extends Node2D

@export var duration_seconds: float = 60.0
var time_left := duration_seconds

func _ready():
    time_left = duration_seconds
    print("Game started: survive for %s seconds" % duration_seconds)

func _process(delta: float) -> void:
    if time_left > 0:
        time_left -= delta
        # TODO: update UI (remaining time)
    else:
        # Time up
        # TODO: trigger win/score screen
        pass
