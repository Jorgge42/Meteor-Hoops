class_name ComicReader
extends Control

signal finished

var chapter: StoryChapter
var page_index := 0
var page_rect: TextureRect
var title_label: Label
var counter_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _build_ui()

func setup(new_chapter: StoryChapter) -> void:
    chapter = new_chapter
    page_index = 0
    if is_node_ready():
        _show_page()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.015, 0.018, 0.025, 1.0)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 18)
    root.add_theme_constant_override("separation", 10)
    add_child(root)

    title_label = Label.new()
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 28)
    root.add_child(title_label)

    page_rect = TextureRect.new()
    page_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
    page_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    page_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
    page_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.add_child(page_rect)

    var footer := HBoxContainer.new()
    footer.alignment = BoxContainer.ALIGNMENT_CENTER
    root.add_child(footer)

    var prev := Button.new()
    prev.text = "< ANTERIOR"
    prev.pressed.connect(_previous_page)
    footer.add_child(prev)

    counter_label = Label.new()
    counter_label.custom_minimum_size.x = 130
    counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.add_child(counter_label)

    var next := Button.new()
    next.text = "PRÓXIMA >"
    next.pressed.connect(_next_page)
    footer.add_child(next)

    _show_page()

func _show_page() -> void:
    if chapter == null or chapter.pages.is_empty() or page_rect == null:
        return
    page_index = clampi(page_index, 0, chapter.pages.size() - 1)
    title_label.text = chapter.title
    page_rect.texture = chapter.pages[page_index]
    counter_label.text = "%d / %d" % [page_index + 1, chapter.pages.size()]

func _previous_page() -> void:
    if page_index > 0:
        page_index -= 1
        _show_page()

func _next_page() -> void:
    if chapter == null:
        return
    if page_index < chapter.pages.size() - 1:
        page_index += 1
        _show_page()
    else:
        finished.emit()
