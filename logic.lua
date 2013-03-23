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

local BlockType = {
    ['棒棒'] = 1, 
    ['田格'] = 2, 
    ['T型'] = 3, 
    ['左拐弯'] = 4,
    ['右拐弯'] = 5,
    ['左Z'] = 6, 
    ['右Z'] = 7
}

BlockTypes = 
{
    '棒棒', '田格', 'T型', '左拐弯', '右拐弯', '左Z', '右Z'
}

local Blocks = {
    {
        desc = "棒棒",
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
    },

    {
        desc = "左拐弯",
        data = {
            {1,1,0,0,
            0,1,0,0,
            0,1,0,0,
            0,0,0,0},
            {0,0,1,0,
            1,1,1,0,
            0,0,0,0,
            0,0,0,0},
            {1,0,0,0,
            1,0,0,0,
            1,1,0,0,
            0,0,0,0},
            {1,1,1,0,
            1,0,0,0,
            0,0,0,0,
            0,0,0,0}
        }
    },

    {
        desc = "右拐弯",
        data = {
            {1,1,0,0,
            1,0,0,0,
            1,0,0,0,
            0,0,0,0},
            {1,1,1,0,
            0,0,1,0,
            0,0,0,0,
            0,0,0,0},
            {0,1,0,0,
            0,1,0,0,
            1,1,0,0,
            0,0,0,0},
            {1,0,0,0,
            1,1,1,0,
            0,0,0,0,
            0,0,0,0}
        }
    },
    {
        desc = "左Z",
        data = {
            {1,1,0,0,
            0,1,1,0,
            0,0,0,0,
            0,0,0,0},
            {0,1,0,0,
            1,1,0,0,
            1,0,0,0,
            0,0,0,0}
        }
    },
    {
        desc = "右Z",
        data = {
            {0,1,1,0,
            1,1,0,0,
            0,0,0,0,
            0,0,0,0},
            {1,0,0,0,
            1,1,0,0,
            0,1,0,0,
            0,0,0,0}
        }
    },


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

    -- 这里要置空, 否则创建的board对象会共享一个data表, 有趣
    o.data = {}
    o:_reset_data()
    return o
end


function Board:SetWidth(val)
    self.width = val
    self:_reset_data()
end

function Board:GetWidth()
    return self.width
end

function Board:SetHeight(val)
    self.height = val
    self:_reset_data()
end

function Board:GetHeight()
    return self.height
end


function Board:IsAvailableBlock(block)
    return false
end

function Board:GetBlockData()
    return self.data
end

function Board:GetBlockPoints()
    local data = self.data
    local ret = {}
    for i = 1, #data do
        if (data[i] == 1) then
            x, y = IndexToXY(i, self.width)
            ret[#ret+1] = {x=x, y=y}
        end
    end
    return ret
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
        if Blocks[block.Type].data[block.CurState+1][i] == 1 then
            self.data[XYtoIndex(block.x+x, block.y+y, self.width)] = 1
        end
    end

    self:_debug_print_data()
end

function Board:AddBlockByData(data)
    for i=1, #data do
        self.data[i] = data[i]
    end

    -- self:_debug_print_data()
end

function Board:IsSolid(x, y)
    -- print('solid'..XYtoIndex(x, y, self.width))
    return self.data[XYtoIndex(x, y, self.width)] == 1
end

function Board:IsOutOfRange(x, y)
    --  y < 0 被认为是有效的
    if x >= self.width or x < 0 or 
       y >= self.height then
        return true
    end
    return false
    -- body
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

-- 判断一个data(block)是否触底
-- TODO: 应该写测试用例
function Board:IsTouchBottomByBlockData(data, width, x, y)
    for iter_x = width-1, 0, -1 do
        for iter_y = math.floor((#data-1) / width), 0, -1 do
            local index = XYtoIndex(iter_x, iter_y, width)
            if data[index] ~= 0 then
                if self:IsOutOfRange(iter_x+x, iter_y+y+1)
                   or (self.data[XYtoIndex(iter_x + x, iter_y + y + 1, self.width)] ~= 0 
                       and iter_y + y + 1 >= 0) then
                    return true
                end
                break
            end
        end
    end
    return false
end

function Board:IsTouchBottom(block)
    return self:IsTouchBottomByBlockData(
        block:GetBlockData(), 
        block.width, 
        block.x, 
        block.y)
end

function Board:IsOutOfBoardByBlockData(data, width, x, y)
    return nil
end

function Board:IsOutOfBoard(block)
    return self:IsOutOfBoardByBlockData(
        block:GetBlockData(), 
        block.width, 
        block.x, 
        block.y)
end

function Board:IsCollisionByBlockData(data, width, x, y)
    for i=1, #data do
        if data[i] ~= 0 then
            local dx, dy = IndexToXY(i, width)
            local bx, by = x+dx, y+dy
            if self:IsOutOfRange(bx, by) then 
                print('collision at x:'..x+dx..' y:'..y+dy..'\n')
                return true
            elseif by >= 0 then
                index = XYtoIndex(x+dx, y+dy, self.width)
                if self.data[index] ~= 0 then
                    -- print('collision at x:'..x+dx..' y:'..y+dy..'\n')
                    return true
                end
            end
        end
    end
    return false
end

function Board:IsCollision(block)
    return self:IsCollisionByBlockData(block:GetBlockData(), block.width, block.x, block.y)
end



Block =
{
    CurState = 1;
    Type = 1;
    x = 0;
    y = 0;
    width = 4;
}
function Block:new(name, state, x, y)
    local o = {}
    setmetatable(o, self)
    self.__index = self  -- 没有在对象中找到条目时, 从元表中找它
    
    o.Type = BlockType[name]
    if o.Type == nil then
        return
    end


    if (Blocks[o.Type] == nil) then
        -- print("Error "..o.Type.." 不存在")
        return nil
    end


    local StateCount = #Blocks[o.Type].data
    if StateCount == 0 then
        return
    end

    o.CurState = state % StateCount
    o.x = x
    o.y = y
    print(o.CurState..o.x..o.y..StateCount)
    return o
end

function Block:CreateBlockByType(type, state, x, y)
    local o = {
        Type = type,
        CurState = state,
        x = x,
        y = y,
    }
    setmetatable(o, self)
    self.__index = self  -- 没有在对象中找到条目时, 从元表中找它
    return o
end

function Block:GetStateCount()
    return #Blocks[self.Type].data
end

function Block:GetMove(direction)
    local n = #Blocks[self.Type].data
    local state = self.state
    if (direction == 'L') then state = (state+n-1)%n
    elseif (direction == 'R') then state = (state+1)%n
    end
        
    return Block:new(self.name, state, self.x, self.y)
end

function Block:RotateLeft()
    local n = #Blocks[self.Type].data
    local state = (self.CurState+n-1)%n
    return self:CreateBlockByType(self.Type, state, self.x, self.y)
end

function Block:RotateRight()
    local n = #Blocks[self.Type].data
    local state = (self.CurState+1)%n
    return self:CreateBlockByType(self.Type, state, self.x, self.y)
end

function Block:GetBlockData()
    return Blocks[self.Type].data[self.CurState+1]
end

function Block:GetBlockPoints()
    local data = Blocks[self.Type].data[self.CurState+1]
    local ret = {}
    for i = 1, #data do
        if (data[i] == 1) then
            block_x, block_y = IndexToXY(i, 4)
            ret[#ret+1] = {x=self.x+block_x, y=self.y+block_y}
        end
    end
    return ret
end

function Block:_debug_print_data()
    print("========_debug_print_data========")
    str = ""
    for i,v in ipairs(self:GetBlockData()) do
        str = str..v
        if (i % self.width == 0) then
            print(str)
            str = ""
        end
    end
    print("========_debug_print_data (end)========")
end

return M
