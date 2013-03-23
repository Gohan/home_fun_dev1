-- 模块设置, 这个模块是用于显示效果测试的control, 在loveUI中使用
local modname = 'test_control'
local M = {}
_G[modname] = M
package.loaded[modname] = M


-- 导入段
local setmetatable = setmetatable
local print = print
local assert = assert
local math = require "math"
local control = require "control"
local logic = require "logic"
local misc = require "misc"
local ipairs = ipairs
local love = love
local string = string
local IsKeyValid = control.IsKeyValid

-- 常量段
local FPS = 30 -- 30 tick/second
local MIN_DT = 1/FPS
local next_time = 0
local NeedSwitchToNextBlock = misc.Misc.CreateTriggerChecker(1, false)


setfenv(1, M)

-- 正式模块代码

Settings = 
{

}

local settings_cooldown_time = 0.1 -- 每0.1s叠加一个方向偏移
Control = {
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

function Control:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self  -- 没有在对象中找到条目时, 从元表中找它
    return o
end

local TestBoardFrame = 
{
{ -- 1
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,0,0,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1
},
{ -- 2
0,0,0,1,0,0,0,0,
0,0,0,1,0,0,0,0,
0,0,0,1,0,0,0,0,
0,0,0,1,0,0,0,0,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,0,0,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1
},
{ -- 3
0,0,0,0,1,0,0,0,
0,0,0,0,1,0,0,0,
0,0,0,0,1,0,0,0,
0,0,0,0,1,0,0,0,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,0,0,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1
},
{ -- 4
0,0,0,0,0,0,0,0,
0,1,1,0,0,1,1,0,
0,1,1,0,0,1,1,0,
0,1,1,1,1,1,1,0,
0,1,1,1,1,1,1,0,
0,0,0,0,0,1,1,0,
0,0,0,0,0,1,1,0,
1,1,1,1,1,1,1,1
},
}

function Control:BeginState()
	next_time = love.timer.getMicroTime()
	self.fps = self.fps_count
	self.fps_count = 0
	self.fps_snaptime = love.timer.getMicroTime()

	self.board = logic.Board:new()
	self.board:SetWidth(8)
	self.board:SetHeight(8)
end

function Control:SetView(view)
	self.view = view
end

function Control:SetBoard(board)
	self.board = board
end

function Control:GetFallingDy(dt)
	if self.falling_count > 1 then
		self.falling_count = 0
		return 1
	else
		self.falling_count = self.falling_count + dt
		return 0
	end
end

function Control:CalculateDxAndDy(dt)
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

	if self.IsKeyDown['up'](dt) then
		self.dy = self.dy - 1
	end
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

(function (o)
	local index = 1
	o.BlockTestOnUpdate = function(self, dt)
		self:CalculateDxAndDy(dt)
		local rotate = self.IsKeyDown[' '](dt)

		-- 更新当前的block
		if NeedSwitchToNextBlock(dt) then
			index = index + 1
			if (index > #logic.BlockTypes) then
				index = 1
			end
		end

		self.block = self:CreateBlock(index)
		self.block.x = self.block.x + self.dx
		self.block.y = self.block.y + self.dy

		if rotate then
			self:TurnBlock(index)
		end
	end

	o.BlockTestOnDraw = function(self)
		self.block = self:CreateBlock(index)

		if self.view then
			love.graphics.print("view -- draw block"..index.."!!", 0, 50);
			love.graphics.print('x: '..self.block.x..' y: '..self.block.y, 500, 500)
			if (self.block) then
				self.view:DrawBlock(self.block)
			end
		end
	end
end)(Control);

(function (o)
	local GetBoard = (function ()
		local boards = {}
		local f = function (index)
			if boards[index] == nil and TestBoardFrame[index] ~= nil then
				print(index)
				boards[index] = logic.Board:new()
				boards[index]:SetWidth(8)
				boards[index]:SetHeight(8)
				boards[index]:AddBlockByData(TestBoardFrame[index])
			end
			return boards[index]
		end
		return f
	end)()

	local index = 1
	o.BoardTestOnUpdate = function(self, dt)
		local dx = 0
		if self.IsKeyDown['left'](dt) then
			dx = dx - 1
		end
		if self.IsKeyDown['right'](dt) then
			dx = dx + 1
		end

		index = index + dx
		if (index > #TestBoardFrame) then
			index = 1
		elseif index < 1 then
			index = #TestBoardFrame
		end
		self.board = GetBoard(index)
	end

	o.BoardTestOnDraw = function(self)
		self.board = GetBoard(index)
		if self.view then
			love.graphics.print("view -- draw board"..index.."!!", 0, 50);
			if (self.board) then
				self.view:DrawBoard(self.board)
				self.board:_debug_print_data()
			end
		end
	end
end)(Control)




local block_index = 1
function Control:update(state, dt)
	-- 帧率控制
	next_time = next_time + MIN_DT 

	-- 动态检查一些游戏输入
	-- ticktime = ticktime + dt

	if state == 'block_test' then
		-- self:CalculateDxAndDy(dt)
		-- local rotate = self.IsKeyDown[' '](dt)

		-- -- 更新当前的block
		-- if NeedSwitchToNextBlock(dt) then
		-- 	block_index = block_index + 1
		-- 	if (block_index > #logic.BlockTypes) then
		-- 		block_index = 1
		-- 	end
		-- end

		-- self.block = self:CreateBlock(block_index)
		-- self.block.x = self.block.x + self.dx
		-- self.block.y = self.block.y + self.dy

		-- if rotate then
		-- 	self:TurnBlock(block_index)
		-- end

		-- print('x: '..self.block.x..' y: '..self.block.y)
		-- love.graphics.print('x: '..self.block.x..' y: '..self.block.y, 500, 500)
		self:BlockTestOnUpdate(dt)
	elseif state == 'board_test' then
		self:BoardTestOnUpdate(dt)
	end

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
function Control:draw(state)
	function tostring(boolean)
		if boolean then
			return 'true'
		end
		return 'false'
	end

	if state == 'block_test' then
		-- self.block = self:CreateBlock(block_index)

		-- if self.view then
		-- 	love.graphics.print("view -- draw block"..block_index.."!!", 0, 50);
		-- 	if (self.block) then
		-- 		self.view:DrawBlock(self.block)
		-- 	end
		-- end
		self:BlockTestOnDraw()
	elseif state == 'board_test' then
		self:BoardTestOnDraw()
	end

    if self.view then
	    -- self.view:draw_board(self.board)
	    -- self.view:draw_block(self.block)
	end

	-- 帧率控制
	local cur_time = love.timer.getMicroTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

function Control:CreateBlock_WRONG(index)
	local blocks = {}
	local LocalCreateBlock = function (index)
		if (logic.BlockTypes[index]) then
			print(logic.BlockTypes[index])
			return logic.Block:new(logic.BlockTypes[index], 0, 0, 0)
		end
	end

	if (blocks[index] == nil) then
		blocks[index] = LocalCreateBlock(index)
	end
	return blocks[index]
end

local functable = (function ()
	local functable = {}
	local blocks = {}

	functable.LocalCreateBlock = function (self, index)
		if (blocks[index] == nil) then
			print('创建'..logic.BlockTypes[index])
			blocks[index] = logic.Block:new(logic.BlockTypes[index], 0, 0, 0)
		end
		return blocks[index]
	end

	functable.LocalTurnBlock = function (self, index)
		if (blocks[index] ~= nil) then
			blocks[index] = blocks[index]:RotateLeft()
		end
		return blocks[index]
	end

	return functable
end)()

Control.CreateBlock = functable.LocalCreateBlock
Control.TurnBlock = functable.LocalTurnBlock

return M