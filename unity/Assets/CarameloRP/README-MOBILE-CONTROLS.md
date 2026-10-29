# Caramelo RP — controles mobile e interação

## Controles de veículos
1. Adicione `CarameloVehicleInputAdapter` ao mesmo GameObject que contém `CarameloArcadeVehicle`.
2. Crie cinco botões UI no Canvas: acelerar, ré, esquerda, direita e freio.
3. Adicione `CarameloVehicleHoldButton` a cada botão e selecione a ação correspondente no Inspector.
4. Cada botão precisa de um componente Graphic (por exemplo, Image) com **Raycast Target** ativado.
5. A cena precisa de um EventSystem e de um GraphicRaycaster no Canvas.

Os botões funcionam enquanto o dedo estiver pressionado. No Editor/PC, também são aceitos W/S ou setas, A/D ou setas e Espaço para frear.

## Interação com objetos
1. Adicione um Collider ao objeto e o componente `CarameloInteractable`.
2. Edite o texto `Prompt` e configure o evento `On Interact` no Inspector.
3. Adicione `CarameloInteractionRaycaster` ao jogador ou a um objeto de controle.
4. Arraste a câmera do jogador para `Player Camera`, o jogador para `Actor` e um componente UI Text para `Prompt Label`.
5. Crie um botão de toque “INTERAGIR” e conecte seu evento OnClick a `CarameloInteractionRaycaster.Interact()`.

No PC, a tecla E executa a interação. Em Android, o botão da interface executa a mesma ação.

## Limites desta etapa
- Os controles de veículo enviam comandos ao controlador arcade existente; ainda não implementam entrada/saída automática de veículos.
- As interações executam os UnityEvents configurados no Inspector. Portas, lojas, garagens e missões precisam ser configuradas como ações próprias.
- É necessário testar os componentes dentro da cópia completa do SanAndreasUnity e ajustar referências na cena. Nenhum APK foi compilado nesta etapa.