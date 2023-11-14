extends PathFollow2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var note_start_time = 0
var note_end_time = 0

var enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
    yield(SongProgress.song_timers.await_time(10), "time_reached")
    enabled = true

func _process(delta):
    # Update the note's position based on the current time.
    if enabled:
        self.unit_offset = SongProgress.current_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
