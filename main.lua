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

--inicializa o jogo
function love.load()

    love.graphics.setDefaultFilter("nearest", "nearest")

    --fonte retro
    smallFont = love.graphics.newFont("font.ttf", 8)
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
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


    love.graphics.printf(
        "Pong :)",
        0,
        20,
        VIRTUAL_WIDTH,
        "center"
    )

    --renderiza primeira raquete (esquerda)
    love.graphics.rectangle(
        "fill",
        10,
        30,
        5,
        20
    )

    --renderiza segunda raquete (direita)
    love.graphics.rectangle(
        "fill",
        VIRTUAL_WIDTH - 10,
        VIRTUAL_HEIGHT - 30,
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