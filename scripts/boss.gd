extends Node2D

@export var bullet_scene_path: String = "res://scenes/Bullet.tscn"
@export var shoot_interval: float = 0.6
@export var pattern_duration: float = 6.0

# multiple size/speed options (px) - default values (will be overridden by stage)
@export var bullet_sizes: Array = [4.0, 6.0, 10.0]
@export var bullet_speeds: Array = [90.0, 130.0, 180.0]

# pattern parameters (defaults)
var _fan_count: int = 11
var _aimed_shots: int = 3
var _circle_count: int = 20

var _shoot_timer: Timer
var _pattern_timer: Timer
var _bullet_scene: PackedScene
var _pattern_index: int = 0
var _spiral_angle: float = 0.0
var _pattern_count: int = 6

func _ready() -> void:
    randomize()
    _bullet_scene = preload(bullet_scene_path)

    # place boss near top center and keep inside screen
    var r = get_viewport_rect()
    position.x = clamp(position.x, 80, r.size.x - 80)

    # shoot timer
    _shoot_timer = Timer.new()
    _shoot_timer.wait_time = shoot_interval
    _shoot_timer.one_shot = false
    _shoot_timer.autostart = true
    add_child(_shoot_timer)
    _shoot_timer.connect("timeout", Callable(self, "_on_shoot_timeout"))

    # pattern switch timer
    _pattern_timer = Timer.new()
    _pattern_timer.wait_time = pattern_duration
    _pattern_timer.one_shot = false
    _pattern_timer.autostart = true
    add_child(_pattern_timer)
    _pattern_timer.connect("timeout", Callable(self, "_on_pattern_timeout"))

func set_stage(stage: int) -> void:
    # 0 = Easy, 1 = Normal, 2 = Hard
    match stage:
        0:
            bullet_sizes = [6.0, 8.0]
            bullet_speeds = [70.0, 110.0]
            shoot_interval = 0.9
            pattern_duration = 7.0
            _fan_count = 7
            _aimed_shots = 2
            _circle_count = 12
            _pattern_count = 4
        1:
            bullet_sizes = [4.0, 6.0, 8.0]
            bullet_speeds = [90.0, 130.0, 180.0]
            shoot_interval = 0.7
            pattern_duration = 6.0
            _fan_count = 11
            _aimed_shots = 3
            _circle_count = 20
            _pattern_count = 5
        2:
            bullet_sizes = [3.0, 5.0, 7.0]
            bullet_speeds = [120.0, 170.0, 230.0]
            shoot_interval = 0.55
            pattern_duration = 5.0
            _fan_count = 15
            _aimed_shots = 5
            _circle_count = 30
            _pattern_count = 6
    # update timers if already created
    if _shoot_timer and _shoot_timer.is_inside_tree():
        _shoot_timer.wait_time = shoot_interval
    if _pattern_timer and _pattern_timer.is_inside_tree():
        _pattern_timer.wait_time = pattern_duration

func _process(delta: float) -> void:
    # subtle horizontal bobbing for visual motion, stays on screen
    var r = get_viewport_rect()
    position.x = r.size.x * 0.5 + sin(OS.get_ticks_msec() / 800.0) * 60.0

func _on_pattern_timeout() -> void:
    _pattern_index = (_pattern_index + 1) % _pattern_count

func _on_shoot_timeout() -> void:
    match _pattern_index:
        0:
            _pattern_fan()
        1:
            _pattern_aimed_bursts()
        2:
            _pattern_circle_burst()
        3:
            _pattern_spiral()
        4:
            _pattern_double_spiral()
        5:
            _pattern_slow_dense()
        _:
            _pattern_fan()

func _get_pool() -> Node:
    if get_parent() and get_parent().has_node("BulletPool"):
        return get_parent().get_node("BulletPool")
    return null

func _spawn_bullet(angle_radians: float, speed_override: float = 0.0, size_override: float = 0.0) -> void:
    var pool = _get_pool()
    var size = size_override if size_override > 0.0 else bullet_sizes[randi() % bullet_sizes.size()]
    var spd = speed_override if speed_override > 0.0 else bullet_speeds[randi() % bullet_speeds.size()]
    var vel = Vector2(cos(angle_radians), sin(angle_radians)).normalized() * spd

    # color by size
    var col = Color(1,1,0.2,1) if size <= 4.0 else (Color(1,0.6,0,1) if size <= 6.0 else Color(1,0.2,0.2,1))

    if pool:
        var b = pool.get_bullet()
        if b:
            b.activate(global_position, vel, size, col)
            return
    # fallback: instantiate directly
    if _bullet_scene != null:
        var b = _bullet_scene.instantiate()
        get_parent().add_child(b)
        if b.has_method("activate"):
            b.activate(global_position, vel, size, col)
        else:
            # best-effort fallback
            b.position = global_position
            b.velocity = vel
            b.radius = size
            b.color = col

func _pattern_fan() -> void:
    # wide fan downward using _fan_count
    var count = max(1, _fan_count)
    var base = deg2rad(90)
    var spread = deg2rad(120)
    for i in range(count):
        var denom = float(count - 1) if count > 1 else 1.0
        var offset = (float(i) - (float(count - 1) / 2.0))
        var angle = base + (offset * (spread / denom))
        var mid_index = int(floor(float(bullet_sizes.size()) / 2.0))
        var size_choice = bullet_sizes[mid_index]
        var speed_choice = bullet_speeds[mid_index % bullet_speeds.size()]
        _spawn_bullet(angle, speed_override=speed_choice, size_override=size_choice)

func _pattern_aimed_bursts() -> void:
    # aimed shots to player's current position with small spread
    var player = null
    if get_parent() and get_parent().has_node("Player"):
        player = get_parent().get_node("Player")
    if player == null:
        return
    var dir = (player.global_position - global_position).angle()
    var shots = max(1, _aimed_shots)
    var spread = deg2rad(8)
    for i in range(shots):
        var offset = (float(i) - (float(shots - 1) / 2.0))
        var angle = dir + (offset * spread)
        var small = bullet_sizes[0]
        var fast = bullet_speeds[bullet_speeds.size() - 1]
        _spawn_bullet(angle, speed_override=fast, size_override=small)

func _pattern_circle_burst() -> void:
    # circular burst using _circle_count bullets, mixed sizes and speeds
    var count = max(1, _circle_count)
    for i in range(count):
        var angle = TAU * float(i) / float(count)
        var size_choice = bullet_sizes[i % bullet_sizes.size()]
        var speed_choice = bullet_speeds[i % bullet_speeds.size()]
        _spawn_bullet(angle, speed_override=speed_choice, size_override=size_choice)

func _pattern_spiral() -> void:
    # rotating spiral: spawn a few bullets each tick and advance the base angle
    var per_tick = 3
    var gap = deg2rad(10)
    for i in range(per_tick):
        var angle = _spiral_angle + i * gap
        # small-medium speed/size
        _spawn_bullet(angle, size_override=bullet_sizes[0])
    _spiral_angle += deg2rad(8)

func _pattern_double_spiral() -> void:
    # two spirals rotating opposite directions
    var per_tick = 2
    var gap = deg2rad(6)
    for i in range(per_tick):
        var angle1 = _spiral_angle + i * gap
        var angle2 = -_spiral_angle + i * gap
        _spawn_bullet(angle1, size_override=bullet_sizes[1])
        _spawn_bullet(angle2, size_override=bullet_sizes[1])
    _spiral_angle += deg2rad(12)

func _pattern_slow_dense() -> void:
    # dense curtain of slower bullets filling a wide band
    var count = max(6, int(_fan_count * 1.2))
    var base = deg2rad(90)
    var spread = deg2rad(60)
    for i in range(count):
        var denom = float(count - 1) if count > 1 else 1.0
        var offset = (float(i) - (float(count - 1) / 2.0))
        var angle = base + (offset * (spread / denom))
        var size_choice = bullet_sizes[1 if bullet_sizes.size() > 1 else 0]
        var speed_choice = bullet_speeds[0] if bullet_speeds.size() > 0 else 90.0
        _spawn_bullet(angle, speed_override=speed_choice, size_override=size_choice)

func _draw() -> void:
    # simple boss visual (rectangle + eye)
    draw_rect(Rect2(Vector2(-56, -40), Vector2(112, 80)), Color(0.6,0.1,0.6,1))
    draw_circle(Vector2(0, -8), 8, Color(1,1,1,1))
