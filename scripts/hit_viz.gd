extends Node2D

@export var radius: float = 5.0
@export var color: Color = Color(1, 0, 0, 0.8)

func _ready() -> void:
    update()

func _draw() -> void:
    draw_circle(Vector2.ZERO, radius, color)
