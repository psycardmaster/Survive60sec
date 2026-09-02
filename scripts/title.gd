extends Control

var selected_stage: int = 1 # 0=Easy,1=Normal,2=Hard

func _ready() -> void:
    # create a simple UI programmatically to avoid complex tscn edits
    var v = VBoxContainer.new()
    v.anchor_left = 0.25
    v.anchor_top = 0.25
    v.anchor_right = 0.75
    v.anchor_bottom = 0.75
    add_child(v)

    var title = Label.new()
    title.text = "Survive 60 Seconds"
    title.align = Label.ALIGN_CENTER
    v.add_child(title)

    var hint = Label.new()
    hint.text = "Select Stage"
    hint.align = Label.ALIGN_CENTER
    v.add_child(hint)

    var btn_easy = Button.new()
    btn_easy.text = "Easy"
    btn_easy.name = "EasyButton"
    v.add_child(btn_easy)
    btn_easy.pressed = false
    btn_easy.connect("pressed", Callable(self, "_on_stage_selected"), [0])

    var btn_norm = Button.new()
    btn_norm.text = "Normal"
    btn_norm.name = "NormalButton"
    v.add_child(btn_norm)
    btn_norm.connect("pressed", Callable(self, "_on_stage_selected"), [1])

    var btn_hard = Button.new()
    btn_hard.text = "Hard"
    btn_hard.name = "HardButton"
    v.add_child(btn_hard)
    btn_hard.connect("pressed", Callable(self, "_on_stage_selected"), [2])

    var start = Button.new()
    start.text = "Start"
    start.name = "StartButton"
    v.add_child(start)
    start.connect("pressed", Callable(self, "_on_start_pressed"))

    # visual selection feedback
    _update_button_states()

func _on_stage_selected(stage: int) -> void:
    selected_stage = stage
    _update_button_states()

func _update_button_states() -> void:
    for child in get_children():
        if child is VBoxContainer:
            for c in child.get_children():
                if c is Button:
                    c.toggle_mode = false
    # simple label update
    var sel_label = Label.new()
    # no-op — keep UI minimal

func _on_start_pressed() -> void:
    var main_scene = preload("res://scenes/Main.tscn")
    var main = main_scene.instantiate()
    # set the stage on the Main node (game.gd exports stage)
    if main.has_method("set"):
        main.set("stage", selected_stage)
    else:
        main.stage = selected_stage
    var root = get_tree().get_root()
    root.add_child(main)
    queue_free()
