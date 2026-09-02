extends Control

var remaining_time: float = 0.0
var _time_label: Label

func _ready() -> void:
    # UI が一時停止中でも入力を受け取る
    pause_mode = Node.PAUSE_MODE_PROCESS

    # フルスクリーンカバー
    set_anchors_preset(Control.PRESET_FULL_RECT)

    var bg = ColorRect.new()
    bg.color = Color(0, 0, 0, 0.6)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var panel = Panel.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.set_size(Vector2(520, 260))
    add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.anchor_left = 0
    vbox.anchor_top = 0
    vbox.anchor_right = 1
    vbox.anchor_bottom = 1
    vbox.set_margin(Margin.LEFT, 12)
    vbox.set_margin(Margin.TOP, 12)
    vbox.set_margin(Margin.RIGHT, 12)
    vbox.set_margin(Margin.BOTTOM, 12)
    panel.add_child(vbox)

    var title = Label.new()
    title.text = "失敗..."
    title.horizontal_alignment = Label.HALIGN_CENTER
    title.vertical_alignment = Label.VALIGN_CENTER
    title.add_theme_font_size_override("font_size", 48)
    vbox.add_child(title)

    # 残り時間ラベル
    _time_label = Label.new()
    _time_label.text = "残り時間: --"
    _time_label.horizontal_alignment = Label.HALIGN_CENTER
    _time_label.add_theme_font_size_override("font_size", 24)
    vbox.add_child(_time_label)

    # スペーサ
    var spacer = Control.new()
    spacer.custom_minimum_size = Vector2(0, 12)
    vbox.add_child(spacer)

    var hbox = HBoxContainer.new()
    hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.add_child(hbox)

    var btn_replay = Button.new()
    btn_replay.text = "リプレイ"
    btn_replay.connect("pressed", Callable(self, "_on_replay_pressed"))
    hbox.add_child(btn_replay)

    var btn_title = Button.new()
    btn_title.text = "タイトルへ戻る"
    btn_title.connect("pressed", Callable(self, "_on_title_pressed"))
    hbox.add_child(btn_title)

    btn_replay.grab_focus()

    # 初期表示を更新
    _update_time_label()

func set_remaining_time(t: float) -> void:
    remaining_time = t
    _update_time_label()

func _update_time_label() -> void:
    if _time_label:
        # 表示は秒、2 桁の小数で表示
        _time_label.text = "残り時間: %.2f 秒" % remaining_time

func _on_replay_pressed() -> void:
    queue_free()
    get_tree().paused = false
    # Godot 4 のリロードを使う（環境により動かない場合は代替でシーン読み直し）
    if Engine.has_singleton("SceneTree"):
        get_tree().reload_current_scene()
    else:
        get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_title_pressed() -> void:
    queue_free()
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/Title.tscn")
