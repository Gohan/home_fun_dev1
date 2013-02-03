local GameControlModule = require 'control'
local game_control = nil
local game_state = 'game_play'
function love.load()
	game_control = GameControlModule.GameControl:new()
	game_control:BeginState()
end

function love.draw()
	if game_state == 'game_play' then
		game_control:draw()
	end
    love.graphics.print('Hello World!', 400, 300)
end

function love.update(dt)
	if game_state == 'game_play' then
		game_control:update(dt)
	end
end
