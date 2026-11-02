extends Node2D

const AvatarScript = preload("res://scripts/avatar.gd")
const SAVE_PATH := "user://hallways_player.cfg"

var player_name := "Estudiante"
var pronouns := "él"
var skin := Color("#c98e69")
var hair := Color("#49352e")
var shirt := Color("#303b55")
var hair_style := "Corto"
var player: HallwaysAvatar
var player_x := 300.0
var near_npc := false
var dialogue_open := false
var creator_open := true
var npc_line := 0
var touch_left := false
var touch_right := false

var ui: CanvasLayer
var hud_label: Label
var prompt_label: Label
var dialogue_panel: PanelContainer
var creator_panel: PanelContainer
var name_edit: LineEdit
var pronoun_select: OptionButton
var skin_select: OptionButton
var hair_select: OptionButton
var style_select: OptionButton
var shirt_select: OptionButton

var npc_lines := [
    ["Estudiante", "Primer día, ¿no? El pasillo siempre parece más largo cuando no sabes adónde vas.", "¿Dónde estoy?", "Ya me apañaré."],
    ["Estudiante", "Si buscas el aula, creo que es por allí. Creo. No me hagas responsable.", "Gracias.", "No pareces muy seguro."],
    ["Estudiante", "Bueno, nos vemos por ahí. Este sitio es pequeño, pero pasan cosas rarísimas.", "Hasta luego.", "Eso espero."]
]

func _ready() -> void:
    _build_world()
    _build_ui()
    _show_creator()

func _build_world() -> void:
    player = AvatarScript.new()
    player.position = Vector2(player_x, 480)
    add_child(player)
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("#202b3b"))
    draw_rect(Rect2(0, 0, 1280, 390), Color("#344355"))
    for i in range(6):
        var x := i * 230.0 - 30
        draw_rect(Rect2(x, 90, 190, 250), Color("#536274"))
        draw_rect(Rect2(x + 12, 104, 166, 220), Color("#26394c"))
        draw_rect(Rect2(x + 20, 112, 150, 204), Color("#9ca8ae"))
        draw_rect(Rect2(x + 27, 119, 136, 190), Color("#627c8b"))
        draw_rect(Rect2(x + 84, 119, 4, 190), Color("#34495a"))
        draw_rect(Rect2(x + 27, 208, 136, 4), Color("#34495a"))
    draw_rect(Rect2(0, 390, 1280, 330), Color("#a18f7b"))
    draw_rect(Rect2(0, 390, 1280, 14), Color("#d2c1a5"))
    for i in range(12):
        draw_line(Vector2(i * 120, 410), Vector2(i * 120 - 100, 720), Color("#8b7b6a"), 2)
    draw_rect(Rect2(850, 265, 150, 125), Color("#795c4d"))
    draw_rect(Rect2(862, 278, 126, 99), Color("#344b5c"))
    draw_string(ThemeDB.fallback_font, Vector2(870, 252), "AULA 1", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f0e8d9"))
    # NPC provisional de prueba.
    draw_circle(Vector2(930, 354), 18, Color("#bd8868"))
    draw_rect(Rect2(908, 372, 44, 62), Color("#566d55"))
    draw_rect(Rect2(912, 434, 13, 35), Color("#252b34"))
    draw_rect(Rect2(936, 434, 13, 35), Color("#252b34"))
    draw_string(ThemeDB.fallback_font, Vector2(890, 492), "¿Hablar?", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f7e8cf"))

func _build_ui() -> void:
    ui = CanvasLayer.new()
    add_child(ui)
    var top := Label.new()
    top.text = "HALLWAYS  /  PROTOTYPE 0.1"
    top.position = Vector2(24, 18)
    top.add_theme_font_size_override("font_size", 22)
    top.add_theme_color_override("font_color", Color("#f5e9d7"))
    ui.add_child(top)
    hud_label = Label.new()
    hud_label.position = Vector2(24, 54)
    hud_label.add_theme_font_size_override("font_size", 18)
    hud_label.add_theme_color_override("font_color", Color("#f5e9d7"))
    ui.add_child(hud_label)
    prompt_label = Label.new()
    prompt_label.position = Vector2(440, 635)
    prompt_label.size = Vector2(400, 40)
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.add_theme_font_size_override("font_size", 22)
    prompt_label.add_theme_color_override("font_color", Color("#fff2d8"))
    ui.add_child(prompt_label)
    _add_touch_controls()

func _add_touch_controls() -> void:
    # Controles grandes para pantallas táctiles.
    var left_button := Button.new()
    left_button.text = "◀"
    left_button.position = Vector2(28, 570)
    left_button.size = Vector2(104, 104)
    left_button.add_theme_font_size_override("font_size", 38)
    left_button.button_down.connect(func(): touch_left = true)
    left_button.button_up.connect(func(): touch_left = false)
    ui.add_child(left_button)

    var right_button := Button.new()
    right_button.text = "▶"
    right_button.position = Vector2(146, 570)
    right_button.size = Vector2(104, 104)
    right_button.add_theme_font_size_override("font_size", 38)
    right_button.button_down.connect(func(): touch_right = true)
    right_button.button_up.connect(func(): touch_right = false)
    ui.add_child(right_button)

    var action_button := Button.new()
    action_button.text = "HABLAR"
    action_button.position = Vector2(1080, 570)
    action_button.size = Vector2(170, 104)
    action_button.add_theme_font_size_override("font_size", 22)
    action_button.pressed.connect(_touch_interact)
    ui.add_child(action_button)

func _touch_interact() -> void:
    if near_npc and not creator_open and not dialogue_open:
        _open_dialogue()
    elif dialogue_open:
        _close_dialogue()

func _show_creator() -> void:
    creator_panel = PanelContainer.new()
    creator_panel.position = Vector2(390, 75)
    creator_panel.size = Vector2(500, 570)
    ui.add_child(creator_panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 9)
    creator_panel.add_child(box)
    var title := Label.new()
    title.text = "HALLWAYS  |  CREA TU PERSONAJE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 25)
    box.add_child(title)
    var note := Label.new()
    note.text = "Este es tu MC. Jacqueline es otro personaje."
    note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(note)
    name_edit = LineEdit.new()
    name_edit.placeholder_text = "Escribe el nombre"
    box.add_child(_field("Nombre"))
    box.add_child(name_edit)
    pronoun_select = _option(["él", "ella", "elle", "otro / no especificar"])
    box.add_child(_field("Pronombres"))
    box.add_child(pronoun_select)
    skin_select = _option(["Claro", "Medio", "Oscuro"])
    box.add_child(_field("Tono de piel"))
    box.add_child(skin_select)
    hair_select = _option(["Castaño", "Negro", "Rubio", "Pelirrojo", "Azul"])
    box.add_child(_field("Color de pelo"))
    box.add_child(hair_select)
    style_select = _option(["Corto", "Rizado", "Largo"])
    box.add_child(_field("Peinado"))
    box.add_child(style_select)
    shirt_select = _option(["Negro", "Azul", "Rojo", "Verde", "Morado"])
    box.add_child(_field("Camiseta"))
    box.add_child(shirt_select)
    var start := Button.new()
    start.text = "ENTRAR AL INSTITUTO"
    start.custom_minimum_size.y = 48
    start.pressed.connect(_create_character)
    box.add_child(start)

func _field(caption: String) -> Label:
    var label := Label.new()
    label.text = caption
    label.add_theme_font_size_override("font_size", 15)
    return label

func _option(items: Array) -> OptionButton:
    var option := OptionButton.new()
    for item in items:
        option.add_item(item)
    return option

func _create_character() -> void:
    player_name = name_edit.text.strip_edges()
    if player_name.is_empty():
        player_name = "Estudiante"
    pronouns = pronoun_select.get_item_text(pronoun_select.selected)
    skin = [Color("#f0c9a6"), Color("#c98e69"), Color("#80543e")][skin_select.selected]
    hair = [Color("#49352e"), Color("#211e22"), Color("#d5ad54"), Color("#a94f35"), Color("#477ca8")][hair_select.selected]
    hair_style = style_select.get_item_text(style_select.selected)
    shirt = [Color("#25252b"), Color("#354e79"), Color("#9b4141"), Color("#49684e"), Color("#695080")][shirt_select.selected]
    player.skin = skin
    player.hair = hair
    player.shirt = shirt
    player.hair_style = hair_style
    player.queue_redraw()
    creator_panel.queue_free()
    creator_open = false
    _save_character()
    _update_hud()
    prompt_label.text = "A / D o flechas para moverte. E para interactuar."

func _save_character() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("character", "name", player_name)
    cfg.set_value("character", "pronouns", pronouns)
    cfg.set_value("character", "skin", skin.to_html())
    cfg.set_value("character", "hair", hair.to_html())
    cfg.set_value("character", "shirt", shirt.to_html())
    cfg.set_value("character", "hair_style", hair_style)
    cfg.save(SAVE_PATH)

func _update_hud() -> void:
    hud_label.text = "%s  |  %s" % [player_name, pronouns]

func _process(delta: float) -> void:
    if creator_open or dialogue_open:
        return
    var direction := Input.get_axis("ui_left", "ui_right")
    if Input.is_key_pressed(KEY_A) or touch_left:
        direction -= 1.0
    if Input.is_key_pressed(KEY_D) or touch_right:
        direction += 1.0
    direction = clampf(direction, -1.0, 1.0)
    player_x = clampf(player_x + direction * 260.0 * delta, 40.0, 1240.0)
    player.position.x = player_x
    player.scale.x = -1 if direction < 0 else 1
    near_npc = absf(player_x - 930.0) < 95.0
    prompt_label.text = "E  ·  Hablar" if near_npc else "A / D o flechas para moverte"

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_E and near_npc and not creator_open and not dialogue_open:
            _open_dialogue()
        elif event.keycode == KEY_ESCAPE and dialogue_open:
            _close_dialogue()

func _open_dialogue() -> void:
    dialogue_open = true
    var data: Array = npc_lines[npc_line]
    dialogue_panel = PanelContainer.new()
    dialogue_panel.position = Vector2(300, 485)
    dialogue_panel.size = Vector2(680, 170)
    ui.add_child(dialogue_panel)
    var box := VBoxContainer.new()
    dialogue_panel.add_child(box)
    var who := Label.new()
    who.text = data[0]
    who.add_theme_font_size_override("font_size", 18)
    box.add_child(who)
    var line := Label.new()
    line.text = data[1]
    line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(line)
    for i in range(2):
        var choice := Button.new()
        choice.text = str(data[i + 2])
        choice.pressed.connect(_choose_dialogue.bind(i))
        box.add_child(choice)

func _choose_dialogue(_choice: int) -> void:
    npc_line = (npc_line + 1) % npc_lines.size()
    _close_dialogue()
    prompt_label.text = "Respuesta guardada en esta sesión."

func _close_dialogue() -> void:
    if is_instance_valid(dialogue_panel):
        dialogue_panel.queue_free()
    dialogue_open = false
