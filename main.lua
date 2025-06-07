if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end
--[[
    Originalmente programado pela Atari em 1972. 
    Apresenta duas raquetes, controladas pelos jogadores, com o objetivo de fazer a bola passar pela borda do oponente. 
    O primeiro a alcançar 10 pontos vence.

    Esta versão foi construída para se assemelhar mais ao NES do que às máquinas originais de Pong ou ao Atari 2600 em termos de resolução, 
    embora em formato widescreen (16:9), para que fique mais agradável em sistemas modernos.
]]

push = require "push"

Class = require "class"

require "Paddle"
require "Ball"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- velocidade da raquete sera multiplicada pelo deltatime
PADDLE_SPEED = 200

--inicializa o jogo
function love.load()

    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setTitle("Pong")

    -- seed aleatória usando os segundos desde 1 janeiro de 1970
    math.randomseed(os.time())
    
    --fonte retro
    smallFont = love.graphics.newFont("font.ttf", 8)
    largeFont = love.graphics.newFont("font.ttf", 16)
    scoreFont = love.graphics.newFont("font.ttf", 32)

    -- tabela para sons
    sounds = {
        ["paddle_hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
        ["score"] = love.audio.newSource("sounds/score.wav", "static"),
        ["wall_hit"] = love.audio.newSource("sounds/wall_hit.wav", "static")
    }

    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    player1Score = 0
    player2Score = 0

    -- comeca com 1, mas depois e determinado pelo jogador que pontuou
    servingPlayer = 1
    
    -- inicializa as raquetes
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- posiciona a bola no meio da tela
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- estado do jogo
    gameState = "start"

    

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    -- antes de mudar para play, inicializa a velocidade da bola baseada no jogador que pontuou por ultimo
    if gameState == "serve" then
        ball.dy = math.random(-50,50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == "play" then
        -- detecta a colisao da bola com as raquetes e inverte o dx se verdadedeiro alem de aumentar um pouco sua velocidade
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.05
            ball.x = player1.x + 5 -- evita que detecte multiplas colisoes
            -- mantem a direcao e sentido da bola
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.05
            ball.x = player2.x - 4 -- evita que detecte multiplas colisoes

            -- mantem a direcao e sentido da bola
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end

        -- detecta limites superior e inferior (eixo y) da tela e inverte o dy se colidir
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- 4 por causa do tamanho da bola
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        
        -- se alcanca os limites esquerdo ou direito da tela, reseta a posicao da bola e atualiza o placar
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()
            if player2Score == 10 then
                winningPlayer = 2
                gameState = "done"
            else
                ball:reset()
                gameState = "serve"
            end
        end
    
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
    
            if player1Score == 10 then
                winningPlayer = 1
                gameState = "done"
            else
                ball:reset()
                gameState = "serve"
            end
        end
    end

    -- movimento do jogador 1, no eixo Y pra cima e negativo e para baixo e positivo
    if(love.keyboard.isDown("w")) then
        player1.dy = -PADDLE_SPEED
    elseif (love.keyboard.isDown("s")) then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- movimento do jogador 2
    if(love.keyboard.isDown("up")) then
         player2.dy = -PADDLE_SPEED
    elseif (love.keyboard.isDown("down")) then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == "play" then
        -- movimento da bola, a multiplacacao por dt é para ser independente do da taxa de quadros
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
    
end


function love.keypressed(key)
    -- encerrar aplicação
    if key == "escape" then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- jogo reseta
            player1Score = 0
            player2Score = 0

            ball:reset()
            
            gameState = 'serve'

            -- decide quem ira sacar, sendo quem perdeu na ultima rodada
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

--usado para exibir qualquer coisa na tela
function love.draw()
    push:apply('start')

    --cor da tela
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    if gameState == 'start' then 
        love.graphics.setFont(smallFont)
        love.graphics.printf(
            "PONG",
            0,
            20,
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.printf(
            "Pressione Enter para iniciar!",
            0,
            30,
            VIRTUAL_WIDTH,
            "center"
        )
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf(
            "Saque do Player " .. tostring(servingPlayer) .. "!",
            0,
            10,
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.printf(
            "Pressione Enter para sacar!",
            0,
            20,
            VIRTUAL_WIDTH,
            "center"
        )

    elseif gameState == "play" then
        -- nao faz nada
    elseif gameState == "done" then
        love.graphics.setFont(largeFont)
        love.graphics.printf(
            "Player " .. tostring(winningPlayer) .. " ganhou!",
            0,
            10,
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.setFont(smallFont)
        love.graphics.printf(
            "Pressione Enter para jogar novamente!",
            0, 
            30,
            VIRTUAL_WIDTH,
            "center"
        )
    end

    displayScore()

    --renderiza primeira raquete (esquerda)
    player1:render()

    --renderiza segunda raquete (direita)
    player2:render()

    --renderiza bola (centro)
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    --renderiza placar
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end