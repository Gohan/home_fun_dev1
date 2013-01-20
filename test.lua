local require = require
require "lunit"
local print = print
local ipairs = ipairs
module( "my_testcase", lunit.testcase )

function test_create_board()
    local mod = require "logic"
    b = mod.Board:new()
    assert(b ~= nil)
end

function test_add_block()
	local mod = require "logic"
	local b = mod.Board:new()
	b:setWidth(8)
	b:setHeight(8)
	local block = mod.Block:new()
	block.Type = 1
	block.CurState = 1
    block.x = 0
    block.y = 0
    b:AddBlock(block)

    assert(b:isSolid(1,0))
    assert(b:isSolid(1,1))
    assert(b:isSolid(1,2))
    assert(b:isSolid(1,3))

    block.x = -1
    block.y = 0
    b:AddBlock(block)
    assert(b:isSolid(0,0))
    assert(b:isSolid(0,1))
    assert(b:isSolid(0,2))
    assert(b:isSolid(0,3))
    assert(not b:isSolid(2,0))


    block.x = 1
    block.y = 0
    b:AddBlock(block)
    assert(b:isSolid(2,0))
    assert(b:isSolid(2,1))
    assert(b:isSolid(2,2))
    assert(b:isSolid(2,3))

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

    local ret = b:CheckPolish()
    for i,v in ipairs(ret) do
		print(i,v)
    end

    local ret2 = b:CheckPolish2()
    for i,v in ipairs(ret2) do
		print(i,v)
    end
 --[[   assert(not b:isSolid(1,0))
    assert(not b:isSolid(1,1))
    assert(not b:isSolid(1,2))
    assert(not b:isSolid(1,3))]]

end

function test_add_block2()
	local mod = require "logic"
	local b = mod.Board:new()
	b:setWidth(8)
	b:setHeight(8)
	local block = mod.Block:new()
	block.Type = 1
	block.CurState = 1
    block.x = 0
    block.y = 0
    b:AddBlock(block)

    assert(b:isSolid(1,0))
    assert(b:isSolid(1,1))
    assert(b:isSolid(1,2))
    assert(b:isSolid(1,3))

    block.x = -1
    block.y = 0
    b:AddBlock(block)
    assert(b:isSolid(0,0))
    assert(b:isSolid(0,1))
    assert(b:isSolid(0,2))
    assert(b:isSolid(0,3))
    assert(not b:isSolid(2,0))


    block.x = 1
    block.y = 0
    b:AddBlock(block)
    assert(b:isSolid(2,0))
    assert(b:isSolid(2,1))
    assert(b:isSolid(2,2))
    assert(b:isSolid(2,3))

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

    local ret = b:CheckPolish()
    for i,v in ipairs(ret) do
		print(i,v)
    end
 --[[   assert(not b:isSolid(1,0))
    assert(not b:isSolid(1,1))
    assert(not b:isSolid(1,2))
    assert(not b:isSolid(1,3))]]

end