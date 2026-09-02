extends Node

@export(PackedScene) var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
@export var initial_size: int = 64

var _pool: Array = []

func _ready() -> void:
    # Pre-instantiate bullets and keep them inactive
    for i in range(initial_size):
        var b = bullet_scene.instantiate()
        add_child(b)
        if b.has_method("deactivate"):
            b.deactivate()
        b.pool = self
        _pool.append(b)

func get_bullet() -> Node:
    if _pool.size() == 0:
        var b = bullet_scene.instantiate()
        add_child(b)
        b.pool = self
        if b.has_method("deactivate"):
            b.deactivate()
        return b
    return _pool.pop_back()

func release(bullet: Node) -> void:
    if bullet == null:
        return
    # reset state and return to pool
    if bullet.has_method("deactivate"):
        bullet.deactivate()
    _pool.append(bullet)
