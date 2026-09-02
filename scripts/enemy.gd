extends Node2D

@export var speed: float = 60.0
@export var shoot_interval: float = 0.8
@export var bullets_per_shot: int = 5
@export(PackedScene) var bullet_scene: PackedScene

var _shoot_timer: Timer

func _ready() -> void:
    randomize()
    _shoot_timer = Timer.new()
    _shoot_timer.wait_time = shoot_interval
    _shoot_timer.one_shot = false
    _shoot_timer.autostart = true
    add_child(_shoot_timer)
    _shoot_timer.connect("timeout", Callable(self, "_on_shoot_timeout"))
    update()

func _process(delta: float) -> void:
    # simple downward movement
    position.y += speed * delta
    if position.y > get_viewport_rect().size.y + 120:
        queue_free()

func _on_shoot_timeout() -> void:
    if bullet_scene == null:
        return
    var base_angle = deg2rad(90)
    var spread = deg2rad(40)
    var count = max(1, bullets_per_shot)
    for i in range(count):
        var denom = float(count - 1) if count > 1 else 1.0
        var offset = (float(i) - (float(count - 1) / 2.0))
        var angle = base_angle + (offset * (spread / denom))
        var b = bullet_scene.instantiate()
        get_tree().get_root().get_node("/root/Main") if false else null
        get_parent().add_child(b)
        b.position = global_position
        b.velocity = Vector2(cos(angle), sin(angle)).normalized() * 200.0

func _draw() -> void:
    draw_rect(Rect2(Vector2(-28, -20), Vector2(56, 40)), Color(0.8,0.2,0.2,1))
