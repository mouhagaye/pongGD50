push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()

    love.graphics.setDefaultFilter('nearest','nearest')
    smallFont = love.graphics.newFont('font.ttf',8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    love.window.setTitle('Pong 2.0')

    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT, WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 30,5,20)
    player2 = Paddle(VIRTUAL_WIDTH - 10,VIRTUAL_HEIGHT-30,5,20)


    ball = Ball(VIRTUAL_WIDTH / 2 - 2 ,VIRTUAL_HEIGHT / 2 - 2,4,4)
    

    gameState = 'start'
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static') ,
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static') 
    }
end

function love.resize(w,h)
    push:resize(w,h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
            ball:reset()
        else 
            gameState = 'start'
            ball:reset()
        end
    end
end

function love.update(dt)

    if love.keyboard.isDown('w') then 
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then 
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then 
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then 
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end


    if ball.x > VIRTUAL_WIDTH then
        sounds.score:play()
        player1Score= player1Score + 1
        playerServe = 1
        if player1Score == 10 then
            winnigPlayer = 1
            gameState = 'gameOver'
        else
            gameState = 'serve'
        end
        ball:reset()
    end
    if ball.x < 0 then
        sounds.score:play()
        playerServe = 2
        player2Score = player2Score + 1
        if player2Score == 10 then
            winnigPlayer = 2
            gameState = 'gameOver'
        else
            gameState = 'serve'
        end
        ball:reset()
    end
    if gameState =='serve' then
        ball.dy = math.random(-50,50)
        if playerServe == 1 then
            ball.dx = math.random(140, 200)
            gameState = 'play'
        else
            ball.dx = -math.random(140, 200)
            gameState = 'play'
        end
    elseif gameState == 'play' then

        if ball:collides(player1) then
            sounds.paddle_hit:play()
            ball.dx = -ball.dx*1.03
            ball.x = player1.x + 5
            if ball.dy < 0 then
                ball.dy = -math.random(10,100)
            else
                ball.dy = math.random(10,100)
            end
        end
        if ball:collides(player2) then
            sounds.paddle_hit:play()
            ball.dx = -ball.dx*1.03
            ball.x = player2.x - 4
            if ball.dy < 0 then
                ball.dy = -math.random(10,100)
            else
                ball.dy = math.random(10,100)
            end
        end
    end

    if ball.y <= 0 then
        sounds.wall_hit:play()
        ball.y = 4
        ball.dy = -ball.dy*1.02
    end
    if ball.y >= VIRTUAL_HEIGHT then
        sounds.wall_hit:play()
        ball.y = VIRTUAL_HEIGHT - 4
        ball.dy = -ball.dy*1.04
    end
    if gameState == 'start' or gameState == 'gameOver'  then
        ball.dx = 0
        ball.dy = 0
    end
    ball:update(dt)
    player1:update(dt)
    player2:update(dt)

end
        
function love.draw()
    push:apply('start')

    love.graphics.clear(40, 45, 52, 255)
    love.graphics.setColor(255,255,255,100)
    for i = 0 , VIRTUAL_HEIGHT , 15
    do
        love.graphics.rectangle('fill',VIRTUAL_WIDTH / 2,i,2,10) 
    end
    love.graphics.setColor(255,255,255,255)
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf('Hello Pong !\nPress Enter', 0, 20, VIRTUAL_WIDTH, 'center')
        resetScore()
    end
    if gameState == 'play' then
        love.graphics.printf('Game Started !', 0, 20, VIRTUAL_WIDTH, 'center')
    end
    if gameState == 'serve' then
        love.graphics.printf('Point ! player '.. tostring(playerServe) ..' serves .', 0, 20, VIRTUAL_WIDTH, 'center')
    end
    if gameState == 'gameOver' then
        love.graphics.printf('Victory ! player '.. tostring(winnigPlayer) ..' Win .\n Congratulation.\nPress Enter to Restart ', 0, 20, VIRTUAL_WIDTH, 'center')
    end
    


    love.graphics.setFont(scoreFont)
    
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2-50 , VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2+30 , VIRTUAL_HEIGHT/3)

    player1:render()
    player2:render()
    ball:render()
    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,255,0,255)
    love.graphics.print('FPS: '..tostring(love.timer.getFPS()),10, 10)
end
function resetScore()
    player1Score = 0
    player2Score = 0
end