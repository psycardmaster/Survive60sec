extends CharacterBody2D

signal hit

@export var speed: float = 600.0
var target_pos: Vector2
var invincible: bool = false
@export var invincible_duration: float = 1.0

func _ready() -> void:
    target_pos = position
    # connect hit area signals
    if has_node("HitArea"):
        $HitArea.connect("body_entered", Callable(self, "_on_hit_area_body_entered"))
        $HitArea.connect("area_entered", Callable(self, "_on_hit_area_body_entered"))
    # ensure HitViz updates
    if has_node("HitViz"):
        $HitViz.update()

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

func _on_hit_area_body_entered(body) -> void:
    if invincible:
        return
    # destroy the colliding body (e.g., bullet) if possible
    if body and body.is_instance_valid():
        if body.has_method("queue_free"):
            body.queue_free()
    invincible = true
    emit_signal("hit")
    # visual feedback: dim the hit indicator
    if has_node("HitViz"):
        $HitViz.modulate = Color(1,1,1,0.4)
    # invincibility duration
    await get_tree().create_timer(invincible_duration).timeout
    invincible = false
    if has_node("HitViz"):
        $HitViz.modulate = Color(1,1,1,1)
