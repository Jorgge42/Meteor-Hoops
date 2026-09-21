extends Node

var menu_layer: CanvasLayer
var campaign_layer: CanvasLayer
var characters_layer: CanvasLayer
var result_layer: CanvasLayer
var lineup_layer: CanvasLayer
var settings_layer: CanvasLayer
var season_layer: CanvasLayer
var match_root: PrototypeMatch
var comic: ComicReader
var status_label: Label
var profile: Dictionary = {}
var current_match: Dictionary = {}
var selected_trio: Array = []
var lineup_status_label: Label
var lineup_start_button: Button
var lineup_buttons: Dictionary = {}
var last_match_stats: Dictionary = {}

func _ready() -> void:
    _ensure_input_actions()
    profile = SaveManager.load_profile()
    _show_main_menu()

func _show_main_menu() -> void:
    _clear_runtime_layers()
    profile = SaveManager.load_profile()

    menu_layer = CanvasLayer.new()
    add_child(menu_layer)

    var bg := ColorRect.new()
    bg.color = Color(0.025, 0.035, 0.05, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    menu_layer.add_child(bg)

    _add_star_field(menu_layer, 52)

    var vbox := VBoxContainer.new()
    vbox.set_anchors_preset(Control.PRESET_CENTER)
    vbox.position = Vector2(-240, -275)
    vbox.size = Vector2(480, 550)
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    vbox.add_theme_constant_override("separation", 12)
    menu_layer.add_child(vbox)

    var title := Label.new()
    title.text = "METEOR HOOPS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 46)
    vbox.add_child(title)

    var sub := Label.new()
    sub.text = "ROTA DO METEORO  •  campanha completa v1.2"
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sub.modulate = Color(0.75, 0.82, 0.9)
    vbox.add_child(sub)

    vbox.add_child(_menu_button("MODO HISTÓRIA", _show_campaign_map))

    var training := _menu_button("TREINO LIVRE" if bool(profile.get("training_unlocked", false)) else "TREINO LIVRE  🔒", _start_training)
    training.disabled = not bool(profile.get("training_unlocked", false))
    vbox.add_child(training)

    vbox.add_child(_menu_button("PERSONAGENS", _show_characters))
    vbox.add_child(_menu_button("TEMPORADA", _show_season))
    vbox.add_child(_menu_button("CONFIGURAÇÕES", _show_settings))
    vbox.add_child(_menu_button("CRÉDITOS", func():
        _set_status("Godot Engine • MIT\nMETEOR HOOPS: ROTA DO METEORO — protótipo técnico v1.2.\nHQs SVG atuais são placeholders e podem ser substituídas pelas artes finais.")
    ))

    var progress := Label.new()
    var unlocked := int(profile.get("highest_unlocked_match", 1))
    progress.text = "ROTA  •  %d/10 jogos alcançados" % mini(unlocked, 10)
    progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    progress.modulate = Color(0.95, 0.7, 0.25)
    vbox.add_child(progress)

    status_label = Label.new()
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.custom_minimum_size = Vector2(470, 88)
    vbox.add_child(status_label)

    var completed: Array = profile.get("completed_matches", [])
    if completed.has("match_10"):
        _set_status("CAMPEÕES DO METEORO. A campanha está completa — todos os dez jogos permanecem disponíveis para revanche e evolução.")
    elif completed.has("match_09"):
        _set_status("Você silenciou a Apex Dominion. A final contra a Tyrant Crown é o último nó da Rota.")
    elif completed.has("match_08"):
        _set_status("A semifinal contra a Apex Dominion está liberada. Leia o plano, varie decisões e construa Compostura.")
    elif completed.has("match_07"):
        _set_status("Fossil Tech está liberada. Varie sequências, use ações-isca e obrigue o modelo a errar.")
    elif completed.has("match_06"):
        _set_status("Nightclaw Academy está liberada. Varie o ataque, use fintas e proteja cada linha de passe.")
    elif completed.has("match_05"):
        _set_status("Ironhorn Institute está liberada. Prepare-se para contato, corta-luzes, box-out e lances livres.")
    elif completed.has("match_04"):
        _set_status("Skycrest Academy está liberada. Prepare-se para cortes verticais, rebotes e alley-oops.")
    elif completed.has("match_03"):
        _set_status("Tidefang School está liberada. Prepare-se para inversões de lado e leitura do lado fraco.")
    elif completed.has("match_02"):
        _set_status("Ember Ridge está liberada. Prepare-se para pressão e decisões mais rápidas.")
    elif completed.has("match_01"):
        _set_status("Canopy Institute está esperando. Abra o Modo História e escolha o Jogo 2.")
    else:
        _set_status("A jornada começa contra a Quartz Academy. O Troféu Meteoro está a dez jogos de distância.")

func _show_characters() -> void:
    _clear_runtime_layers()
    characters_layer = CanvasLayer.new()
    add_child(characters_layer)

    var bg := ColorRect.new()
    bg.color = Color(0.018, 0.028, 0.045, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    characters_layer.add_child(bg)
    _add_star_field(characters_layer, 58)

    var title := Label.new()
    title.position = Vector2(58, 26)
    title.size = Vector2(1000, 52)
    title.text = "VALE FÓSSIL • ELENCO"
    title.add_theme_font_size_override("font_size", 38)
    characters_layer.add_child(title)

    var subtitle := Label.new()
    subtitle.position = Vector2(60, 76)
    subtitle.size = Vector2(1100, 38)
    subtitle.text = "Cada dinossauro deve mudar uma decisão de basquete — não apenas a aparência do personagem."
    subtitle.modulate = Color(0.72, 0.82, 0.9)
    characters_layer.add_child(subtitle)

    var scroll := ScrollContainer.new()
    scroll.position = Vector2(55, 125)
    scroll.size = Vector2(1170, 500)
    characters_layer.add_child(scroll)

    var grid := GridContainer.new()
    grid.columns = 2
    grid.add_theme_constant_override("h_separation", 18)
    grid.add_theme_constant_override("v_separation", 18)
    grid.custom_minimum_size = Vector2(1120, 1020)
    scroll.add_child(grid)

    for entry in MatchCatalog.home_roster(profile.get("player_progress", {})):
        grid.add_child(_character_card(entry))

    var back := Button.new()
    back.position = Vector2(55, 650)
    back.size = Vector2(230, 48)
    back.text = "← MENU PRINCIPAL"
    back.pressed.connect(_show_main_menu)
    characters_layer.add_child(back)

func _character_card(entry: Dictionary) -> Control:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(545, 310)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 5)
    panel.add_child(box)

    var name_label := Label.new()
    name_label.text = "%s  •  %s" % [String(entry.get("display_name", "")), String(entry.get("species", ""))]
    name_label.add_theme_font_size_override("font_size", 24)
    name_label.modulate = Color(0.3, 0.9, 0.82)
    box.add_child(name_label)

    var role := Label.new()
    role.text = "%s  |  %.2f m  |  ☄ %s" % [String(entry.get("role", "")), float(entry.get("height", 1.8)), String(entry.get("instinct", ""))]
    role.modulate = Color(0.95, 0.72, 0.25)
    box.add_child(role)

    var progression := Label.new()
    var xp := int(entry.get("xp", 0))
    var level := int(entry.get("level", 1))
    var next_xp := SaveManager.xp_to_next_level(xp)
    var upgrade_points := int(entry.get("upgrade_points", 0))
    progression.text = "NÍVEL %d  •  XP %d%s  •  EVOLUÇÃO %d" % [level, xp, "  •  %d para o próximo" % next_xp if next_xp > 0 else "  •  NÍVEL MÁXIMO", upgrade_points]
    progression.modulate = Color(0.55, 0.92, 1.0)
    box.add_child(progression)

    var stats := Label.new()
    stats.text = "VEL %02d   ARREM %02d   PASSE %02d   DEF %02d   FORÇA %02d" % [
        int(entry.get("speed", 0)), int(entry.get("shooting", 0)), int(entry.get("passing", 0)), int(entry.get("defense", 0)), int(entry.get("strength", 0))
    ]
    stats.add_theme_font_size_override("font_size", 16)
    box.add_child(stats)

    var upgrades: Dictionary = entry.get("upgrades", {})
    var upgrade_line := Label.new()
    upgrade_line.text = "BÔNUS ESCOLHIDOS • VEL +%d  ARR +%d  PAS +%d  DEF +%d  FOR +%d" % [
        int(upgrades.get("speed", 0)), int(upgrades.get("shooting", 0)), int(upgrades.get("passing", 0)),
        int(upgrades.get("defense", 0)), int(upgrades.get("strength", 0))
    ]
    upgrade_line.add_theme_font_size_override("font_size", 14)
    upgrade_line.modulate = Color(0.76, 0.84, 0.94)
    box.add_child(upgrade_line)

    if upgrade_points > 0:
        var choice := HBoxContainer.new()
        choice.add_theme_constant_override("separation", 5)
        choice.add_child(_upgrade_button("+VEL", String(entry.get("id", "")), "speed", int(upgrades.get("speed", 0)) >= 5))
        choice.add_child(_upgrade_button("+ARR", String(entry.get("id", "")), "shooting", int(upgrades.get("shooting", 0)) >= 5))
        choice.add_child(_upgrade_button("+PAS", String(entry.get("id", "")), "passing", int(upgrades.get("passing", 0)) >= 5))
        choice.add_child(_upgrade_button("+DEF", String(entry.get("id", "")), "defense", int(upgrades.get("defense", 0)) >= 5))
        choice.add_child(_upgrade_button("+FOR", String(entry.get("id", "")), "strength", int(upgrades.get("strength", 0)) >= 5))
        box.add_child(choice)

    var bio := Label.new()
    bio.text = String(entry.get("bio", ""))
    bio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    bio.custom_minimum_size = Vector2(505, 70)
    bio.modulate = Color(0.76, 0.82, 0.9)
    box.add_child(bio)

    return panel

func _upgrade_button(text_value: String, player_id: String, stat: String, disabled_value: bool) -> Button:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(86, 32)
    button.disabled = disabled_value
    button.pressed.connect(func(): _spend_upgrade(player_id, stat))
    return button

func _spend_upgrade(player_id: String, stat: String) -> void:
    profile = SaveManager.spend_upgrade_point(profile, player_id, stat)
    _show_characters()

func _show_campaign_map() -> void:
    _clear_runtime_layers()
    profile = SaveManager.load_profile()

    campaign_layer = CanvasLayer.new()
    add_child(campaign_layer)

    var bg := ColorRect.new()
    bg.color = Color(0.018, 0.028, 0.045, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    campaign_layer.add_child(bg)
    _add_star_field(campaign_layer, 70)

    var title := Label.new()
    title.position = Vector2(70, 28)
    title.size = Vector2(920, 55)
    title.text = "ROTA DO METEORO"
    title.add_theme_font_size_override("font_size", 38)
    campaign_layer.add_child(title)

    var subtitle := Label.new()
    subtitle.position = Vector2(72, 78)
    subtitle.size = Vector2(1000, 32)
    subtitle.text = "10 escolas. 10 jogos. Uma final contra a Tyrant Crown pelo Troféu Meteoro."
    subtitle.modulate = Color(0.72, 0.8, 0.9)
    campaign_layer.add_child(subtitle)

    var scroll := ScrollContainer.new()
    scroll.position = Vector2(60, 125)
    scroll.size = Vector2(1160, 500)
    campaign_layer.add_child(scroll)

    var grid := GridContainer.new()
    grid.columns = 2
    grid.add_theme_constant_override("h_separation", 18)
    grid.add_theme_constant_override("v_separation", 14)
    grid.custom_minimum_size = Vector2(1110, 900)
    scroll.add_child(grid)

    var unlocked := int(profile.get("highest_unlocked_match", 1))
    var completed: Array = profile.get("completed_matches", [])
    for item in MatchCatalog.all_matches():
        var number := int(item.get("number", 0))
        var match_id := String(item.get("id", ""))
        var is_unlocked := number <= unlocked
        var is_complete := completed.has(match_id)
        grid.add_child(_campaign_card(item, is_unlocked, is_complete))

    var back := Button.new()
    back.position = Vector2(60, 650)
    back.size = Vector2(220, 48)
    back.text = "← MENU PRINCIPAL"
    back.pressed.connect(_show_main_menu)
    campaign_layer.add_child(back)

    var legend := Label.new()
    legend.position = Vector2(315, 660)
    legend.size = Vector2(860, 30)
    legend.text = "✓ concluído   •   ☄ disponível   •   🔒 bloqueado   •   Jogos 1–10 jogáveis nesta build"
    legend.modulate = Color(0.72, 0.8, 0.88)
    campaign_layer.add_child(legend)

func _campaign_card(item: Dictionary, unlocked: bool, completed: bool) -> Control:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(540, 150)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 4)
    panel.add_child(box)

    var number := int(item.get("number", 0))
    var heading := Label.new()
    heading.text = "%s  JOGO %02d • %s" % ["✓" if completed else ("☄" if unlocked else "🔒"), number, String(item.get("title", ""))]
    heading.add_theme_font_size_override("font_size", 21)
    heading.modulate = Color(String(item.get("color", "ffffff"))) if unlocked else Color(0.45, 0.48, 0.55)
    box.add_child(heading)

    var school := Label.new()
    school.text = String(item.get("school", ""))
    school.add_theme_font_size_override("font_size", 18)
    box.add_child(school)

    var description := Label.new()
    description.text = String(item.get("subtitle", ""))
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.custom_minimum_size = Vector2(500, 38)
    description.modulate = Color(0.75, 0.8, 0.87)
    box.add_child(description)

    var button := Button.new()
    button.custom_minimum_size = Vector2(500, 35)
    var playable := bool(item.get("playable", false))
    if not unlocked:
        button.text = "BLOQUEADO"
        button.disabled = true
    elif not playable:
        button.text = "ROTA MAPEADA • EM DESENVOLVIMENTO"
        button.disabled = true
    else:
        button.text = "REJOGAR" if completed else "JOGAR"
        button.pressed.connect(func(): _choose_campaign_match(number))
    box.add_child(button)
    return panel

func _choose_campaign_match(number: int) -> void:
    var config := MatchCatalog.get_match(number)
    if config.is_empty():
        return
    var unlocked := int(profile.get("highest_unlocked_match", 1))
    if number > unlocked or not bool(config.get("playable", false)):
        return
    current_match = config
    if is_instance_valid(campaign_layer):
        campaign_layer.queue_free()

    var story_id := "chapter_%02d_pre" % number
    var pre_path := String(config.get("pre_chapter", ""))
    if not pre_path.is_empty() and ResourceLoader.exists(pre_path) and not SaveManager.has_seen_story(profile, story_id):
        _play_story_resource(pre_path, func():
            if number == 1:
                profile = SaveManager.mark_intro_seen(profile)
            else:
                profile = SaveManager.mark_story_seen(profile, story_id)
            _show_lineup_selection(config)
        )
    else:
        _show_lineup_selection(config)

func _show_lineup_selection(config: Dictionary) -> void:
    _clear_runtime_layers()
    current_match = config.duplicate(true)
    selected_trio = _validated_preferred_trio()
    lineup_buttons.clear()

    lineup_layer = CanvasLayer.new()
    add_child(lineup_layer)
    var bg := ColorRect.new()
    bg.color = Color(0.018, 0.028, 0.045, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    lineup_layer.add_child(bg)
    _add_star_field(lineup_layer, 46)

    var title := Label.new()
    title.position = Vector2(70, 35)
    title.size = Vector2(1100, 50)
    title.text = "ESCOLHA O TRIO • JOGO %02d" % int(config.get("number", 1))
    title.add_theme_font_size_override("font_size", 36)
    lineup_layer.add_child(title)

    var subtitle := Label.new()
    subtitle.position = Vector2(72, 88)
    subtitle.size = Vector2(1100, 45)
    subtitle.text = "%s • selecione exatamente 3 dos 5 atletas" % String(config.get("school", "RIVAL"))
    subtitle.modulate = Color(0.74, 0.82, 0.9)
    lineup_layer.add_child(subtitle)

    var grid := GridContainer.new()
    grid.columns = 5
    grid.position = Vector2(55, 165)
    grid.size = Vector2(1170, 320)
    grid.add_theme_constant_override("h_separation", 10)
    lineup_layer.add_child(grid)

    for entry in MatchCatalog.home_roster(profile.get("player_progress", {})):
        var id := String(entry.get("id", ""))
        var panel := PanelContainer.new()
        panel.custom_minimum_size = Vector2(220, 300)
        var box := VBoxContainer.new()
        box.add_theme_constant_override("separation", 8)
        panel.add_child(box)
        var name_label := Label.new()
        name_label.text = String(entry.get("display_name", ""))
        name_label.add_theme_font_size_override("font_size", 23)
        name_label.modulate = Color(0.35, 0.92, 0.82)
        box.add_child(name_label)
        var role := Label.new()
        role.text = "%s\n%s" % [String(entry.get("species", "")), String(entry.get("role", ""))]
        role.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        box.add_child(role)
        var stats := Label.new()
        stats.text = "VEL %02d\nARREM %02d\nPASSE %02d\nDEF %02d\nFORÇA %02d" % [int(entry.get("speed", 0)), int(entry.get("shooting", 0)), int(entry.get("passing", 0)), int(entry.get("defense", 0)), int(entry.get("strength", 0))]
        stats.modulate = Color(0.78, 0.84, 0.9)
        box.add_child(stats)
        var check := CheckButton.new()
        check.text = "TITULAR"
        check.button_pressed = selected_trio.has(id)
        check.toggled.connect(func(pressed: bool): _toggle_lineup(id, pressed))
        lineup_buttons[id] = check
        box.add_child(check)
        grid.add_child(panel)

    lineup_status_label = Label.new()
    lineup_status_label.position = Vector2(60, 520)
    lineup_status_label.size = Vector2(760, 45)
    lineup_status_label.add_theme_font_size_override("font_size", 18)
    lineup_layer.add_child(lineup_status_label)

    lineup_start_button = Button.new()
    lineup_start_button.position = Vector2(840, 510)
    lineup_start_button.size = Vector2(360, 54)
    lineup_start_button.text = "ENTRAR EM QUADRA"
    lineup_start_button.pressed.connect(_confirm_lineup)
    lineup_layer.add_child(lineup_start_button)

    var back := Button.new()
    back.position = Vector2(60, 620)
    back.size = Vector2(240, 48)
    back.text = "← VOLTAR À ROTA"
    back.pressed.connect(_show_campaign_map)
    lineup_layer.add_child(back)
    _refresh_lineup_ui()

func _toggle_lineup(id: String, pressed: bool) -> void:
    if pressed:
        if not selected_trio.has(id) and selected_trio.size() < 3:
            selected_trio.append(id)
        elif selected_trio.size() >= 3:
            var button = lineup_buttons.get(id, null)
            if is_instance_valid(button):
                button.set_pressed_no_signal(false)
    else:
        selected_trio.erase(id)
    _refresh_lineup_ui()

func _refresh_lineup_ui() -> void:
    if is_instance_valid(lineup_status_label):
        lineup_status_label.text = "TRIO %d/3 • %s" % [selected_trio.size(), ", ".join(_names_for_ids(selected_trio))]
        lineup_status_label.modulate = Color(0.35, 0.95, 0.75) if selected_trio.size() == 3 else Color(1.0, 0.72, 0.25)
    if is_instance_valid(lineup_start_button):
        lineup_start_button.disabled = selected_trio.size() != 3

func _confirm_lineup() -> void:
    if selected_trio.size() != 3:
        return
    profile = SaveManager.set_preferred_trio(profile, selected_trio)
    if is_instance_valid(lineup_layer):
        lineup_layer.queue_free()
    _start_match(false, current_match)

func _validated_preferred_trio() -> Array:
    var valid_ids: Array = []
    for entry in MatchCatalog.home_roster(profile.get("player_progress", {})):
        valid_ids.append(String(entry.get("id", "")))
    var preferred: Array = profile.get("preferred_trio", ["kiro", "luma", "bato"])
    var result: Array = []
    for id in preferred:
        if valid_ids.has(String(id)) and not result.has(String(id)):
            result.append(String(id))
    for fallback in ["kiro", "luma", "bato", "nilo", "mako"]:
        if result.size() >= 3:
            break
        if valid_ids.has(fallback) and not result.has(fallback):
            result.append(fallback)
    return result.slice(0, 3)

func _names_for_ids(ids: Array) -> PackedStringArray:
    var names := PackedStringArray()
    for id in ids:
        for entry in MatchCatalog.home_roster(profile.get("player_progress", {})):
            if String(entry.get("id", "")) == String(id):
                names.append(String(entry.get("display_name", id)))
                break
    return names

func _show_season() -> void:
    _clear_runtime_layers()
    profile = SaveManager.load_profile()
    season_layer = CanvasLayer.new()
    add_child(season_layer)

    var bg := ColorRect.new()
    bg.color = Color(0.018, 0.028, 0.045, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    season_layer.add_child(bg)
    _add_star_field(season_layer, 54)

    var title := Label.new()
    title.position = Vector2(58, 24)
    title.size = Vector2(1100, 50)
    title.text = "TEMPORADA • VALE FÓSSIL"
    title.add_theme_font_size_override("font_size", 36)
    season_layer.add_child(title)

    var history: Array = profile.get("match_history", [])
    var wins := 0
    var losses := 0
    for result_value in history:
        var result: Dictionary = result_value
        if bool(result.get("won", false)):
            wins += 1
        else:
            losses += 1

    var record := Label.new()
    record.position = Vector2(60, 76)
    record.size = Vector2(1100, 35)
    record.text = "REGISTRO DE PARTIDAS • %d vitórias / %d derrotas  •  histórico recente %d jogos" % [wins, losses, history.size()]
    record.modulate = Color(0.95, 0.72, 0.25)
    season_layer.add_child(record)

    var header := Label.new()
    header.position = Vector2(65, 125)
    header.size = Vector2(1110, 34)
    header.text = "ATLETA          LV XP    J PTS AST REB STL BLK  FG     3PT    FT     PF TO MVP"
    header.add_theme_font_size_override("font_size", 17)
    header.modulate = Color(0.45, 0.92, 0.85)
    season_layer.add_child(header)

    var totals: Dictionary = profile.get("season_totals", {})
    var progress: Dictionary = profile.get("player_progress", {})
    var y := 172.0
    for entry in MatchCatalog.home_roster(progress):
        var id := String(entry.get("id", ""))
        var row: Dictionary = totals.get(id, {})
        var state: Dictionary = progress.get(id, {})
        var label := Label.new()
        label.position = Vector2(65, y)
        label.size = Vector2(1120, 54)
        label.text = "%s • LV %02d XP %04d • J %02d PTS %03d AST %03d REB %03d STL %03d BLK %03d • FG %02d/%02d 3PT %02d/%02d FT %02d/%02d PF %02d TO %02d • MVP %02d" % [
            String(entry.get("display_name", "")), int(state.get("level", 1)), int(state.get("xp", 0)),
            int(row.get("games", 0)), int(row.get("points", 0)), int(row.get("assists", 0)),
            int(row.get("rebounds", 0)), int(row.get("steals", 0)), int(row.get("blocks", 0)),
            int(row.get("fgm", 0)), int(row.get("fga", 0)), int(row.get("3pm", 0)), int(row.get("3pa", 0)),
            int(row.get("ftm", 0)), int(row.get("fta", 0)), int(row.get("fouls", 0)),
            int(row.get("turnovers", 0)), int(state.get("mvp", 0))
        ]
        label.add_theme_font_size_override("font_size", 16)
        season_layer.add_child(label)
        y += 68.0

    var note := Label.new()
    note.position = Vector2(65, 530)
    note.size = Vector2(1110, 82)
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    note.text = "EVOLUÇÃO v1.2: carreira, upgrades e perfis agregados permanecem salvos. Na final, a Tyrant Crown combina tendências, sequências e planos visíveis; quebrar três decretos abre a janela Coroa Partida."
    note.modulate = Color(0.72, 0.82, 0.9)
    season_layer.add_child(note)

    var back := Button.new()
    back.position = Vector2(60, 640)
    back.size = Vector2(240, 48)
    back.text = "← MENU PRINCIPAL"
    back.pressed.connect(_show_main_menu)
    season_layer.add_child(back)

func _show_settings() -> void:
    _clear_runtime_layers()
    settings_layer = CanvasLayer.new()
    add_child(settings_layer)
    var bg := ColorRect.new()
    bg.color = Color(0.018, 0.028, 0.045, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    settings_layer.add_child(bg)

    var panel := PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-310, -270)
    panel.size = Vector2(620, 540)
    settings_layer.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 14)
    panel.add_child(box)

    var title := Label.new()
    title.text = "CONFIGURAÇÕES • ACESSIBILIDADE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 30)
    box.add_child(title)

    var difficulty := OptionButton.new()
    difficulty.name = "Difficulty"
    difficulty.add_item("AVENTURA • janela maior / IA mais gentil")
    difficulty.add_item("LIGA • equilíbrio padrão")
    difficulty.add_item("METEORO • IA mais agressiva / timing estrito")
    var current := String(profile.get("difficulty", "ADVENTURE"))
    difficulty.select(0 if current == "ADVENTURE" else (1 if current == "LEAGUE" else 2))
    box.add_child(difficulty)

    var shot_feedback := CheckButton.new()
    shot_feedback.name = "ShotFeedback"
    shot_feedback.text = "Feedback detalhado de arremesso (timing + contest)"
    shot_feedback.button_pressed = bool(profile.get("shot_feedback", true))
    box.add_child(shot_feedback)

    var reduced := CheckButton.new()
    reduced.name = "ReducedFX"
    reduced.text = "Reduzir pulsos e brilho do Instinto Meteoro"
    reduced.button_pressed = bool(profile.get("reduced_fx", false))
    box.add_child(reduced)

    var contrast := CheckButton.new()
    contrast.name = "HighContrast"
    contrast.text = "Alto contraste nos times e marcações da quadra"
    contrast.button_pressed = bool(profile.get("high_contrast", false))
    box.add_child(contrast)

    var info := Label.new()
    info.text = "A dificuldade altera a janela de green release e a velocidade de decisão da IA. Nenhuma opção muda a história ou bloqueia conteúdo."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.custom_minimum_size = Vector2(560, 90)
    info.modulate = Color(0.72, 0.82, 0.9)
    box.add_child(info)

    var save := Button.new()
    save.text = "SALVAR E VOLTAR"
    save.custom_minimum_size = Vector2(560, 50)
    save.pressed.connect(func(): _save_settings(difficulty, shot_feedback, reduced, contrast))
    box.add_child(save)

func _save_settings(difficulty: OptionButton, shot_feedback: CheckButton, reduced: CheckButton, contrast: CheckButton) -> void:
    var names := ["ADVENTURE", "LEAGUE", "METEOR"]
    profile = SaveManager.set_options(profile, names[difficulty.selected], shot_feedback.button_pressed, reduced.button_pressed, contrast.button_pressed)
    _show_main_menu()

func _format_stats_table(stats: Dictionary) -> String:
    if stats.is_empty():
        return "Sem estatísticas registradas."
    var mvp_name := String(stats.get("mvp_name", ""))
    var lines := PackedStringArray(["MVP • %s" % mvp_name if not mvp_name.is_empty() else "BOX SCORE INDIVIDUAL"])
    var players: Array = stats.get("players", [])
    for row_value in players:
        var row: Dictionary = row_value
        if not bool(row.get("played", false)):
            continue
        lines.append("%s • PTS %02d AST %02d REB %02d STL %02d BLK %02d FG %d/%d FT %d/%d PF %d TO %d IMP %.1f" % [
            String(row.get("name", "")), int(row.get("points", 0)), int(row.get("assists", 0)),
            int(row.get("rebounds", 0)), int(row.get("steals", 0)), int(row.get("blocks", 0)),
            int(row.get("fgm", 0)), int(row.get("fga", 0)), int(row.get("ftm", 0)), int(row.get("fta", 0)),
            int(row.get("fouls", 0)), int(row.get("turnovers", 0)),
            float(row.get("impact", 0.0))
        ])
    var team_turnovers: Dictionary = stats.get("team_turnovers", {})
    var points_after_turnovers: Dictionary = stats.get("points_off_turnovers", {})
    lines.append("EQUIPE • TO %d • PONTOS APÓS TO %d" % [
        int(team_turnovers.get(0, team_turnovers.get("0", 0))),
        int(points_after_turnovers.get(0, points_after_turnovers.get("0", 0))),
    ])
    var crown_summary: Dictionary = stats.get("crown_summary", {})
    if int(crown_summary.get("edicts_broken", 0)) > 0:
        lines.append("FINAL • DECRETOS %d • COROAS PARTIDAS %d • PREVISÕES EVITADAS %d" % [
            int(crown_summary.get("edicts_broken", 0)),
            int(crown_summary.get("crowns_shattered", 0)),
            int(crown_summary.get("predictions_evaded", 0)),
        ])
    return "\n".join(lines)

func _format_progression(summary: Array) -> String:
    if summary.is_empty():
        return "Sem XP registrado."
    var lines := PackedStringArray()
    for item_value in summary:
        var item: Dictionary = item_value
        var level_text := " • SUBIU PARA NÍVEL %d!" % int(item.get("new_level", 1)) if int(item.get("new_level", 1)) > int(item.get("old_level", 1)) else ""
        var mvp_text := " • MVP +12 XP" if bool(item.get("mvp", false)) else ""
        var next_text := " • %d XP até próximo" % int(item.get("to_next", 0)) if int(item.get("to_next", 0)) > 0 else ""
        var upgrade_text := " • +%d PONTO DE EVOLUÇÃO" % int(item.get("upgrade_points_gained", 0)) if int(item.get("upgrade_points_gained", 0)) > 0 else ""
        lines.append("%s  +%d XP%s%s%s%s" % [String(item.get("name", "")), int(item.get("xp_gain", 0)), level_text, mvp_text, next_text, upgrade_text])
    return "\n".join(lines)

func _start_training() -> void:
    if not bool(profile.get("training_unlocked", false)):
        _set_status("Vença o Jogo 1 para liberar o Treino Livre.")
        return
    if is_instance_valid(menu_layer):
        menu_layer.queue_free()
    current_match = MatchCatalog.get_match(1)
    selected_trio = _validated_preferred_trio()
    _start_match(true, current_match)

func _start_match(training: bool, config: Dictionary) -> void:
    if is_instance_valid(match_root):
        match_root.queue_free()
    match_root = load("res://scenes/prototype_match.gd").new()
    match_root.training_mode = training
    match_root.match_config = config.duplicate(true)
    match_root.home_lineup_ids = selected_trio.duplicate() if selected_trio.size() == 3 else _validated_preferred_trio()
    match_root.player_progression = profile.get("player_progress", {}).duplicate(true)
    match_root.adaptive_profile = profile.get("adaptive_profile", {}).duplicate(true)
    match_root.sequence_profile = profile.get("sequence_profile", {}).duplicate(true)
    match_root.semifinal_profile = profile.get("semifinal_profile", {}).duplicate(true)
    match_root.final_profile = profile.get("final_profile", {}).duplicate(true)
    match_root.difficulty_name = String(profile.get("difficulty", "ADVENTURE"))
    match_root.shot_feedback_enabled = bool(profile.get("shot_feedback", true))
    match_root.reduced_fx = bool(profile.get("reduced_fx", false))
    match_root.high_contrast = bool(profile.get("high_contrast", false))
    match_root.tutorial_enabled = not training and int(config.get("number", 1)) == 1 and not bool(profile.get("tutorial_completed", false))
    match_root.exit_requested.connect(_show_main_menu)
    match_root.match_finished.connect(_on_match_finished)
    match_root.tutorial_completed.connect(_on_tutorial_completed)
    add_child(match_root)

func _on_tutorial_completed() -> void:
    profile = SaveManager.mark_tutorial_completed(profile)

func _on_match_finished(home_won: bool, home_score: int, away_score: int) -> void:
    var number := int(current_match.get("number", 1))
    var id := String(current_match.get("id", "match_01"))
    last_match_stats = match_root.get_home_stats_summary() if is_instance_valid(match_root) else {}
    if home_won:
        profile = SaveManager.complete_match(profile, id, number, home_score, away_score, last_match_stats)
    else:
        profile = SaveManager.record_defeat(profile, id, number, home_score, away_score, last_match_stats)
    _show_result_overlay(home_won, home_score, away_score)

func _show_result_overlay(home_won: bool, home_score: int, away_score: int) -> void:
    if is_instance_valid(result_layer):
        result_layer.queue_free()
    result_layer = CanvasLayer.new()
    result_layer.layer = 20
    add_child(result_layer)

    var shade := ColorRect.new()
    shade.color = Color(0.01, 0.015, 0.025, 0.90)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    result_layer.add_child(shade)

    var panel := PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-340, -340)
    panel.size = Vector2(680, 680)
    result_layer.add_child(panel)

    var box := VBoxContainer.new()
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    box.add_theme_constant_override("separation", 14)
    panel.add_child(box)

    var number := int(current_match.get("number", 1))
    var opponent := String(current_match.get("school", "RIVAL"))
    var headline := Label.new()
    if home_won and number == 10:
        headline.text = "CAMPEÕES DO METEORO"
    else:
        headline.text = "ROTA AVANÇA" if home_won else "A ROTA CONTINUA"
    headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    headline.add_theme_font_size_override("font_size", 34)
    box.add_child(headline)

    var game_label := Label.new()
    game_label.text = "JOGO %02d • %s" % [number, String(current_match.get("title", ""))]
    game_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    game_label.modulate = Color(0.95, 0.72, 0.22)
    box.add_child(game_label)

    var score := Label.new()
    score.text = "VALE FÓSSIL  %d  —  %d  %s" % [home_score, away_score, opponent]
    score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    score.add_theme_font_size_override("font_size", 24)
    box.add_child(score)

    var body := Label.new()
    body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    body.custom_minimum_size = Vector2(560, 72)
    if home_won:
        if number == 10:
            body.text = "A Coroa caiu sem truques: leitura, variedade e coragem fecharam a Rota. A Vale Fóssil ergue o Troféu Meteoro."
        elif number == 1:
            body.text = "O próximo nó da Rota do Meteoro foi aberto. O Treino Livre também foi liberado."
        else:
            body.text = "A Vale Fóssil sobe mais um degrau. A próxima escola já aparece no mapa da temporada."
    else:
        body.text = "Você pode tentar novamente. Derrotas ficam registradas apenas como último resultado e não apagam o progresso anterior."
    box.add_child(body)

    var stats_title := Label.new()
    stats_title.text = "BOX SCORE • VALE FÓSSIL"
    stats_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    stats_title.modulate = Color(0.35, 0.9, 0.82)
    box.add_child(stats_title)

    var stats_label := Label.new()
    stats_label.text = _format_stats_table(last_match_stats)
    stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    stats_label.add_theme_font_size_override("font_size", 15)
    stats_label.custom_minimum_size = Vector2(620, 108)
    box.add_child(stats_label)

    var xp_title := Label.new()
    xp_title.text = "PROGRESSÃO"
    xp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    xp_title.modulate = Color(0.55, 0.86, 1.0)
    box.add_child(xp_title)

    var xp_label := Label.new()
    xp_label.text = _format_progression(profile.get("last_progression", []))
    xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    xp_label.add_theme_font_size_override("font_size", 14)
    xp_label.custom_minimum_size = Vector2(620, 76)
    box.add_child(xp_label)

    if home_won:
        var post_path := String(current_match.get("post_chapter", ""))
        if not post_path.is_empty() and ResourceLoader.exists(post_path):
            box.add_child(_result_button("LER HQ PÓS-JOGO", _play_post_match_comic))
        box.add_child(_result_button("VOLTAR À ROTA", _show_campaign_map))
    else:
        box.add_child(_result_button("TENTAR NOVAMENTE", _retry_story_match))
        box.add_child(_result_button("VOLTAR À ROTA", _show_campaign_map))

func _retry_story_match() -> void:
    if is_instance_valid(result_layer):
        result_layer.queue_free()
    if is_instance_valid(match_root):
        match_root.queue_free()
    selected_trio = _validated_preferred_trio()
    _start_match(false, current_match)

func _play_post_match_comic() -> void:
    if is_instance_valid(result_layer):
        result_layer.queue_free()
    if is_instance_valid(match_root):
        match_root.queue_free()
    var number := int(current_match.get("number", 1))
    var post_path := String(current_match.get("post_chapter", ""))
    var story_id := "chapter_%02d_post" % number
    _play_story_resource(post_path, func():
        profile = SaveManager.mark_story_seen(profile, story_id)
        _show_campaign_map()
    )

func _play_story_resource(path: String, on_finished: Callable) -> void:
    comic = ComicReader.new()
    add_child(comic)
    var chapter := load(path) as StoryChapter
    comic.setup(chapter)
    comic.finished.connect(func():
        if is_instance_valid(comic):
            comic.queue_free()
        on_finished.call()
    )

func _menu_button(text_value: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(440, 48)
    button.pressed.connect(callback)
    return button

func _result_button(text_value: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(420, 46)
    button.pressed.connect(callback)
    return button

func _set_status(text_value: String) -> void:
    if is_instance_valid(status_label):
        status_label.text = text_value

func _add_star_field(layer: CanvasLayer, count: int) -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 20460417 + count
    for i in range(count):
        var star := ColorRect.new()
        var size := rng.randf_range(1.0, 3.2)
        star.position = Vector2(rng.randf_range(0.0, 1275.0), rng.randf_range(0.0, 715.0))
        star.size = Vector2(size, size)
        star.color = Color(0.7, 0.82, 1.0, rng.randf_range(0.18, 0.55))
        layer.add_child(star)

func _clear_runtime_layers() -> void:
    if is_instance_valid(result_layer):
        result_layer.queue_free()
    if is_instance_valid(match_root):
        match_root.queue_free()
    if is_instance_valid(comic):
        comic.queue_free()
    if is_instance_valid(menu_layer):
        menu_layer.queue_free()
    if is_instance_valid(campaign_layer):
        campaign_layer.queue_free()
    if is_instance_valid(characters_layer):
        characters_layer.queue_free()
    if is_instance_valid(lineup_layer):
        lineup_layer.queue_free()
    if is_instance_valid(settings_layer):
        settings_layer.queue_free()
    if is_instance_valid(season_layer):
        season_layer.queue_free()

func _ensure_input_actions() -> void:
    _bind_keys("move_left", [KEY_A, KEY_LEFT])
    _bind_keys("move_right", [KEY_D, KEY_RIGHT])
    _bind_keys("move_up", [KEY_W, KEY_UP])
    _bind_keys("move_down", [KEY_S, KEY_DOWN])
    _bind_keys("pass_pickup", [KEY_SPACE])
    _bind_keys("lob_pass", [KEY_L])
    _bind_keys("pass_fake", [KEY_V])
    _bind_keys("shoot", [KEY_J])
    _bind_keys("finish_block", [KEY_K])
    _bind_keys("protect_ball", [KEY_E])
    _bind_keys("activate_instinct", [KEY_F])
    _bind_keys("call_play", [KEY_C])
    _bind_keys("call_screen", [KEY_G])
    _bind_keys("post_move", [KEY_H])
    _bind_keys("sprint", [KEY_SHIFT])
    _bind_keys("switch_player", [KEY_Q, KEY_TAB])
    _bind_keys("reset_ball", [KEY_R])
    _bind_keys("pause_menu", [KEY_ESCAPE])
    _bind_joy_button("pass_pickup", JOY_BUTTON_A)
    _bind_joy_button("lob_pass", JOY_BUTTON_DPAD_UP)
    _bind_joy_button("pass_fake", JOY_BUTTON_DPAD_DOWN)
    _bind_joy_button("call_screen", JOY_BUTTON_DPAD_RIGHT)
    _bind_joy_button("post_move", JOY_BUTTON_DPAD_LEFT)
    _bind_joy_button("shoot", JOY_BUTTON_X)
    _bind_joy_button("finish_block", JOY_BUTTON_B)
    _bind_joy_button("switch_player", JOY_BUTTON_Y)
    _bind_joy_button("sprint", JOY_BUTTON_RIGHT_SHOULDER)
    _bind_joy_button("protect_ball", JOY_BUTTON_LEFT_SHOULDER)
    _bind_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
    _bind_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
    _bind_joy_axis("move_up", JOY_AXIS_LEFT_Y, -1.0)
    _bind_joy_axis("move_down", JOY_AXIS_LEFT_Y, 1.0)

func _bind_keys(action: StringName, keys: Array) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    for keycode in keys:
        var event := InputEventKey.new()
        event.physical_keycode = keycode
        InputMap.action_add_event(action, event)

func _bind_joy_button(action: StringName, button_index: int) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    var event := InputEventJoypadButton.new()
    event.button_index = button_index
    InputMap.action_add_event(action, event)

func _bind_joy_axis(action: StringName, axis: int, axis_value: float) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    var event := InputEventJoypadMotion.new()
    event.axis = axis
    event.axis_value = axis_value
    InputMap.action_add_event(action, event)
