--[[
    PauseState Class
    Author: Leon Cao
    mintyck@gmail.com

    A simple state used to pause game.
]]

PauseState = Class { __includes = BaseState }

function PauseState:enter(params)
    sounds['music']:pause()

    self.bird = params.bird
    self.pipePairs = params.pipePairs
    self.timer = params.timer
    self.score = params.score
    self.lastY = params.lastY
end

function PauseState:exit(params)
    sounds['music']:play()
end

function PauseState:update()
    -- go back to play if space or mouse is pressed
    if love.keyboard.wasPressed('space') or love.mouse.wasPressed(1) then
        gStateMachine:change('play', {
            bird = self.bird,
            pipePairs = self.pipePairs,
            timer = self.timer,
            score = self.score,
            lastY = self.lastY
        })
    end
end

function PauseState:render()
    -- render paused game
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()

    love.graphics.setFont(flappyFont)
    love.graphics.printf('Game Paused', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(hugeFont)
    love.graphics.printf('II', 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press Space or Mouse to Continue!', 0, 170, VIRTUAL_WIDTH, 'center')
end
