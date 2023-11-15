extends PathFollow2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var animation_start_time = 0
var animation_end_time = 0

var enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
    yield(SongProgress.song_timers.await_time(animation_end_time), "time_reached")
    queue_free()

func _process(_delta):
    # lerp between animation_start_time and animation_end_time
    var time_since_start = SongProgress.current_time - animation_start_time
    if animation_end_time != animation_start_time:
        self.unit_offset = (time_since_start/(animation_end_time - animation_start_time))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
