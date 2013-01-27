-- 模块设置
local modname = 'logic'
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

local Blocks = {
    {
        desc = "a",
        data = {
            {0,1,0,0,
            0,1,0,0,
            0,1,0,0,
            0,1,0,0},
            {0,0,0,0,
            1,1,1,1,
            0,0,0,0,
            0,0,0,0}
        }
    },

    {
        desc = "田格",
        data = {
            {0,1,1,0,
            0,1,1,0,
            0,0,0,0,
            0,0,0,0}
        }
    },

    {
        desc = "T型",
        data = {
            {1,1,1,0,
            0,1,0,0,
            0,0,0,0,
            0,0,0,0},
            {0,1,0,0,
            1,1,0,0,
            0,1,0,0,
            0,0,0,0},
            {0,1,0,0,
            1,1,1,0,
            0,0,0,0,
            0,0,0,0},
            {0,1,0,0,
            0,1,1,0,
            0,1,0,0,
            0,0,0,0}
        }
    }
}



Board = {
    data = {},
    width = 8,
    height = 8,
    config = {
        ["debug_output"] = true,
    },
}
function Board:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self  -- 没有在对象中找到条目时, 从元表中找它
    self:_reset_data()
    return o
end


function Board:SetWidth(val)
    self.width = val
    self:_reset_data()
end

function Board:SetHeight(val)
    self.height = val
    self:_reset_data()
end


function Board:IsAvailableBlock(block)
    return false
end

function Board:GetBlockData()
    return self.data
end

function Board:RemoveFullLine()
    local baseline = self.height-1
    for k = self.height-1, 0, -1 do
        if not self:_is_line_full(k, self.width) and k ~= self.height then
            self:MoveLine(k, baseline)
            baseline = baseline - 1
        end
    end

    for i = baseline, 0, -1 do
        self:ResetLine(i)
    end

    self:_debug_print_data()
end

function Board:MoveLine( srcline, dstline )
    local width = self.width
    for i = 1, width do
        self.data[dstline * width + i] = self.data[srcline * width + i] 
    end
end

function Board:ResetLine(line)
    local width = self.width
    for i = line * width + 1, line * width + width do
        self.data[i] = 0 
    end
end

function Board:MoveDown(line, count)
    local width = self.width
    for i = line * width + 1, line * width + width do
        self.data[i+count*width] = self.data[i]
    end
end

function Board:RemoveFullLine2()
    local move_down_count = 0
    polish_lines = self:CheckPolish2()
    local index = #polish_lines; 
    for i = self.height-1, 0, -1 do
        if (i == polish_lines[index]) then -- 这行当然就是消除行, 不去处理
            index = index - 1
            move_down_count = move_down_count + 1
            self:ResetLine(i)
        elseif move_down_count > 0 then
            self:MoveDown(i, move_down_count)
            self:ResetLine(i)
        end
    end
    self:_debug_print_data()
end

function Board:RemoveFullLine3()
    local move_down_count = 0
    for i = self.height-1, 0, -1 do
        if (self:_is_line_full(i, self.width)) then -- 这行当然就是消除行, 不去处理
            move_down_count = move_down_count + 1
            self:ResetLine(i)
        elseif move_down_count > 0 then
            self:MoveDown(i, move_down_count)
            self:ResetLine(i)
        end
    end
    self:_debug_print_data()
end

--[[
1~64

2, 10, 18, 26
]]

function XYtoIndex(x, y, width)
    return x + y*width + 1
end

function IndexToXY(index, width)
    return (index-1)%width, math.floor((index-1)/width)
end


function Board:_debug_print_data()
    if (self.config["debug_output"] ~= true) then
        return
    end

    print("========_debug_print_data========")
    str = ""
    for i,v in ipairs(self.data) do
        str = str..v
        if (i % self.width == 0) then
            print(str)
            str = ""
        end
    end
    print("========_debug_print_data (end)========")
end

function Board:_reset_data()
    for i = 1, self.width*self.height do
        self.data[i] = 0
    end  
end

function Board:_is_line_full(line, width)
    for i = line * width + 1, line * width + width do
        if self.data[i] == 0 then
            return false
        end
    end
    return true
end

function Board:HasFullLine()
    local ret = false
    for i = 0, self.height-1 do
        if self:_is_line_full(i, self.width) then
            ret = true
            break
        end
    end
    return ret
end

function Board:AddBlock(block)
    for i=1,16 do
        x, y = IndexToXY(i, 4)
        if Blocks[block.Type].data[block.CurState][i] == 1 then
            self.data[XYtoIndex(block.x+x, block.y+y, self.width)] = 1
        end
    end

    self:_debug_print_data()
end

function Board:AddBlockByData(data)
    for i=1, #data do
        self.data[i] = data[i]
    end

    self:_debug_print_data()
end

function Board:IsSolid(x, y)
    -- print('solid'..XYtoIndex(x, y, self.width))
    return self.data[XYtoIndex(x, y, self.width)] == 1
end

-- 返回可消除的行数(从0开始)
function Board:CheckPolish()
    bCanPolish = 1;
    local ret = {}
    for i = 1, self.width*self.height do
        bCanPolish = bCanPolish and self.data[i]
        if bCanPolish == 0 then
            i = math.ceil(i / self.width) * self.width + 1
        elseif i%self.width == 0 then
            ret[#ret+1] = math.floor((i-1) / self.width)
        end
    end
    return ret
end

-- 返回可消除的行数(从0开始)
function Board:CheckPolish2()
    local ret = {}
    for i = 0, self.height-1 do
        if self:_is_line_full(i, self.width) then
            ret[#ret+1] = i
        end
    end
    return ret
end

Block =
{
    CurState = 1;
    Type = 1;
    x = 0;
    y = 0;
}
function Block:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self  -- 没有在对象中找到条目时, 从元表中找它
    return o
end

function Block:getTurn(direction)
    local n = #Blocks[Type].data
    if (direction == 'L') then-- 顺时针
        local b = self.new()
        return Blocks[Type].data[(self.CurState+1)%n]
    end
end

function Block:setTurn(direction)

end

return M
