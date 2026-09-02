extends Node2D

@export var bullet_scene_path: String = "res://scenes/Bullet.tscn"
@export var shoot_interval: float = 0.6
@export var pattern_duration: float = 6.0

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

func _spawn_bullet(angle_radians: float, speed: float = 200.0) -> void:
    if _bullet_scene == null:
        return
    var b = _bullet_scene.instantiate()
    get_parent().add_child(b)
    b.position = global_position
    b.velocity = Vector2(cos(angle_radians), sin(angle_radians)).normalized() * speed

func _pattern_fan() -> void:
    # wide fan downward: 11 bullets spread over 120 degrees centered down
    var count = 11
    var base = deg2rad(90)
    var spread = deg2rad(120)
    for i in range(count):
        var denom = float(count - 1) if count > 1 else 1.0
        var offset = (float(i) - (float(count - 1) / 2.0))
        var angle = base + (offset * (spread / denom))
        _spawn_bullet(angle, 160.0)

func _pattern_aimed_bursts() -> void:
    # 3 quick aimed shots to player's current position with small spread
    var player = null
    if get_parent() and get_parent().has_node("Player"):
        player = get_parent().get_node("Player")
    if player == null:
        return
    var dir = (player.global_position - global_position).angle()
    var shots = 3
    var spread = deg2rad(8)
    for i in range(shots):
        var offset = (float(i) - (float(shots - 1) / 2.0))
        var angle = dir + (offset * spread)
        _spawn_bullet(angle, 260.0)

func _pattern_circle_burst() -> void:
    # circular burst: 20 bullets in full circle
    var count = 20
    for i in range(count):
        var angle = TAU * float(i) / float(count)
        _spawn_bullet(angle, 140.0)

func _draw() -> void:
    # simple boss visual (rectangle + eye)
    draw_rect(Rect2(Vector2(-56, -40), Vector2(112, 80)), Color(0.6,0.1,0.6,1))
    draw_circle(Vector2(0, -8), 8, Color(1,1,1,1))
