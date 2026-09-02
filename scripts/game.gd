extends Node2D

@export var duration_seconds: float = 60.0
@export var stage: int = 1 # 0=Easy,1=Normal,2=Hard
var time_left := duration_seconds

# countdown notification state
var _notified_30: bool = false
var _notified_15: bool = false
var _last_whole_second: int = -1
var _cleared: bool = false
var _failed: bool = false

# audio: generator-based beep/tick system
var _audio_gen: AudioStreamGenerator
var _audio_player: AudioStreamGeneratorPlayer
var _audio_playback
var _mix_rate: int = 44100
var _active_beeps: Array = [] # each: {freq, total_samples, sample_pos, volume}

func _ready():
    time_left = duration_seconds
    print("Game started: survive for %s seconds" % duration_seconds)
    if has_node("Player"):
        $Player.connect("hit", Callable(self, "_on_player_hit"))

    # initialize audio generator player for synthesized beeps
    _audio_gen = AudioStreamGenerator.new()
    _audio_gen.mix_rate = _mix_rate
    _audio_gen.buffer_length = 0.2
    _audio_player = AudioStreamGeneratorPlayer.new()
    _audio_player.stream = _audio_gen
    add_child(_audio_player)
    _audio_player.play()
    _audio_playback = _audio_player.get_stream_playback()

    # initialize last whole second so ticks occur properly
    _last_whole_second = int(floor(time_left)) + 1

func _process(delta: float) -> void:
    if time_left > 0:
        time_left -= delta

        # 30s and 15s notifications
        if not _notified_30 and time_left <= 30.0:
            _notified_30 = true
            _play_beep(880.0, 0.18, 0.7) # higher pitched beep for 30s
        if not _notified_15 and time_left <= 15.0:
            _notified_15 = true
            _play_beep(740.0, 0.18, 0.8) # slightly lower pitch for 15s

        # per-second ticks from 10s down to 1s
        var current_whole = int(floor(time_left))
        if current_whole < _last_whole_second and current_whole >= 1 and current_whole <= 10:
            # play a short tick; for numbers 3..1 we can increase pitch
            var pitch = 1200.0 if current_whole <= 3 else 1000.0
            _play_beep(pitch, 0.09, 0.85)
        _last_whole_second = current_whole

    else:
        # time up -> you win (show clear UI and options)
        # but only if the player hasn't failed earlier
        if not _cleared and not _failed:
            _cleared = true
            print("Time's up! You cleared the game.")
            _play_beep(1320.0, 0.5, 1.0)

            # create a Control and attach the clear UI script so it can receive input even when the scene is paused
            var ui = Control.new()
            ui.set_script(load("res://scripts/clear_ui.gd"))
            ui.pause_mode = Node.PAUSE_MODE_PROCESS
            var current = get_tree().get_current_scene()
            if current:
                current.add_child(ui)
            else:
                add_child(ui)

            # pause game world so gameplay stops while UI is shown
            get_tree().paused = true

    # audio generation: fill available frames by mixing active beeps
    if _audio_playback and _active_beeps.size() > 0:
        var frames_avail = _audio_playback.get_frames_available()
        # limit frames to avoid long loops
        var to_push = min(frames_avail, 1024)
        var mix_rate = _mix_rate
        for i in range(to_push):
            var sample = 0.0
            # iterate beeps and sum samples for this frame
            for b in _active_beeps:
                var pos = b.sample_pos
                if pos < b.total_samples:
                    var t = float(pos) / float(mix_rate)
                    sample += sin(TAU * b.freq * t) * b.volume
                # else: will be cleaned up later
                b.sample_pos += 1
            # clamp
            sample = clamp(sample, -1.0, 1.0)
            var frame = AudioFrame(sample, sample)
            _audio_playback.push_frame(frame)
        # remove finished beeps
        for j in range(_active_beeps.size() - 1, -1, -1):
            var bb = _active_beeps[j]
            if bb.sample_pos >= bb.total_samples:
                _active_beeps.remove_at(j)

func _play_beep(freq: float, duration: float, volume: float = 0.8) -> void:
    # schedule a beep to be synthesized in _process
    var total = int(ceil(duration * _mix_rate))
    var b = {"freq": freq, "total_samples": total, "sample_pos": 0, "volume": volume}
    _active_beeps.append(b)

func _on_player_hit() -> void:
    # show failure UI immediately and prevent the clear UI from also appearing
    if _failed or _cleared:
        return
    _failed = true
    print("Player was hit! Game over (failed).")
    time_left = 0
    # play a distinct 'hit' sound
    _play_beep(220.0, 0.25, 1.0)

    # create and attach fail UI
    var ui = Control.new()
    ui.set_script(load("res://scripts/fail_ui.gd"))
    ui.pause_mode = Node.PAUSE_MODE_PROCESS
    var current = get_tree().get_current_scene()
    if current:
        current.add_child(ui)
    else:
        add_child(ui)

    get_tree().paused = true
