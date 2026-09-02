extends Area2D

@export var radius: float = 6.0
@export var color: Color = Color(1,0.6,0,1)
var velocity: Vector2 = Vector2.ZERO
var accel: Vector2 = Vector2.ZERO
@export var despawn_margin: int = 64
@export var needle_threshold: float = 4.5 # sizes <= this are drawn as needle

# homing support
var homing: bool = false
var homing_strength: float = 0.0
var homing_time_left: float = 0.0
var homing_target = null

# Pool reference will be set by BulletPool when instantiated
var pool = null
var active: bool = false
var age: float = 0.0
var _is_needle: bool = false

func _ready() -> void:
    # Ensure collision shape exists
    if has_node("CollisionShape2D") and $CollisionShape2D.shape:
        # keep existing shape as-is, we'll overwrite in activate depending on size
        pass
    update()
    connect("area_entered", Callable(self, "_on_area_entered"))

# accel is optional; hom_target/hom_strength/hom_duration are optional
func activate(pos: Vector2, vel: Vector2, r: float, col: Color, a: Vector2 = Vector2.ZERO, hom_target = null, hom_strength: float = 0.0, hom_duration: float = 0.0) -> void:
    position = pos
    velocity = vel
    accel = a
    radius = r
    color = col
    active = true
    visible = true
    age = 0.0
    _is_needle = radius <= needle_threshold

    # homing setup
    homing = hom_target != null and hom_strength > 0.0 and hom_duration > 0.0
    homing_target = hom_target if homing else null
    homing_strength = hom_strength
    homing_time_left = hom_duration

    # update collision shape based on shape choice
    if has_node("CollisionShape2D"):
        if _is_needle:
            var cap = CapsuleShape2D.new()
            # radius for capsule should be small relative to bullet radius
            cap.radius = max(1.0, radius * 0.45)
            # height controls the length of the needle; ensure a minimum length
            cap.height = max(12.0, radius * 6.0)
            $CollisionShape2D.shape = cap
        else:
            var cir = CircleShape2D.new()
            cir.radius = radius
            $CollisionShape2D.shape = cir

    # set orientation so needle points along velocity direction
    if _is_needle and velocity.length() > 0.001:
        rotation = velocity.angle()
    else:
        rotation = 0.0

    # ensure monitoring
    monitoring = true
    # make sure it's processed
    set_process(true)
    update()

func deactivate() -> void:
    active = false
    visible = false
    velocity = Vector2.ZERO
    accel = Vector2.ZERO
    age = 0.0
    _is_needle = false
    rotation = 0.0
    # clear homing
    homing = false
    homing_strength = 0.0
    homing_time_left = 0.0
    homing_target = null
    # disable monitoring to avoid stray collisions
    monitoring = false
    set_process(false)

func _process(delta: float) -> void:
    if not active:
        return
    age += delta
    # homing: adjust velocity toward target direction if active
    if homing and homing_time_left > 0.0 and homing_target and homing_target.is_inside_tree():
        var to_target = (homing_target.global_position - position)
        if to_target.length() > 0.01:
            var desired = to_target.normalized() * velocity.length()
            # interpolate velocity toward desired; homing_strength is in "per-second" units
            var factor = clamp(homing_strength * delta, 0.0, 1.0)
            velocity = velocity.linear_interpolate(desired, factor)
        homing_time_left -= delta
        if homing_time_left <= 0.0:
            homing = false
            homing_target = null

    # integrate velocity with optional acceleration
    velocity += accel * delta
    position += velocity * delta

    # if needle, keep rotation aligned with velocity
    if _is_needle and velocity.length() > 0.001:
        rotation = velocity.angle()

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
    if not active:
        return
    if _is_needle:
        # draw a thin needle pointing to the right (rotation set in activate/_process)
        var len = max(12.0, radius * 6.0)
        var half_th = max(1.0, radius * 0.6)
        var p1 = Vector2(len * 0.5, 0)               # tip
        var p2 = Vector2(-len * 0.5, half_th)       # back-bottom
        var p3 = Vector2(-len * 0.5, -half_th)      # back-top
        draw_polygon([p1, p2, p3], [color])
        # optional thin outline for visibility
        draw_polyline([p1, p2, p3, p1], Color(0,0,0,0.4), 1.0)
    else:
        # if homing and not needle, draw a distinct homing graphic (ring + dot)
        if homing:
            # outer ring
            draw_circle(Vector2.ZERO, radius * 1.4, Color(0.2, 0.9, 1.0, 0.9))
            # inner fill
            draw_circle(Vector2.ZERO, radius * 0.9, Color(0.05, 0.35, 0.9, 1.0))
            # center highlight
            draw_circle(Vector2.ZERO, radius * 0.35, Color(1,1,1,0.9))
        else:
            draw_circle(Vector2.ZERO, radius, color)
