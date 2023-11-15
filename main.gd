extends Node2D

const SMF = preload("res://addons/midi/SMF.gd")
const Utility = preload("res://addons/midi/Utility.gd")


# var seconds_to_timebase = tempo / 60.0
# var timebase_to_seconds = 60.0 / tempo

const midi_track = preload("res://midi_track.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    print ("test")
    var test = SMF.new()
    var result = test.read_file("res://Assets/midi_files/fairyland_gm.mid")
    if result.error != OK:
        print("Error loading midi file!")
    
    var track_i = 0
    for track in result.data.tracks:
        var track_node = midi_track.instance()
        track_node.track = track
        track_node.set_position(self.get_position() + Vector2(30, 0) * track_i)
        add_child(track_node)
        track_i+=1

