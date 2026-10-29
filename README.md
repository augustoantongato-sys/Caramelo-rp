# Caramelo RP

**Caramelo RP** é um jogo de mundo aberto 3D para Android, inspirado no estilo de jogos GTA RP, ambientado em uma cidade brasileira fictícia.

> Projeto em desenvolvimento. Esta versão é um protótipo inicial em Godot 4; ainda não é um APK final.

## Estado atual

- [x] Projeto Godot 4 configurado com renderização Compatibility, adequada para testar em dispositivos móveis.
- [x] Primeiro bairro gerado por código: avenida, calçadas, prédios, casas em morro, bar, mercadinho e postes.
- [x] Personagem 3D controlável com câmera em terceira pessoa.
- [x] Movimento de caminhada, corrida e pulo por teclado.
- [ ] Controles de toque e interface mobile.
- [ ] Veículos dirigíveis.
- [ ] NPCs, empregos, missões e economia.
- [ ] Salvamento de progresso.
- [ ] Exportação e testes do APK Android.

## Estrutura

```
Caramelo-rp/
├── project.godot
├── scenes/
│   ├── main.tscn
│   └── player.tscn
├── scripts/
│   ├── city.gd
│   └── player.gd
└── (referências visuais e recursos enviados ao repositório)
```

## Abrir o projeto

1. Instale o **Godot Engine 4.x** (a configuração atual foi criada para Godot 4.3).
2. Baixe o repositório pelo botão **Code → Download ZIP** ou clone:
   `git clone https://github.com/augustoantongato-sys/Caramelo-rp.git`
3. Abra o Godot Project Manager e importe a pasta do projeto selecionando `project.godot`.
4. Execute a cena principal com **F6/F5** ou o botão Play.

## Controles atuais (PC)

| Ação | Tecla |
|---|---|
| Andar | W, A, S, D ou setas |
| Pular | Espaço |
| Correr | Shift |
| Câmera | Movimento do mouse |
| Liberar/capturar mouse | Esc / clique |

## Exportar para Android

1. No Godot, instale os **Export Templates** da mesma versão do editor.
2. Configure o Android SDK, JDK e as ferramentas exigidas pela documentação oficial do Godot.
3. Em **Project → Export**, adicione o preset **Android**.
4. Configure identificador do pacote, orientação e ícone.
5. Exporte primeiro um APK de depuração e teste em um aparelho real.

A exportação Android ainda precisa de validação e otimização em aparelhos reais. Os controles de toque serão adicionados antes de considerar a versão mobile pronta.

## Direção do projeto

A primeira meta é uma pequena área explorável com movimentação em terceira pessoa. Depois serão adicionados, em etapas, veículos, personagens não jogáveis, atividades, sistema de dinheiro, polícia e missões.

## Tecnologias

- Godot Engine 4.x
- GDScript
- 3D com renderer Compatibility

## Aviso

Caramelo RP é um projeto independente e não é afiliado à Rockstar Games.