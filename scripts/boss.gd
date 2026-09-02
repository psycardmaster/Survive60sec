extends Node2D

@export var bullet_scene_path: String = "res://scenes/Bullet.tscn"
@export var shoot_interval: float = 0.6
@export var pattern_duration: float = 6.0

# multiple size/speed options (px) - default values (will be overridden by stage)
@export var bullet_sizes: Array = [4.0, 6.0, 10.0]
@export var bullet_speeds: Array = [140.0, 200.0, 260.0]

# pattern parameters (defaults)
var _fan_count: int = 11
var _aimed_shots: int = 3
var _circle_count: int = 20

var _shoot_timer: Timer
var _pattern_timer: Timer
var _bullet_scene: PackedScene
var _pattern_index: int = 0

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
            bullet_speeds = [100.0, 160.0]
            shoot_interval = 0.8
            pattern_duration = 7.0
            _fan_count = 7
            _aimed_shots = 2
            _circle_count = 12
        1:
            bullet_sizes = [4.0, 6.0, 10.0]
            bullet_speeds = [140.0, 200.0, 260.0]
            shoot_interval = 0.6
            pattern_duration = 6.0
            _fan_count = 11
            _aimed_shots = 3
            _circle_count = 20
        2:
            bullet_sizes = [3.0, 5.0, 8.0]
            bullet_speeds = [180.0, 260.0, 340.0]
            shoot_interval = 0.45
            pattern_duration = 5.0
            _fan_count = 15
            _aimed_shots = 5
            _circle_count = 30
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
    _pattern_index = (_pattern_index + 1) % 3

func _on_shoot_timeout() -> void:
    match _pattern_index:
        0:
            _pattern_fan()
        1:
            _pattern_aimed_bursts()
        2:
            _pattern_circle_burst()
        _:
            _pattern_fan()

func _spawn_bullet(angle_radians: float, speed_override: float = 0.0, size_override: float = 0.0) -> void:
    if _bullet_scene == null:
        return
    var b = _bullet_scene.instantiate()
    # attach to main scene (parent is Main)
    get_parent().add_child(b)
    b.position = global_position

    # choose size
    var size = size_override if size_override > 0.0 else bullet_sizes[randi() % bullet_sizes.size()]
    b.radius = size

    # choose speed
    var spd = speed_override if speed_override > 0.0 else bullet_speeds[randi() % bullet_speeds.size()]
    b.velocity = Vector2(cos(angle_radians), sin(angle_radians)).normalized() * spd

    # color by size for readability (small=yellow, medium=orange, large=red)
    if size <= 4.0:
        b.color = Color(1,1,0.2,1)
    elif size <= 6.0:
        b.color = Color(1,0.6,0,1)
    else:
        b.color = Color(1,0.2,0.2,1)

func _pattern_fan() -> void:
    # wide fan downward using _fan_count
    var count = max(1, _fan_count)
    var base = deg2rad(90)
    var spread = deg2rad(120)
    for i in range(count):
        var denom = float(count - 1) if count > 1 else 1.0
        var offset = (float(i) - (float(count - 1) / 2.0))
        var angle = base + (offset * (spread / denom))
        # choose medium sizes and medium speed when possible
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
        # small fast bullets
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

func _draw() -> void:
    # simple boss visual (rectangle + eye)
    draw_rect(Rect2(Vector2(-56, -40), Vector2(112, 80)), Color(0.6,0.1,0.6,1))
    draw_circle(Vector2(0, -8), 8, Color(1,1,1,1))
