extends Control

func _ready() -> void:
    # UI が停止中でも入力を受け取るようにする
    pause_mode = Node.PAUSE_MODE_PROCESS

    # フルスクリーンの親 Control にする
    set_anchors_preset(Control.PRESET_FULL_RECT)

    # 背景パネル（半透明）
    var bg = ColorRect.new()
    bg.color = Color(0, 0, 0, 0.6)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    # 中央のパネル
    var panel = Panel.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.set_size(Vector2(520, 220))
    add_child(panel)

    # レイアウト用 VBox
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

    # タイトルラベル
    var title = Label.new()
    title.text = "クリア！"
    title.horizontal_alignment = Label.HALIGN_CENTER
    title.vertical_alignment = Label.VALIGN_CENTER
    title.add_theme_font_size_override("font_size", 48)
    vbox.add_child(title)

    # スペーサ
    var spacer = Control.new()
    spacer.custom_minimum_size = Vector2(0, 16)
    vbox.add_child(spacer)

    # ボタン行
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

    # フォーカスをボタンに移す
    btn_replay.grab_focus()

func _on_replay_pressed() -> void:
    # UI を消して一時停止を解除してリロードする
    queue_free()
    get_tree().paused = false
    # Godot 4: reload_current_scene() を使って現在のシーンをやり直す
    if Engine.has_singleton("SceneTree"):
        # 安全のため try/catch 相当の書き方
        get_tree().reload_current_scene()
    else:
        # フォールバック：Main シーンに戻す（必要に応じてパスを変更）
        get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_title_pressed() -> void:
    queue_free()
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/Title.tscn")
