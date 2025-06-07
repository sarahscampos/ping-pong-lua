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

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- velocidade da raquete sera multiplicada pelo deltatime
PADDLE_SPEED = 200

--inicializa o jogo
function love.load()

    love.graphics.setDefaultFilter("nearest", "nearest")

    -- seed aleatória usando os segundos desde 1 janeiro de 1970
    math.randomseed(os.time())
    
    --fonte retro
    smallFont = love.graphics.newFont("font.ttf", 8)

    scoreFont = love.graphics.newFont("font.ttf", 32)

    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    player1Score = 0
    player2Score = 0
    
    -- posicao das raquetes no eixo Y
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50

    -- posicao da bola no eixo X e Y
    ballX = VIRTUAL_WIDTH / 2 - 2
    ballY = VIRTUAL_HEIGHT / 2 - 2

    -- velocidade da bola no eixo X e Y
    ballDX = math.random(2) == 1 and 100 or -100
    ballDY = math.random(-50, 50)

    gameState = "start"

end

function love.update(dt)
    -- movimento do jogador 1, no eixo Y pra cima e negativo e para baixo e positivo
    if(love.keyboard.isDown("w")) then
        -- garante que a raquete nao saia da tela
        player1Y = math.max(0, player1Y - PADDLE_SPEED * dt)
    elseif (love.keyboard.isDown("s")) then
        -- garante que a raquete nao saia da tela
        player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
    end

    -- movimento do jogador 2
    if(love.keyboard.isDown("up")) then
        player2Y = math.max(0, player2Y - PADDLE_SPEED * dt)
    elseif (love.keyboard.isDown("down")) then
        player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
    end

    if gameState == "play" then
        -- movimento da bola, a multiplacacao por dt é para ser independente do da taxa de quadros
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end
    
end


-- encerrar aplicação
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "enter" or key == "return" then
        if gameState == "start" then
            gameState = "play"
        else
            gameState = "start"
            -- bola inicia no centro da tela
            ballX = VIRTUAL_WIDTH / 2 - 2
            ballY = VIRTUAL_HEIGHT / 2 - 2
            -- bola inicia com uma velocidade aleatoria
            ballDX = math.random(2) == 1 and 100 or -100
            ballDY = math.random(-50, 50) * 1.5
        end
    end
end

--usado para exibir qualquer coisa na tela
function love.draw()
    push:apply('start')

    --cor da tela
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)
    love.graphics.printf(
        "PONG",
        0,
        20,
        VIRTUAL_WIDTH,
        "center"
    )

    love.graphics.setFont(scoreFont)
    --renderiza placar
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    --renderiza primeira raquete (esquerda)
    love.graphics.rectangle(
        "fill",
        10,
        player1Y,
        5,
        20
    )

    --renderiza segunda raquete (direita)
    love.graphics.rectangle(
        "fill",
        VIRTUAL_WIDTH - 10,
        player2Y,
        5,
        20
    )

    --renderiza bola (centro)
    love.graphics.rectangle(
        "fill",
        ballX,
        ballY,
        5,
        5
    )

    push:apply('end')
end