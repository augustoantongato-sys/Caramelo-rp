extends CanvasLayer
## HUD mobile/PC do Caramelo RP.

var health_label: Label
var money_label: Label
var wanted_label: Label
var message_label: Label
var ammo_label: Label
var crosshair: Label
var player_ref: Node

func _ready() -> void:
    layer = 30
    _build_hud()
    GameState.stats_changed.connect(_refresh_stats)
    GameState.message_changed.connect(_show_message)
    _refresh_stats()

func _label(text: String, pos: Vector2, size: Vector2, font_size: int, color := Color.WHITE) -> Label:
    var l := Label.new()
    l.text = text
    l.position = pos
    l.size = size
    l.add_theme_font_size_override("font_size", font_size)
    l.add_theme_color_override("font_color", color)
    l.add_theme_color_override("font_shadow_color", Color(0,0,0,0.85))
    l.add_theme_constant_override("shadow_offset_x", 2)
    l.add_theme_constant_override("shadow_offset_y", 2)
    add_child(l)
    return l

func _build_hud() -> void:
    var panel := ColorRect.new()
    panel.position = Vector2(18,18)
    panel.size = Vector2(250,112)
    panel.color = Color(0.025,0.035,0.045,0.72)
    add_child(panel)
    health_label = _label("VIDA 100",Vector2(32,28),Vector2(220,24),20,Color(0.45,1.0,0.62))
    money_label = _label("R$ 2.500",Vector2(32,57),Vector2(220,24),19,Color(1.0,0.84,0.35))
    wanted_label = _label("PROCURADO: ☆☆☆☆☆",Vector2(32,86),Vector2(230,24),16,Color(1.0,0.48,0.38))
    ammo_label = _label("MUNIÇÃO: --",Vector2(0,0),Vector2(190,28),18)
    ammo_label.anchor_left = 1.0
    ammo_label.anchor_right = 1.0
    ammo_label.position = Vector2(-215,24)
    message_label = _label("",Vector2(0,0),Vector2(520,38),18,Color(1.0,0.92,0.62))
    message_label.anchor_left = 0.5
    message_label.anchor_right = 0.5
    message_label.position = Vector2(-260,92)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    crosshair = _label("+",Vector2(0,0),Vector2(32,32),28,Color(1,1,1,0.9))
    crosshair.anchor_left = 0.5
    crosshair.anchor_right = 0.5
    crosshair.anchor_top = 0.5
    crosshair.anchor_bottom = 0.5
    crosshair.position = Vector2(-16,-16)
    var title := _label("CARAMELO RP",Vector2(0,18),Vector2(250,28),18,Color(1,1,1,0.82))
    title.anchor_left = 1.0
    title.anchor_right = 1.0
    title.position.x = -270

func _refresh_stats() -> void:
    if not is_instance_valid(health_label):
        return
    health_label.text = "VIDA  %d / %d" % [roundi(GameState.health),roundi(GameState.max_health)]
    money_label.text = "R$  %s" % _format_money(GameState.money)
    var stars := ""
    for i in range(5):
        stars += "★" if i < GameState.wanted_level else "☆"
    wanted_label.text = "PROCURADO  " + stars

func _format_money(value: int) -> String:
    var s := str(value)
    var out := ""
    for i in range(s.length()):
        out += s[i]
        if (s.length()-i-1) % 3 == 0 and i < s.length()-1:
            out += "."
    return out

func _show_message(value: String) -> void:
    if is_instance_valid(message_label):
        message_label.text = value

func set_ammo(current: int, total: int, weapon_name: String) -> void:
    if is_instance_valid(ammo_label):
        ammo_label.text = "%s  %d / %d" % [weapon_name.to_upper(),current,total]
