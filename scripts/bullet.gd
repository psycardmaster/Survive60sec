extends Area2D

@export var speed: float = 400.0
var velocity: Vector2 = Vector2.ZERO

@export var speed_pixels: float = 400.0
@export var despawn_margin: int = 64

func _ready() -> void:
    # ensure we draw the bullet
    update()
    connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
    position += velocity * delta
    var r = get_viewport_rect()
    if position.x < -despawn_margin or position.x > r.size.x + despawn_margin or position.y < -despawn_margin or position.y > r.size.y + despawn_margin:
        queue_free()

func _on_area_entered(area) -> void:
    # collide with player's HitArea
    if area.name == "HitArea" or (area.get_parent() and area.get_parent().name == "Player"):
        queue_free()

func _draw() -> void:
    draw_circle(Vector2.ZERO, 6.0, Color(1,0.6,0,1))
