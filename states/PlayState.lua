--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class { __includes = BaseState }

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

PIPE_HEIGHT_RANGE = 50

function PlayState:init()
    self.widthBetweenPipes = self.randomHorizontalGap(self)
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('p') then
        sounds['pause']:play()
        gStateMachine:change('pause', {
            bird = self.bird,
            pipePairs = self.pipePairs,
            timer = self.timer,
            score = self.score,
            lastY = self.lastY
        })
    end

    -- update timer for pipe spawning
    self.timer = self.timer + dt

    -- spawn a new pipe pair every second and a half
    if self.timer > self.widthBetweenPipes then
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        local y = math.max(-PIPE_HEIGHT + 40,
            math.min(self.lastY + math.random(-PIPE_HEIGHT_RANGE, PIPE_HEIGHT_RANGE), VIRTUAL_HEIGHT - 150 - PIPE_HEIGHT))
        self.lastY = y

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y))

        -- reset timer
        self.timer = 0

        self.widthBetweenPipes = self.randomHorizontalGap(self)
    end

    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()

                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()

        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()
    
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter(params)
    self.bird = params.bird
    self.pipePairs = params.pipePairs
    self.timer = params.timer
    self.score = params.score
    self.lastY = params.lastY
end

--[[
    Re-random the horizontal gaps between pipes.
]]
function PlayState:randomHorizontalGap()
    local score = self.score ~= nil and self.score or 0
    local temp = math.min(score / 8, 5) + 1
    local gap = 1.8 + 1 / temp + 2 * math.random()
    return gap
end
