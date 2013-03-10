local GameControlModule = require 'control'
local game_control = nil
local game_state = 'game_play'

local TestStates =
{
	index = 1,
	states = {'block_test', 'board_test'},
	IsTestKeyDown = GameControlModule.IsKeyValid('f1', 60),
}

--[[
game_state for test:

]]--

function love.load()
	game_control = GameControlModule.GameControl:new()
	game_control:BeginState()
end

function love.draw()
	if game_state == 'game_play' then
		game_control:draw()
	end
	love.graphics.print(game_state, 0, 0)
    love.graphics.print('Hello World!', 400, 300)
end

function love.update(dt)
	-- Handle Test State
	handle_test_state(dt)
	if game_state == 'game_play' then
		game_control:update(dt)
	end
end

function handle_test_state(dt)
	if TestStates.IsTestKeyDown(dt) then
		game_state = TestStates.states[TestStates.index]
		TestStates.index = TestStates.index + 1
		if TestStates.index > #TestStates.states then
			TestStates.index = 1
		end
	end
	
	print(game_state)
	if state == 'block_test' then
	end
end