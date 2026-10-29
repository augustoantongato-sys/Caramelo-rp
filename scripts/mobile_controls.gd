extends CanvasLayer
## Controles básicos de toque para a versão Android.

func _ready() -> void:
    layer = 20
    _add_hold_button("↑", "move_forward", Vector2(112, -190), Vector2(76, 68))
    _add_hold_button("↓", "move_back", Vector2(112, -42), Vector2(76, 68))
    _add_hold_button("←", "move_left", Vector2(36, -116), Vector2(68, 68))
    _add_hold_button("→", "move_right", Vector2(184, -116), Vector2(68, 68))
    _add_hold_button("CORRER", "sprint", Vector2(40, -265), Vector2(112, 54))
    _add_hold_button("PULAR", "jump", Vector2(-205, -205), Vector2(100, 62))
    _add_hold_button("ATIRAR", "shoot", Vector2(-95, -125), Vector2(100, 62))
    _add_hold_button("AÇÃO", "melee", Vector2(-95, -55), Vector2(100, 58))
    _add_hold_button("ALGEMAR", "arrest", Vector2(-205, -55), Vector2(100, 58))
    _add_hold_button("ENTRAR / SAIR", "interact", Vector2(-205, -275), Vector2(150, 58))

func _add_hold_button(label_text: String, action: String, offset: Vector2, size: Vector2) -> void:
    var button := Button.new()
    button.text = label_text
    button.custom_minimum_size = size
    button.size = size
    button.anchor_left = 1.0 if offset.x < 0 else 0.0
    button.anchor_right = button.anchor_left
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    button.position = offset
    button.modulate = Color(1, 1, 1, 0.82)
    button.add_theme_font_size_override("font_size", 17)
    add_child(button)
    button.button_down.connect(_press_action.bind(action))
    button.button_up.connect(_release_action.bind(action))

func _press_action(action: String) -> void:
    Input.action_press(action)

func _release_action(action: String) -> void:
    Input.action_release(action)
