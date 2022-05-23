--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

local goldMedalImage = love.graphics.newImage('resources/images/gold_medal.png')
local silverMedalImage = love.graphics.newImage('resources/images/silver_medal.png')
local bronzeMedalImage = love.graphics.newImage('resources/images/bronze_medal.png')

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    scrolling = false
    sounds['music']:pause()
    
    self.score = params.score
end

function ScoreState:exit()
    scrolling = true
    sounds['music']:play()
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    local resultText = 'Oof! You Lost!'
    local medalImage = nil
    if self.score >= 20 then
        resultText = 'Perfect!'
        medalImage = goldMedalImage
    elseif self.score >= 10 then
        resultText = 'Well Done!' 
        medalImage = silverMedalImage
    elseif self.score >= 5 then
        resultText = 'Good Job!'
        medalImage = bronzeMedalImage
    end

    love.graphics.setFont(flappyFont)
    love.graphics.printf(resultText, 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    if medalImage ~= nil then
        love.graphics.draw(medalImage, VIRTUAL_WIDTH / 2 - 32, 120)
    end

    love.graphics.printf('Press Enter to Play Again!', 0, 190, VIRTUAL_WIDTH, 'center')
end