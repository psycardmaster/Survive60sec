extends Node2D

@export var duration_seconds: float = 60.0
var time_left := duration_seconds

func _ready():
    time_left = duration_seconds
    print("Game started: survive for %s seconds" % duration_seconds)
    if has_node("Player"):
        $Player.connect("hit", Callable(self, "_on_player_hit"))

func _process(delta: float) -> void:
    if time_left > 0:
        time_left -= delta
    else:
        pass

func _on_player_hit() -> void:
    print("Player was hit! Game over.")
    time_left = 0
