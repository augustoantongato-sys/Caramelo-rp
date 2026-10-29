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
- [x] Protótipos de NPCs, missões, economia e territórios em desenvolvimento.
- [x] Dez modelos visuais estilizados de equipamentos com formas arredondadas e seleção por teclado.
- [x] Ambientação ampliada: pedestres decorativos, carros de cenário, moto, bicicleta, hatch de serviço com escada no teto, postes, abrigo de ônibus e skyline urbano.
- [x] Serviços públicos de cenário: policiais com uniforme tático inspirado em patrulhamento especial, bombeiros, profissionais de saúde, viaturas, SUVs e vans blindadas, caminhões de bombeiros e ambulância SAMU estilizada.
- [x] Detalhes adicionais na favela: caixas d'água elevadas e vergalhões aparentes nas lajes.
- [x] Personagem procedural com braços e pernas separados, animação simples de caminhada/corrida e pose de mira.
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
| Selecionar pistola, revólver, rifle de precisão, submetralhadora, fuzil, metralhadora ou espingarda | 4, 5, 6, 7, 8, 9, 0 |
| Selecionar machado, faca ou algemas | Z, X, C |
| Disparar | Botão esquerdo do mouse / ação configurada |
| Faca / algemas (ações existentes) | F / G, conforme configuração de entrada |

## Exportar para Android

1. No Godot, instale os **Export Templates** da mesma versão do editor.
2. Configure o Android SDK, JDK e as ferramentas exigidas pela documentação oficial do Godot.
3. Em **Project → Export**, adicione o preset **Android**.
4. Configure identificador do pacote, orientação e ícone.
5. Exporte primeiro um APK de depuração e teste em um aparelho real.

A exportação Android ainda precisa de validação e otimização em aparelhos reais. Os veículos e profissionais de emergência adicionados nesta etapa são modelos decorativos de cenário; não são dirigíveis nem possuem IA ou missões funcionais ainda.

## Direção do projeto

A primeira meta é uma pequena área explorável com movimentação em terceira pessoa. Depois serão adicionados, em etapas, veículos, personagens não jogáveis, atividades, sistema de dinheiro, polícia e missões.

## Tecnologias

- Godot Engine 4.x
- GDScript
- 3D com renderer Compatibility

## Aviso

Caramelo RP é um projeto independente e não é afiliado à Rockstar Games.