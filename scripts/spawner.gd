extends Node2D

@export(PackedScene) var enemy_scene: PackedScene
@export var spawn_interval: float = 1.6

var _timer: Timer

func _ready() -> void:
    randomize()
    _timer = Timer.new()
    _timer.wait_time = spawn_interval
    _timer.one_shot = false
    _timer.autostart = true
    add_child(_timer)
    _timer.connect("timeout", Callable(self, "_on_spawn_timeout"))

func _on_spawn_timeout() -> void:
    if enemy_scene == null:
        return
    var e = enemy_scene.instantiate()
    get_parent().add_child(e)
    var w = get_viewport_rect().size.x
    var x = randi() % int(max(1, w - 40)) + 20
    e.position = Vector2(x, -60)
    # point enemy to bullet scene
    e.bullet_scene = preload("res://scenes/Bullet.tscn")
