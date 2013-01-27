local require = require
local print = print
local ipairs = ipairs
require "lunit"
module( "logic_test", lunit.testcase )

function block_equal(left, right)
    if (#left ~= #right) then
        print('size not equel')
        return false
    end

    for i=1,#left do
        if (left[i]~=right[i]) then
            print(i..': l='..left[i]..' r='..right[i])
            return false
        end
    end

    return true
end

function test_create_board()
    local mod = require "logic"
    local b = mod.Board:new()
    assert(b ~= nil)
end

function test_add_block()
	local mod = require "logic"
    local viewMod = require "view"
	local b = mod.Board:new()
    local view = viewMod.GamePlayView:new()
	b:SetWidth(8)
	b:SetHeight(8)
    view:SetBoard(b)
	local block = mod.Block:new("棒棒", 1, 0, 0)
	block.Type = 1
	block.CurState = 1
    block.x = 0
    block.y = 0
    b:AddBlock(block)

    assert(block_equal(b:GetBlockData(), 
            {0,1,0,0,0,0,0,0,
             0,1,0,0,0,0,0,0,
             0,1,0,0,0,0,0,0,
             0,1,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0}))

    block.x = -1
    block.y = 0
    b:AddBlock(block)

    assert(block_equal(b:GetBlockData(), 
            {1,1,0,0,0,0,0,0,
             1,1,0,0,0,0,0,0,
             1,1,0,0,0,0,0,0,
             1,1,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0}))

    block.x = 1
    block.y = 0
    b:AddBlock(block)
    assert(block_equal(b:GetBlockData(), 
            {1,1,1,0,0,0,0,0,
             1,1,1,0,0,0,0,0,
             1,1,1,0,0,0,0,0,
             1,1,1,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0}))

    block.x = 2
    block.y = 0
    b:AddBlock(block)

    block.x = 3
    block.y = 0
    b:AddBlock(block)

    block.x = 4
    block.y = 0
    b:AddBlock(block)

    block.x = 5
    block.y = 0
    b:AddBlock(block)

    block.x = 6
    block.y = 0
    b:AddBlock(block)

    assert(block_equal(b:GetBlockData(), 
            {1,1,1,1,1,1,1,1,
             1,1,1,1,1,1,1,1,
             1,1,1,1,1,1,1,1,
             1,1,1,1,1,1,1,1,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0}))


    local ret = b:CheckPolish()
    for i,v in ipairs(ret) do
		print(i,v)
    end

    local ret2 = b:CheckPolish2()
    for i,v in ipairs(ret2) do
		print(i,v)
    end

    assert(b:HasFullLine())

    view:Draw()

 --[[   assert(not b:isSolid(1,0))
    assert(not b:isSolid(1,1))
    assert(not b:isSolid(1,2))
    assert(not b:isSolid(1,3))]]
end


function test_remove_full_line()
    local logic_mod = require "logic"
    local board = logic_mod.Board:new()

    board:SetWidth(8)
    board:SetHeight(8)

    board:AddBlockByData(
            {0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             1,1,1,1,1,1,1,1,
             1,1,1,1,1,1,0,0,
             1,1,1,1,1,1,1,1,
             1,1,1,1,1,1,1,1})

    assert(board:HasFullLine())

    board:RemoveFullLine3()
    assert(block_equal(board:GetBlockData(), 
            {0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             1,1,1,1,1,1,0,0}))

    board:_reset_data()

    board:AddBlockByData(
        {1,1,0,0,0,0,0,0, 
         1,1,0,0,0,0,0,0, 
         1,1,1,1,1,1,1,1,
         0,0,0,0,0,0,1,1, 
         0,0,0,0,0,0,1,1,
         1,1,1,1,1,1,0,0, 
         1,1,1,1,1,1,1,1,
         1,1,1,1,1,1,1,1})

    assert(board:HasFullLine())

    board:RemoveFullLine3()
    assert(block_equal(board:GetBlockData(), 
            {0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             0,0,0,0,0,0,0,0,
             1,1,0,0,0,0,0,0,
             1,1,0,0,0,0,0,0,
             0,0,0,0,0,0,1,1,
             0,0,0,0,0,0,1,1,
             1,1,1,1,1,1,0,0}))

end


function test_block_rotate()
    local logic_mod = require "logic"
    -- 创建x=3, y=0的棒棒形状
    local block1 = logic_mod.Block:new('棒棒', 0, 3, 0);
    assert(block_equal(block1:GetBlockData(), 
           {0,1,0,0,
            0,1,0,0,
            0,1,0,0,
            0,1,0,0}
        ))

    local block1_rotate_left = block1:TurnLeft()
    local block1_rotate_right = block1:TurnRight()

    assert(block_equal(block1_rotate_left:GetBlockData(), 
           block1_rotate_right:GetBlockData()));

    assert(block_equal(block1:GetBlockData(), 
            {0,0,0,0,
            1,1,1,1,
            0,0,0,0,
            0,0,0,0}
        ))

    local block1_rotate_4times = block1:TurnLeft():TurnLeft():TurnLeft():TurnLeft()
    assert(block_equal(block1:GetBlockData(), 
           block1_rotate_4times:GetBlockData()));  
end

function test_board_collision()

end


