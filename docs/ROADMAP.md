# Caramelo RP — planejamento de produção

## Direção do produto

Jogo 3D de mundo aberto, offline e focado em Android. A cidade deve transmitir Brasil contemporâneo: avenidas movimentadas, comércio de bairro, conjuntos residenciais, comunidade em morro, equipamentos públicos, áreas verdes e um centro urbano verticalizado.

## Fases

### Fase 1 — Base técnica e protótipo jogável
- [x] Projeto Godot 4.3 e cena principal.
- [x] Personagem e câmera em terceira pessoa em versão inicial.
- [x] Cidade procedural inicial.
- [x] HUD e controles móveis iniciais.
- [x] Protótipos de veículos, NPCs, empregos e salvamento.
- [ ] Validar abertura e execução no Godot 4.3 sem erros.
- [ ] Validar colisões, câmera, interação e salvamento em sessão real.

### Fase 2 — Vertical slice de um bairro
- [ ] Definir escala métrica, quadras, calçadas e cruzamentos.
- [ ] Trocar blocos provisórios por módulos arquitetônicos reutilizáveis.
- [ ] Criar fachadas, telhados, portas, vitrines, sinalização e iluminação coerentes.
- [ ] Criar um pequeno bairro completo com início, objetivo e retorno.
- [ ] Criar fluxo de pedestres e tráfego com limites de quantidade e distância.
- [ ] Adicionar áudio ambiente original/licenciado.

### Fase 3 — Sistemas de jogo
- [ ] Refinar dirigir, entrar/sair, câmera e colisões dos veículos.
- [ ] Interações com NPCs e pontos de serviço.
- [ ] Missões com objetivos, checkpoints e recompensas.
- [ ] Economia, lojas, garagem e propriedades persistentes.
- [ ] Polícia, procurado e serviços de emergência com comportamento consistente.

### Fase 4 — Mundo e conteúdo
- [ ] Expandir por bairros conectados e pontos de interesse.
- [ ] Criar interiores selecionados e atividades.
- [ ] Adicionar variação de clima/horário se o orçamento de desempenho permitir.
- [ ] Criar personagens, roupas e veículos originais.

### Fase 5 — Android e lançamento
- [ ] Perfil de qualidade baixo/médio/alto.
- [ ] LOD, oclusão, limites de NPCs e tráfego, carregamento por região.
- [ ] Testes em aparelhos de entrada e intermediários.
- [ ] Corrigir consumo de memória, aquecimento e travamentos.
- [ ] Testar APK de depuração em aparelho físico.
- [ ] Preparar ícone, tela inicial, créditos, política de privacidade e pacote final.

## Critérios de aceite

Uma fase só é marcada como concluída quando:
1. O projeto importa no Godot 4.3 sem erros.
2. A funcionalidade pode ser executada e repetida.
3. Não há regressão conhecida em controles, colisões ou salvamento.
4. A versão Android é medida em aparelho real antes de aumentar a carga gráfica.

## Regra de escopo

Não prometer qualidade AAA apenas com geometria procedural simples. A meta é construir uma fatia vertical polida, com arte e sistemas consistentes, e expandir depois. Priorizar identidade brasileira, legibilidade, estabilidade e desempenho.
