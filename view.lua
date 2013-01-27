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
local ipairs = ipairs
--
-- 
--
setfenv(1, M)

-- Begin module 

GamePlayView = 
{
    is_playing_animate = false,
    board = nil,
    
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

function GamePlayView:Draw()
    self.board:_debug_print_data()
end

function GamePlayView:Tick(delta)

end

-- End module
return M
