extends CharacterBody2D

@export var speed: float = 600.0
var target_pos: Vector2

func _ready() -> void:
    target_pos = position

func _process(delta: float) -> void:
    # Mobile: touch input
    var touch_count := Input.get_touch_count()
    if touch_count > 0:
        # use first touch
        target_pos = Input.get_touch_position(0)
    elif Input.is_mouse_button_pressed(MouseButton.LEFT):
        target_pos = get_viewport().get_mouse_position()

    var dir := target_pos - position
    if dir.length() > 8:
        position += dir.normalized() * speed * delta
