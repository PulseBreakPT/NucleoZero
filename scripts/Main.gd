extends Control

const Data := preload("res://scripts/GameData.gd")
const BG := Color("#091320")
const PANEL := Color("#14273b")
const BORDER := Color("#325069")
const CYAN := Color("#61e5df")
const GOLD := Color("#f4c273")
const WHITE := Color("#f0f9ff")
const MUTED := Color("#9db5c7")
var game: GameData
var page: int = 0
var frame: VBoxContainer
var scroll: ScrollContainer
var content: VBoxContainer
var message: Label
var stats: HBoxContainer
var tick: float = 0.0
var click_count: int = 0

func _ready() -> void:
    game = Data.new()
    game.load_save()
    _shell()
    _refresh()
    if game.offline_capsules > 0:
        _notify("Enquanto estiveste fora, o reator criou %d cápsulas." % game.offline_capsules)

func _notification(what: int) -> void:
    if game != null and (what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_FOCUS_OUT):
        game.save_game()

func _exit_tree() -> void:
    if game != null:
        game.save_game()

func _process(delta: float) -> void:
    if game == null:
        return
    var earned: int = game.passive(delta)
    tick += delta
    if earned > 0 or tick > 2.0:
        tick = 0.0
        if page == 0:
            _refresh()

func _style(fill: Color, edge: Color = BORDER, radius: int = 22) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = fill
    s.border_color = edge
    s.set_border_width_all(2)
    s.set_corner_radius_all(radius)
    s.content_margin_left = 16
    s.content_margin_right = 16
    s.content_margin_top = 12
    s.content_margin_bottom = 12
    return s

func _label(value: String, font_size: int = 25, color: Color = WHITE, center: bool = false) -> Label:
    var l := Label.new()
    l.text = value
    l.add_theme_font_size_override("font_size",font_size)
    l.add_theme_color_override("font_color",color)
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if center else HORIZONTAL_ALIGNMENT_LEFT
    l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return l

func _button(value: String, color: Color, callback: Callable, height: float = 72.0) -> Button:
    var b := Button.new()
    b.text = value
    b.custom_minimum_size = Vector2(0,height)
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_font_size_override("font_size",25)
    b.add_theme_color_override("font_color",BG)
    b.add_theme_color_override("font_hover_color",BG)
    b.add_theme_color_override("font_pressed_color",BG)
    b.add_theme_stylebox_override("normal",_style(color))
    b.add_theme_stylebox_override("hover",_style(color.lightened(0.12),CYAN))
    b.add_theme_stylebox_override("pressed",_style(color.darkened(0.20),GOLD))
    b.pressed.connect(callback)
    return b

func _space(height: float = 12.0) -> Control:
    var c := Control.new()
    c.custom_minimum_size = Vector2(0,height)
    return c

func _card() -> VBoxContainer:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel",_style(PANEL))
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",14)
    panel.add_child(box)
    content.add_child(panel)
    return box

func _shell() -> void:
    var background := TextureRect.new()
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.texture = preload("res://assets/atmosphere.svg")
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_SCALE
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left",24)
    margin.add_theme_constant_override("margin_right",24)
    margin.add_theme_constant_override("margin_top",36)
    margin.add_theme_constant_override("margin_bottom",22)
    add_child(margin)
    frame = VBoxContainer.new()
    frame.add_theme_constant_override("separation",18)
    margin.add_child(frame)
    var header := VBoxContainer.new()
    header.add_theme_constant_override("separation",6)
    frame.add_child(header)
    header.add_child(_label("NÚCLEO ZERO",44,CYAN,true))
    header.add_child(_label("PROTOCOLO DE ENERGIA // OFFLINE",17,MUTED,true))
    stats = HBoxContainer.new()
    stats.add_theme_constant_override("separation",10)
    frame.add_child(stats)
    scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    frame.add_child(scroll)
    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation",16)
    scroll.add_child(content)
    message = _label("TOCA NO REATOR PARA COMEÇAR",18,GOLD,true)
    frame.add_child(message)
    var nav := HBoxContainer.new()
    nav.add_theme_constant_override("separation",8)
    frame.add_child(nav)
    var menu := ["REATOR","OFICINA","ARQUIVO","ASCENSÃO"]
    for i in range(menu.size()):
        var idx: int = i
        var button := _button(menu[i], CYAN if idx == page else Color("#7a9aaa"),func(): _change_page(idx),64)
        button.add_theme_font_size_override("font_size",16)
        nav.add_child(button)

func _refresh_stats() -> void:
    for child in stats.get_children():
        stats.remove_child(child)
        child.queue_free()
    for value in ["◉ %d" % game.capsules,"◆ %d" % game.coins,"✦ %d" % game.cores]:
        var pill := PanelContainer.new()
        pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        pill.add_theme_stylebox_override("panel",_style(PANEL,BORDER,17))
        pill.add_child(_label(value,22,GOLD,true))
        stats.add_child(pill)

func _refresh() -> void:
    _refresh_stats()
    for child in content.get_children():
        content.remove_child(child)
        child.queue_free()
    match page:
        0: _reactor()
        1: _workshop()
        2: _archive()
        3: _ascension()

func _change_page(index: int) -> void:
    page = index
    scroll.scroll_vertical = 0
    _refresh()

func _notify(value: String) -> void:
    message.text = value

func _tap() -> void:
    var earned: int = game.tap()
    click_count += 1
    if click_count % 15 == 0:
        game.save_game()
    if OS.get_name() == "Android":
        Input.vibrate_handheld(14)
    if earned > 0:
        _notify("CÁPSULA DESBLOQUEADA! ABRE-A.")
    else:
        _notify("+%.0f ENERGIA" % game.tap_power())
    _refresh()

func _open() -> void:
    var reward: Dictionary = game.open_capsule()
    if reward.is_empty():
        _notify("CARREGA O REATOR PARA GANHARES CÁPSULAS.")
    else:
        _notify("%s • %s • +%d MOEDAS" % [GameData.RARITIES[int(reward["rarity"])],reward["name"],reward["coins"]])
    _refresh()

func _reactor() -> void:
    var box := _card()
    box.add_child(_space(8))
    box.add_child(_label("REATOR CENTRAL",27,CYAN,true))
    box.add_child(_label("NÍVEL %d  •  %d TOQUES" % [game.level,game.total_taps],20,MUTED,true))
    box.add_child(_space(24))
    var big := _button("◉",CYAN,func(): _tap(),310)
    big.add_theme_font_size_override("font_size",148)
    big.add_theme_stylebox_override("normal",_style(Color("#12475b"),CYAN,155))
    big.add_theme_stylebox_override("hover",_style(Color("#1a6472"),CYAN,155))
    big.add_theme_stylebox_override("pressed",_style(Color("#0a344a"),GOLD,155))
    box.add_child(big)
    box.add_child(_space(12))
    var pct: int = int(100.0 * game.charge / game.target())
    box.add_child(_label("ENERGIA ACUMULADA   %d%%" % pct,21,MUTED,true))
    var progress := ProgressBar.new()
    progress.custom_minimum_size = Vector2(0,30)
    progress.show_percentage = false
    progress.max_value = game.target()
    progress.value = game.charge
    box.add_child(progress)
    box.add_child(_label("PODER %.1f   •   AUTO %.1f/s" % [game.tap_power(),game.auto_power()],20,GOLD,true))
    box.add_child(_space(8))
    box.add_child(_button("ABRIR CÁPSULA  ◉  %d" % game.capsules,GOLD,func(): _open(),84))
    box.add_child(_space(4))

func _workshop() -> void:
    content.add_child(_label("OFICINA DE MELHORIAS",29,CYAN,true))
    for key in ["tap","auto","charge","luck","critical"]:
        var code: String = key
        var box := _card()
        box.add_child(_label(GameData.UPGRADE_NAMES[code].to_upper(),25,WHITE))
        box.add_child(_label("Nível %d  •  Custo %d moedas" % [game.upgrades[code],game.upgrade_cost(code)],19,MUTED))
        box.add_child(_button("MELHORAR",CYAN,func(): _buy(code),64))

func _buy(key: String) -> void:
    if game.buy_upgrade(key):
        _notify("MELHORIA INSTALADA: %s" % GameData.UPGRADE_NAMES[key])
    else:
        _notify("AINDA NÃO TENS MOEDAS SUFICIENTES.")
    _refresh()

func _archive() -> void:
    content.add_child(_label("ARQUIVO DE RELÍQUIAS",29,CYAN,true))
    content.add_child(_label("%d / 30 DESCOBERTAS" % game.discovery_count(),19,GOLD,true))
    for i in range(GameData.ITEMS.size()):
        var key: String = str(i)
        var amount: int = int(game.inventory.get(key,0))
        var found: bool = game.discovered.has(key)
        var box := _card()
        var rarity: int = int(i / 5)
        box.add_child(_label(GameData.ITEMS[i] if found else "??? RELÍQUIA NÃO DESCOBERTA",21,Color(GameData.RARITY_COLORS[rarity]) if found else MUTED))
        box.add_child(_label("%s  •  Guardadas: %d  •  Valor: %d" % [GameData.RARITIES[rarity],amount,game.item_price(i)],17,MUTED))
        if amount > 0:
            var id: int = i
            box.add_child(_button("VENDER 1 POR %d" % game.item_price(i),GOLD,func(): _sell(id),57))

func _sell(id: int) -> void:
    var income: int = game.sell_item(id)
    if income > 0:
        _notify("RELÍQUIA VENDIDA: +%d MOEDAS" % income)
    _refresh()

func _ascension() -> void:
    var box := _card()
    box.add_child(_label("ASCENSÃO",31,GOLD,true))
    box.add_child(_label("Ao abrir 30 cápsulas numa era, podes reiniciar as melhorias e ganhar Núcleos Permanentes.",22,WHITE,true))
    box.add_child(_label("CÁPSULAS DESTA ERA: %d / 30" % game.opened,21,CYAN,true))
    box.add_child(_label("ASCENSÕES: %d    •    NÚCLEOS: %d" % [game.resets,game.cores],18,GOLD,true))
    box.add_child(_button("ASCENDER  ✦",GOLD,func(): _ascend(),72))
    content.add_child(_space())
    content.add_child(_label("TALENTOS PERMANENTES",27,CYAN,true))
    for key in ["power","wealth","luck"]:
        var id: String = key
        var perk := _card()
        perk.add_child(_label(GameData.PERK_NAMES[id],23,WHITE))
        perk.add_child(_label("Nível %d  •  Custo %d núcleos" % [game.perks[id],game.perk_cost(id)],19,MUTED))
        perk.add_child(_button("DESBLOQUEAR TALENTO",CYAN,func(): _perk(id),62))

func _ascend() -> void:
    var amount: int = game.ascend()
    _notify("ASCENSÃO CONCLUÍDA: +%d NÚCLEOS" % amount if amount > 0 else "PRECISAS DE ABRIR 30 CÁPSULAS NESTA ERA.")
    _refresh()

func _perk(key: String) -> void:
    if game.buy_perk(key):
        _notify("NOVO TALENTO PERMANENTE!")
    else:
        _notify("NÚCLEOS INSUFICIENTES.")
    _refresh()
