extends Control

const SMF = preload("res://addons/midi/SMF.gd")
const Utility = preload("res://addons/midi/Utility.gd")


# var seconds_to_timebase = tempo / 60.0
# var timebase_to_seconds = 60.0 / tempo

const note_track = preload("res://note_track.tscn")

const MidiScheduler = preload("res://midi_scheduler.gd")

var missed_notes = 0

func _on_missed_note():
    missed_notes += 1
    get_node("%ScoreLabel").text = str(missed_notes)

# Called when the node enters the scene tree for the first time.
func _ready():
    var standard_midi_file = SMF.new()
    var result = standard_midi_file.read_file("res://Assets/midi_files/maestro.mid")
    if result.error != OK:
        print("Error loading midi file!")
    
    SongProgress.smf_data = result.data
    
    var key_array = ["A", "S", "D", "J", "K", "L"]

    

    var note_tracks = []
    var track_i = 0
    var gap = 50
    for key in key_array:
        var track_node = note_track.instance()
        track_node.set_position(Vector2(gap, 0) * track_i)
        track_node.key_to_press = key
        track_node.connect("missed_note", self, "_on_missed_note")
        add_child(track_node)
        var track_letter = Label.new()
        track_letter.text = key
        track_letter.rect_position.x = gap * track_i
        track_letter.rect_size.x = 20
        track_letter.align = Label.ALIGN_CENTER
        add_child(track_letter)
        note_tracks.append(track_node)
        track_i += 1
        
    var midi_scheduler = MidiScheduler.new()
    midi_scheduler.note_tracks = note_tracks
    
    for track in result.data.tracks:
        midi_scheduler.start_track_coroutine(track, self.rect_size.y)
    

