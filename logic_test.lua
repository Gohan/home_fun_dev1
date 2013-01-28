-- 使用busted来测试代码


-- helper functions
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

-- testsuite
describe("logic_test", function()
    it("Board:AddBlock", function()
        local mod = require "logic"
        local b = mod.Board:new()
        b:SetWidth(8)
        b:SetHeight(8)
        local block = mod.Block:new("棒棒", 0, 0, 0)
        b:AddBlock(block)

        assert.is_true(block_equal(b:GetBlockData(), 
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

        assert.is_true(block_equal(b:GetBlockData(), 
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
        assert.is_true(block_equal(b:GetBlockData(), 
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

        assert.is_true(block_equal(b:GetBlockData(), 
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
            --print(i,v)
        end

        local ret2 = b:CheckPolish2()
        for i,v in ipairs(ret2) do
            --print(i,v)
        end

        assert(b:HasFullLine())
    end)

    it("Board:RemoveFullLine", function()
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
    end)
    
    it("Board:RemoveFullLine3", function()
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

        assert.is_true(board:HasFullLine())

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

        assert.is_true(board:HasFullLine())

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
    end)

    it("Block:GetBlockData", function()
        local logic_mod = require "logic"
        -- 创建x=3, y=0的棒棒形状
        local block1 = logic_mod.Block:new('棒棒', 0, 3, 0);
        assert.is_true(block_equal(block1:GetBlockData(), 
               {0,1,0,0,
                0,1,0,0,
                0,1,0,0,
                0,1,0,0}
        ))
    end)

    it("Block:CreateTurn", function()
        local logic_mod = require "logic"
        -- 创建x=3, y=0的棒棒形状
        local block1 = logic_mod.Block:new('棒棒', 0, 3, 0);
        assert.is_true(block_equal(block1:GetBlockData(), 
               {0,1,0,0,
                0,1,0,0,
                0,1,0,0,
                0,1,0,0}
            ))

        local block1_rotate_left = block1:RotateLeft()
        local block1_rotate_right = block1:RotateRight()

        assert.is_true(block_equal(block1_rotate_left:GetBlockData(), 
               block1_rotate_right:GetBlockData()));

        assert.is_true(block_equal(block1_rotate_left:GetBlockData(), 
                {0,0,0,0,
                1,1,1,1,
                0,0,0,0,
                0,0,0,0}
            ))

        local block1_rotate_4times = block1:RotateLeft():RotateLeft():RotateLeft():RotateLeft()
        assert.is_true(block_equal(block1:GetBlockData(), 
               block1_rotate_4times:GetBlockData()));  
    end)

    it("Board:CheckCollision", function()
        local logic_mod = require "logic"
        -- 创建x=3, y=0的棒棒形状
        local block1 = logic_mod.Block:new('棒棒', 0, 3, 0);
        assert.is_true(block_equal(block1:GetBlockData(), 
               {0,1,0,0,
                0,1,0,0,
                0,1,0,0,
                0,1,0,0}
            ))

        local block1_rotate_left = block1:RotateLeft()
        local block1_rotate_right = block1:RotateRight()

        assert.is_true(block_equal(block1_rotate_left:GetBlockData(), 
               block1_rotate_right:GetBlockData()));

        assert.is_true(block_equal(block1_rotate_left:GetBlockData(), 
                {0,0,0,0,
                1,1,1,1,
                0,0,0,0,
                0,0,0,0}
            ))

        local block1_rotate_4times = block1:RotateLeft():RotateLeft():RotateLeft():RotateLeft()
        assert.is_true(block_equal(block1:GetBlockData(), 
               block1_rotate_4times:GetBlockData()));  
    end)
end)