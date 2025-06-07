# Pong em Lua com LÖVE2D 🏓

Este projeto é uma recriação do clássico jogo **Pong**, originalmente lançado pela Atari em 1972. Foi desenvolvido como uma implementação prática da disciplina **Arquitetura de Linguagens de Programação**, utilizando a linguagem **Lua** e o framework **LÖVE2D**.

## Sobre o Jogo

O jogo consiste em duas raquetes controladas pelos jogadores com o objetivo de rebater uma bola e marcar pontos quando ela passa pela raquete do oponente. O primeiro jogador a alcançar **10 pontos vence**.

Esta versão foi adaptada para se assemelhar visualmente aos jogos do **NES**, com resolução baixa e estilo retrô, mas em formato *widescreen* (16:9).
![image](https://github.com/user-attachments/assets/08cd1e8b-ea83-4601-9b1d-6a434de27e54)

## Tecnologias e Recursos Utilizados

- **Lua** como linguagem de programação.
- **LÖVE2D** como framework gráfico e de áudio.
- **push** para renderização em tela com resolução virtual.
- **class.lua** para programação orientada a objetos.
- Sons em `.wav` para interações (batida na parede, raquete e pontuação).
- Suporte ao **lldebugger** para depuração no VSCode.

## Como Jogar

1. Instale **Lua** e **LÖVE2D**.
2. Clone o repositório: ```git clone https://github.com/sarahscampos/ping-pong-lua.git```
### Controles
- **Jogador 1**: W (cima) e S (baixo)
- **Jogador 2**: Seta ↑ (cima) e Seta ↓ (baixo)
- **Enter**: Inicia ou reinicia o jogo
- **Esc**: Sair do jogo
  
<div align="center">
  <img src="https://github.com/user-attachments/assets/a58090f4-6ab9-421a-8310-4c41c7180fa0" alt="gifpong" />
</div>


