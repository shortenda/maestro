extends CanvasLayer

const SMF = preload("res://addons/midi/SMF.gd")
const Utility = preload("res://addons/midi/Utility.gd")

# var seconds_to_timebase = tempo / 60.0
# var timebase_to_seconds = 60.0 / tempo

const note_track = preload("res://note_track.tscn")

const MidiScheduler = preload("res://midi_scheduler.gd")

export (Resource) var midi_bytes_resource

var missed_notes = 0

const FileBytes = preload("res://addons/midi/sound_font_bytes.gd")

signal score_updated(misses)

func _on_missed_note(_note):
    missed_notes += 1
    self.emit_signal("score_updated", missed_notes)

func _on_note(note: Note):
    note.connect("note_missed", self, "_on_missed_note")

# Called when the node enters the scene tree for the first time.
func _ready():
    var standard_midi_file = SMF.new()
    
    var stream:StreamPeerBuffer = StreamPeerBuffer.new( )
    stream.set_data_array((midi_bytes_resource as FileBytes).value)
    stream.big_endian = true
    var result = standard_midi_file.read_from_stream(stream)

    midi_bytes_resource = null

    if result.error != OK:
        print("Error loading midi file!")
    
    SongProgress.smf_data = result.data
    
    var key_array = ["A", "S", "D", "J", "K", "L"]

    var note_tracks = []
    var track_i = 0
    var gap = 50
    for key in key_array:
        var track_node = note_track.instance()
        track_node.set_position(Vector2(gap * track_i + 50, 0))
        track_node.key_to_press = key
        $Control.add_child(track_node)
        note_tracks.append(track_node)
        track_i += 1
        
    var midi_scheduler = MidiScheduler.new()
    midi_scheduler.note_tracks = note_tracks
    midi_scheduler.connect("note", self, "_on_note")
    
    $Control/ColorRect.anchor_top = \
        1.0 - SongProgress.key_press_interval/SongProgress.note_preview_time
    
    for track in result.data.tracks:
        midi_scheduler.start_track_coroutine(track, $Control.rect_size.y)
    

