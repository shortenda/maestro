extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MidiPlayerScene = preload("addons/midi/MidiPlayer.tscn")

const sound_font = preload("Assets/Aspirin-Stereo.sf2")

onready var midi_player = $MidiPlayer

onready var _is_ready = true

func wait_for_ready():
    if _is_ready:
        return
    yield(self, "ready")
    return

# Not called until MidiPlayer's _ready is complete.
func _ready():
    pass
    
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
