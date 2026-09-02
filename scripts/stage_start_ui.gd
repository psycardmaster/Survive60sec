extends Control

var stage_number: int = 1
var _on_done_callable: Callable = null

func _ready() -> void:
    pause_mode = Node.PAUSE_MODE_PROCESS
    set_anchors_preset(Control.PRESET_FULL_RECT)

    var bg = ColorRect.new()
    bg.color = Color(0,0,0,0.6)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var label = Label.new()
    label.name = "MainLabel"
    label.text = "Stage %d" % stage_number
    label.horizontal_alignment = Label.HALIGN_CENTER
    label.vertical_alignment = Label.VALIGN_CENTER
    label.add_theme_font_size_override("font_size", 48)
    label.set_anchors_preset(Control.PRESET_CENTER)
    add_child(label)

    # run the simple sequence asynchronously
    _run_sequence()

func _run_sequence() -> void:
    var label = $MainLabel
    # show Stage N
    label.text = "Stage %d" % stage_number
    await get_tree().create_timer(0.8).timeout

    # countdown
    for i in [3,2,1]:
        label.text = "%d" % i
        await get_tree().create_timer(0.6).timeout

    # go
    label.text = "GO!"
    await get_tree().create_timer(0.5).timeout

    # call done callback
    if _on_done_callable and _on_done_callable.is_valid():
        _on_done_callable.call()

    queue_free()

func set_stage(n: int) -> void:
    stage_number = n

func set_on_done(callable_obj: Callable) -> void:
    _on_done_callable = callable_obj
