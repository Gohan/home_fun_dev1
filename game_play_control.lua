-- 模块设置, 这个模块是用于显示效果测试的control, 在loveUI中使用
local modname = 'game_play_control'
local M = {}
_G[modname] = M
package.loaded[modname] = M


-- 导入段
local setmetatable = setmetatable
local print = print
local assert = assert
local math = require "math"
local logic = require "logic"
local misc = require "misc"
local os = require "os"
local ipairs = ipairs
local love = love
local string = string

-- 常量段
local FPS = 30 -- 30 tick/second
local MIN_DT = 1/FPS
local next_time = 0
local NeedSwitchToNextBlock = misc.Misc.CreateTriggerChecker(1, false)
local IsKeyValid = misc.Misc.IsKeyValid

setfenv(1, M)

-- 正式模块代码
GameSettings = 
{

}

local settings_cooldown_time = 0.1 -- 每0.1s叠加一个方向偏移
GamePlayControl = {
	IsKeyDown = { 
		['left'] = IsKeyValid('left', settings_cooldown_time),
		['right'] = IsKeyValid('right', settings_cooldown_time),
		['up'] = IsKeyValid('up', settings_cooldown_time),
		['down'] = IsKeyValid('down', settings_cooldown_time),
		[' '] = IsKeyValid(' ', settings_cooldown_time), 
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

function GamePlayControl:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self  -- 没有在对象中找到条目时, 从元表中找它
    return o
end

function GamePlayControl:BeginState()
	next_time = love.timer.getMicroTime()
	self.fps = self.fps_count
	self.fps_count = 0
	self.fps_snaptime = love.timer.getMicroTime()

	self.board = logic.Board:new()
	self.board:SetWidth(8)
	self.board:SetHeight(12)

	local time = os.time()
	print(time)
	math.randomseed(1364049727)
end

function GamePlayControl:SetView(view)
	self.view = view
	self.view:SetBoard(self.board)
end

function GamePlayControl:SetBoard(board)
	self.board = board
end

function GamePlayControl:GetFallingDy(dt)
	if self.falling_count > 1 then
		self.falling_count = 0
		return 1
	else
		self.falling_count = self.falling_count + dt
		return 0
	end
end

function GamePlayControl:CalculateDxAndDy(dt)
	-- 计算dx
	self.dx = 0
	if self.IsKeyDown['left'](dt) then
		self.dx = self.dx - 1
	end
	if self.IsKeyDown['right'](dt) then
		self.dx = self.dx + 1
	end

	-- 计算dy
	local dy = self:GetFallingDy(dt)
	self.dy = dy

	if self.IsKeyDown['down'](dt) then
		self.dy = self.dy + 1
	end

	-- 更新block位置

	-- 判断碰撞, 自适应block位置

	-- 判断消除, 上一帧的block状态与这一帧相同, 则block落下. 以后可以实现增加动画

	-- 生成下一个block
end
-- 游戏中的更新处理
-- 游戏中帧控制



local play_state = 'creating_block'

function GamePlayControl:CreateBlock()
	-- 暂时不随机
	local type = math.ceil(math.random()*7)
	print(logic.BlockTypes[type])
	return logic.Block:new(logic.BlockTypes[type], 0, 0, 0)
end

-- 游戏中的绘制的处理
function GamePlayControl:draw()
	function tostring(boolean)
		if boolean then
			return 'true'
		end
		return 'false'
	end

	-- 这种情况绘制方块, 绘制游戏board
	love.graphics.print(play_state.." state!!", 0, 50);

	if self.view then
		if (self.board) then
			self.view:DrawBoard(self.board)
		end
		if (self.block) then
			self.view:DrawBlock(self.block)
		end
	end

	-- 帧率控制
	local cur_time = love.timer.getMicroTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

function GamePlayControl:update(dt)
	-- 帧率控制
	next_time = next_time + MIN_DT 

	-- 动态检查一些游戏输入
	-- ticktime = ticktime + dt

	if play_state == 'creating_block' then
		self.block = self:CreateBlock()
		self.block.x = self.board.width / 2
		self.block.y = -4
		play_state = 'block_drop'
	elseif play_state == 'block_drop' then
		self:CalculateDxAndDy(dt)
		local rotate = self.IsKeyDown['up'](dt)

		if rotate then
			self.block = self.block:RotateLeft()
			if self.board:IsCollision(self.block) then
				self.block = self.block:RotateRight()
			end
		end

		self.block.x = self.block.x + self.dx
		if self.board:IsCollision(self.block) then
			self.block.x = self.block.x - self.dx
		end

		self.dy = self.dy * 2
		assert(self.dy >= 0)
		while self.dy ~= 0 do
			if self.board:IsTouchBottom(self.block) then
				self.board:AddBlock(self.block)
				if self.board:HasFullLine() then
					play_state = 'line_clear'
				elseif self.block:GetBlockValidTop() < 0 then
					play_state = 'game_over'
				else
					play_state = 'creating_block'
				end
				break;
			else
				self.block.y = self.block.y + 1
				self.dy = self.dy - 1
			end
		end

		-- Buggy code
		-- if self.dy ~= 0 then
		-- 	if self.board:IsTouchBottom(self.block) then
		-- 		self.board:AddBlock(self.block)
		-- 		if self.board:HasFullLine() then
		-- 			play_state = 'line_clear'
		-- 		elseif self.block:GetBlockValidTop() < 0 then
		-- 			play_state = 'game_over'
		-- 		else
		-- 			play_state = 'creating_block'
		-- 		end
		-- 	else
		-- 		self.block.y = self.block.y + self.dy
		-- 	end
		-- end
	elseif play_state == 'line_clear' then
		self.board:RemoveFullLine3()
		play_state = 'creating_block'
	elseif play_state == 'game_over' then
		if self.IsKeyDown[' '](dt) then
			play_state = 'restart_game'
		end
	elseif play_state == 'restart_game' then
		self:BeginState()
		self:SetView(self.view)
		play_state = 'creating_block'
	end

	self.fps_count = self.fps_count + 1
	if love.timer.getMicroTime() - self.fps_snaptime > 1 then
		self.fps = self.fps_count
		self.fps_count = 0
		self.fps_snaptime = love.timer.getMicroTime()
	end
end

return M