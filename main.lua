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
end

function love.update(dt)
    -- movimento do jogador 1, no eixo Y pra cima e negativo e para baixo e positivo
    if(love.keyboard.isDown("w")) then
        player1Y = player1Y - PADDLE_SPEED * dt
    elseif (love.keyboard.isDown("s")) then
        player1Y = player1Y + PADDLE_SPEED * dt
    end

    -- movimento do jogador 2
    if(love.keyboard.isDown("up")) then
        player2Y = player2Y - PADDLE_SPEED * dt
    elseif (love.keyboard.isDown("down")) then
        player2Y = player2Y + PADDLE_SPEED * dt
    end
    
end


-- encerrar aplicação
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
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
        VIRTUAL_WIDTH / 2 - 2,
        VIRTUAL_HEIGHT / 2 - 2,
        5,
        5
    )

    push:apply('end')
end