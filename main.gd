extends Control

const SMF = preload("res://addons/midi/SMF.gd")
const Utility = preload("res://addons/midi/Utility.gd")


# var seconds_to_timebase = tempo / 60.0
# var timebase_to_seconds = 60.0 / tempo

const midi_track = preload("res://midi_track.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    print ("test")
    var test = SMF.new()
    var result = test.read_file("res://Assets/midi_files/maestro.mid")
    if result.error != OK:
        print("Error loading midi file!")
        
    SongProgress.smf_data = result.data
    
    var key_array = ["A", "S", "D", "J", "K", "L"]

    var track_i = 0
    for track in result.data.tracks:
        var track_node = midi_track.instance()
        track_node.track = track
        track_node.set_position(Vector2(30, 0) * track_i)
        track_node.stage_length = self.rect_size.y
        track_node.key_to_press = key_array[track_i]
        add_child(track_node)
        var track_letter = Label.new()
        track_letter.text = key_array[track_i]
        track_letter.rect_position.x = 30 * track_i
        track_letter.rect_size.x = 20
        track_letter.align = Label.ALIGN_CENTER
        add_child(track_letter)
        track_i+=1

