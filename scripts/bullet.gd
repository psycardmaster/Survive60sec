extends Area2D

@export var radius: float = 6.0
@export var color: Color = Color(1,0.6,0,1)
var velocity: Vector2 = Vector2.ZERO
@export var despawn_margin: int = 64

# Pool reference will be set by BulletPool when instantiated
var pool = null
var active: bool = false

func _ready() -> void:
    # Ensure collision shape exists
    if has_node("CollisionShape2D") and $CollisionShape2D.shape and $CollisionShape2D.shape is CircleShape2D:
        $CollisionShape2D.shape.radius = radius
    update()
    connect("area_entered", Callable(self, "_on_area_entered"))

func activate(pos: Vector2, vel: Vector2, r: float, col: Color) -> void:
    position = pos
    velocity = vel
    radius = r
    color = col
    active = true
    visible = true
    # update collision shape radius if present
    if has_node("CollisionShape2D") and $CollisionShape2D.shape and $CollisionShape2D.shape is CircleShape2D:
        $CollisionShape2D.shape.radius = radius
    # ensure monitoring
    monitoring = true
    # make sure it's processed
    set_process(true)
    update()

func deactivate() -> void:
    active = false
    visible = false
    velocity = Vector2.ZERO
    # disable monitoring to avoid stray collisions
    monitoring = false
    set_process(false)

func _process(delta: float) -> void:
    if not active:
        return
    position += velocity * delta
    var r = get_viewport_rect()
    if position.x < -despawn_margin or position.x > r.size.x + despawn_margin or position.y < -despawn_margin or position.y > r.size.y + despawn_margin:
        if pool:
            pool.release(self)
        else:
            queue_free()

func _on_area_entered(area) -> void:
    # collide with player's HitArea
    if area.name == "HitArea" or (area.get_parent() and area.get_parent().name == "Player"):
        if pool:
            pool.release(self)
        else:
            queue_free()

func _draw() -> void:
    if active:
        draw_circle(Vector2.ZERO, radius, color)
