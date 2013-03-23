local GameControlModule = require 'control'
local TestControlModule = require 'test_control'
local GameView = require 'view'

local game_control = nil
local game_state = 'game_play'


local test_control = nil
local test_view = nil


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
	test_view = GameView.GamePlayView:new()
	game_control = GameControlModule.GameControl:new()
	game_control:BeginState()
	game_control:SetView(test_view)

	test_control = TestControlModule.Control:new()
	test_control:BeginState()

	test_view = GameView.GamePlayView:new()
	test_control:SetView(test_view)
end

function love.draw()
	if game_state == 'game_play' then
		game_control:draw()
	elseif string.match(game_state, '_test$') then
		test_control:draw(game_state)
	end

	-- 左上角显示gamestate
	love.graphics.print(game_state, 0, 0)
end

function love.update(dt)
	-- Handle Test State
	handle_test_state(dt)
	if game_state == 'game_play' then
		game_control:update(dt)
	elseif string.match(game_state, '_test$') then
		test_control:update(game_state, dt)
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
end