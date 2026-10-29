# CARAMELO RP

**Mundo aberto 3D • Brasil contemporâneo • Android • Offline**

Caramelo RP é um projeto independente de mundo aberto em terceira pessoa, ambientado em uma cidade brasileira fictícia inspirada na diversidade urbana de São Paulo. A direção é buscar escala, atmosfera e liberdade de exploração de um grande jogo de mundo aberto, com identidade visual própria e otimização para celulares Android.

> **Estado honesto:** protótipo em desenvolvimento. Os sistemas e cenários atuais são majoritariamente procedurais e ainda precisam de validação visual, física e de desempenho em aparelho real. Não é um jogo AAA pronto.

## Visão do jogo

- Cidade brasileira com centro urbano, bairros residenciais, comércio, periferia e comunidade em morro.
- Exploração livre em câmera de terceira pessoa.
- Personagem, pedestres, trânsito e veículos dirigíveis.
- Atividades, missões, empregos, economia e propriedades.
- Polícia, serviços públicos e sistema de territórios em evolução.
- Experiência individual/offline, com controles para Android.

## Estrutura do projeto

```
Caramelo-rp/
├── .github/workflows/       # automação de validação e exportação
├── assets/
│   ├── audio/               # sons originais/licenciados
│   ├── materials/           # materiais e texturas
│   ├── models/              # modelos 3D
│   ├── ui/                  # ícones e elementos da interface
│   └── references/          # referências de produção, não usadas no jogo
├── docs/                    # visão, direção de arte e planejamento
├── scenes/                  # cenas Godot
├── scripts/                 # lógica GDScript
├── project.godot
└── export_presets.cfg
```

## Abrir no Godot

1. Instale Godot **4.3**.
2. Baixe o repositório em **Code → Download ZIP** ou clone:
   `git clone https://github.com/augustoantongato-sys/Caramelo-rp.git`
3. Extraia o ZIP e abra `project.godot` pelo Godot Project Manager.
4. Aguarde a importação de recursos e execute a cena principal.

## Controles já previstos

| Ação | PC |
|---|---|
| Movimento | WASD / setas |
| Pular | Espaço |
| Correr | Shift |
| Interagir / entrar ou sair de veículo | E |
| Mirar e disparar | Mouse |
| Recarregar | R |
| Salvar / carregar | F5 / F9 |

Os controles móveis são apresentados na interface do jogo. A disposição e a resposta tátil ainda precisam de testes em aparelhos Android.

## Sistemas já presentes no protótipo

- Cena principal e personagem controlável.
- Cidade procedural com avenida, prédios, casas, morro, comércio e marcos públicos.
- Detalhes de rua, veículos de cenário, pedestres e skyline procedural.
- Veículos dirigíveis e serviços de emergência em versão inicial.
- HUD, vida, dinheiro, respeito, nível de procurado e munição.
- Missões, empregos, propriedades, salvamento local e sistema de territórios em desenvolvimento.

Consulte [o planejamento](docs/ROADMAP.md) para separar o que existe, o que precisa ser melhorado e o que ainda não foi implementado.

## Android

O preset Android está em `export_presets.cfg`. Para exportar localmente, instale os templates de exportação da mesma versão do Godot, configure JDK e Android SDK no Editor Settings e gere primeiro um APK de depuração. A automação do GitHub Actions está em evolução; um workflow verde e um APK gerado são necessários antes de considerar a compilação validada.

## Padrão de qualidade e direitos

- Priorizar desempenho consistente em Android antes de aumentar densidade gráfica.
- Usar modelos, texturas, sons e fontes originais ou com licença compatível.
- Não incluir marcas, personagens, mapas ou ativos proprietários de terceiros sem autorização.
- A inspiração em jogos de mundo aberto é de qualidade e estrutura; **Caramelo RP tem universo e identidade próprios**.

Caramelo RP é independente e não é afiliado, patrocinado ou endossado pela Rockstar Games.
