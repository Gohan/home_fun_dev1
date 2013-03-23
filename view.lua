-- 模块设置
local modname = 'view'
local M = {}
_G[modname] = M
package.loaded[modname] = M


-- 导入段
local setmetatable = setmetatable
local print = print
local assert = assert
local math = require "math"
local logic = require "logic"
local love = love
local ipairs = ipairs
--
-- 每格像素大小
local BLOCK_SIZE = 32
local BOARD_HEIGHT = 12
local BOARD_WIDTH = 8

local BLOCK_COLOR = {0, 100, 0, 255}
local LINE_COLOR = {200, 0, 0, 255}
-- 
--
setfenv(1, M)

-- Begin module 


-- 这里设定, 每一个方块10像素, board是一个网:
-- 0,0, 10,0, 20, 0 这样就是每一条线
GamePlayView = 
{
    is_playing_animate = false,
    board = nil,
    view_pos_x = 100,
    view_pos_y = 100,
}

function GamePlayView:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self  -- 没有在对象中找到条目时, 从元表中找它
    return o
end

function GamePlayView:SetBoard(board) -- 设置board
    self.board = board
end

function GamePlayView:SetAnimateBegin() -- 设置开始(消除)动画
    self.is_playing_animate = true
end

function GamePlayView:DrawOnePoint( x, y )
	love.graphics.rectangle('fill', 
		x * BLOCK_SIZE + self.view_pos_x, y * BLOCK_SIZE + self.view_pos_y,
		BLOCK_SIZE, BLOCK_SIZE);
end

function GamePlayView:DrawBlock(block)

	local height_diff = BOARD_HEIGHT - self.board:GetHeight()

	-- 绘制10*10的网格
	love.graphics.setLine(1, "smooth")
	love.graphics.setColor(LINE_COLOR);

	for i = 0, BOARD_HEIGHT do
		love.graphics.line( self.view_pos_x, 
						    self.view_pos_y + i*BLOCK_SIZE, 
						    self.view_pos_x + BOARD_WIDTH*BLOCK_SIZE, 
						    self.view_pos_y + i*BLOCK_SIZE)
	end

	for i = 0, BOARD_WIDTH do
		love.graphics.line( self.view_pos_x + i*BLOCK_SIZE, 
						    self.view_pos_y, 
						    self.view_pos_x + i*BLOCK_SIZE, 
						    self.view_pos_y + BOARD_HEIGHT*BLOCK_SIZE)
	end

	love.graphics.setColor(BLOCK_COLOR);
	local points = block:GetBlockPoints()
	for i = 1, #points do
		self:DrawOnePoint(points[i].x, points[i].y + height_diff)
	end

	love.graphics.setColor(255, 255, 255, 255);	
end

function GamePlayView:DrawBoard(board)

	local height_diff = BOARD_HEIGHT - board:GetHeight()

	-- 绘制10*10的网格
	love.graphics.setLine(1, "smooth")
	love.graphics.setColor(LINE_COLOR);

	for i = 0, BOARD_HEIGHT do
		love.graphics.line( self.view_pos_x, 
						    self.view_pos_y + i*BLOCK_SIZE, 
						    self.view_pos_x + BOARD_WIDTH*BLOCK_SIZE, 
						    self.view_pos_y + i*BLOCK_SIZE)
	end

	for i = 0, BOARD_WIDTH do
		love.graphics.line( self.view_pos_x + i*BLOCK_SIZE, 
						    self.view_pos_y, 
						    self.view_pos_x + i*BLOCK_SIZE, 
						    self.view_pos_y + BOARD_HEIGHT*BLOCK_SIZE)
	end

	love.graphics.setColor(BLOCK_COLOR);
	local points = board:GetBlockPoints()
	for i = 1, #points do
		self:DrawOnePoint(points[i].x, points[i].y + height_diff)
	end
	love.graphics.setColor(255, 255, 255, 255);	
end

function GamePlayView:Draw()
    self.board:_debug_print_data()
end

function GamePlayView:Tick(delta)

end

-- End module
return M
