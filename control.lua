-- 模块设置
local modname = 'control'
local M = {}
_G[modname] = M
package.loaded[modname] = M


-- 导入段
local setmetatable = setmetatable
local print = print
local assert = assert
local math = require "math"
local ipairs = ipairs
local love = love
local string = string

-- 常量段
local FPS = 30 -- 30 tick/second
local MIN_DT = 1/FPS
local next_time = 0


setfenv(1, M)

-- 正式模块代码

Settings = 
{

}

-- cooldown 表示冷却时间, 如果这个按键被按时间超过冷却时间, 再次返回true.
function IsKeyValid(key, cooldown)
	local holdtime = 0
	f = function (dt)
		if love.keyboard.isDown(key) then
			if holdtime == 0 or holdtime > cooldown then
				holdtime = dt
				return true
			else
				holdtime = holdtime + dt
				return false
			end
		elseif holdtime ~= 0 then
			holdtime = 0
		end
		return false
	end
	return f
end

local settings_cooldown_time = 0.1 -- 每0.1s叠加一个方向偏移
GameControl = {
	IsKeyDown = { 
		['left'] = IsKeyValid('left', settings_cooldown_time),
		['right'] = IsKeyValid('right', settings_cooldown_time),
	},
	left,
	right,
	ticktime = 0,
	speed = 1, -- dy = 1/FPS, cooltime = FPS/speed
	block_creator, -- 用来创建block的函数
	view, -- view对象(视图类, 用于绘制游戏)
	board, -- board对象(用于存放游戏数据)
	-- 当前方块信息
	active_block, -- 当前活跃的方块
	dx = 0,
	dy = 0,
	falling_speed_per_frame = 1/FPS, -- Speed/FPS, holdtime = FPS/Speed
	falling_max_speed_flag = 0, -- 如果不为0说明按了向下的按键, 全速下降
	falling_count = 0,
	-- 计算fps
	fps = 0,
	fps_count = 0,
	fps_snaptime = 0,
}

function GameControl:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self  -- 没有在对象中找到条目时, 从元表中找它
    return o
end

function GameControl:BeginState()
    next_time = love.timer.getMicroTime()
end

function GameControl:SetView(view)
	self.view = view
end

function GameControl:SetBoard(board)
	self.board = board
end

function GameControl:GetFallingDy(dt)
	if self.falling_count > 1 then
		self.falling_count = 0
		return 1
	else
		self.falling_count = self.falling_count + dt
		return 0
	end
end

function GameControl:CalculateDxAndDy(dt)
	-- 计算dx
	if self.IsKeyDown['left'](dt) then
		self.dx = self.dx - 1
	end
	if self.IsKeyDown['right'](dt) then
		self.dx = self.dx + 1
	end

	-- 计算dy
	local dy = self:GetFallingDy(dt)
	self.dy = dy

	-- 更新block位置

	-- 判断碰撞, 自适应block位置

	-- 判断消除, 上一帧的block状态与这一帧相同, 则block落下. 以后可以实现增加动画

	-- 生成下一个block
end
-- 游戏中的更新处理
-- 游戏中帧控制
function GameControl:update(dt)
	-- 帧率控制
	next_time = next_time + MIN_DT 

	-- 动态检查一些游戏输入
	-- ticktime = ticktime + dt
	self:CalculateDxAndDy(dt)

	-- self.fps_count = self.fps_count + 1
	-- 
	--love.timer.step()
	self.fps_count = self.fps_count + 1
	if love.timer.getMicroTime() - self.fps_snaptime > 1 then
		self.fps = self.fps_count
		self.fps_count = 0
		self.fps_snaptime = love.timer.getMicroTime()
	end	
end


-- 游戏中的绘制的处理
function GameControl:draw()
	function tostring(boolean)
		if boolean then
			return 'true'
		end
		return 'false'
	end
	-- 做了view实现后就可以直接这么写了(view和board/block结构绑定)
	-- self.game_view.draw()
    love.graphics.print('Hello World!'..
						'left:'..tostring(self.left)..
						'  right:'..tostring(self.right)..'\n'..
						self.dx..'\n'..
						self.dy..'\n'..
						self.falling_count..'\n'..
						'fps:'..self.fps, 400, 300)
    if self.view then
	    self.view:draw_board(self.board)
	    self.view:draw_block(self.block)
	end

	-- 帧率控制
	local cur_time = love.timer.getMicroTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

return M