extends Node

const SAVE_PATH := "user://progress.cfg"
const SECTION := "stages"
const KEY_CLEARED := "cleared"

static func _ensure_list(v):
    if typeof(v) == TYPE_ARRAY:
        return v
    return []

static func load_cleared_stages() -> Array:
    var cfg := ConfigFile.new()
    var err = cfg.load(SAVE_PATH)
    if err != OK:
        return []
    var arr = cfg.get_value(SECTION, KEY_CLEARED, [])
    return _ensure_list(arr)

static func is_stage_cleared(stage: int) -> bool:
    var arr = load_cleared_stages()
    return stage in arr

static func save_stage_cleared(stage: int) -> void:
    var cfg := ConfigFile.new()
    var err = cfg.load(SAVE_PATH)
    # if load failed we still continue with empty cfg
    var arr = cfg.get_value(SECTION, KEY_CLEARED, [])
    arr = _ensure_list(arr)
    if stage in arr:
        return
    arr.append(stage)
    cfg.set_value(SECTION, KEY_CLEARED, arr)
    cfg.save(SAVE_PATH)
