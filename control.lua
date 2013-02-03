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

local settings_cooldown_time = 0.1
GameControl = {
	IsKeyDown = { 
		['left'] = IsKeyValid('left', settings_cooldown_time),
		['right'] = IsKeyValid('right', settings_cooldown_time),
	},
	left,
	right,
	ticktime = 0,
	block_creator, -- 用来创建block的函数
	view, -- view对象(视图类, 用于绘制游戏)
	board, -- board对象(用于存放游戏数据)
	active_block, -- 当前活跃的方块
	dx = 0,
}

function GameControl:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self  -- 没有在对象中找到条目时, 从元表中找它
    return o
end

function GameControl:SetView(view)
	self.view = view
end

function GameControl:SetBoard(board)
	self.board = board
end


-- 游戏中的更新处理
-- 游戏中帧控制
function GameControl:update(dt)
	-- 动态检查一些游戏输入
	-- ticktime = ticktime + dt
	if self.IsKeyDown['left'](dt) then
		self.dx = self.dx - 1
	end
	if self.IsKeyDown['right'](dt) then
		self.dx = self.dx + 1
	end

	-- 
	--love.timer.step()
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
						self.dx, 400, 300)
    if self.view then
	    self.view:draw_board(self.board)
	    self.view:draw_block(self.block)
	end
end

return M