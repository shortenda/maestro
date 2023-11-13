extends Node

const SMF = preload( "res://addons/midi/SMF.gd" )
const Utility = preload( "res://addons/midi/Utility.gd" )

onready var midi_player:MidiPlayer = $MidiPlayer

# var seconds_to_timebase = tempo / 60.0
# var timebase_to_seconds = 60.0 / tempo

func track_coroutine(track: SMF.MIDITrack):
    print("Started coroutine for track", track.track_number)
    var last_event_chunk_time = null
    for event_chunk in track.events:
        if last_event_chunk_time != null:
            yield(get_tree().create_timer((event_chunk.time as float - last_event_chunk_time as float) / 200), "timeout")
        $MidiPlayer.receive_raw_smf_midi_event(event_chunk.channel_number, event_chunk.event)
        last_event_chunk_time = event_chunk.time

var track_coroutines = []

# Called when the node enters the scene tree for the first time.
func _ready():
    print ("test")
    var test = SMF.new()
    var result = test.read_file("res://Assets/midi_files/fairyland_gm.mid")
    if result.error != OK:
        print("Error loading midi file!")
    
    for track in result.data.tracks:
        track_coroutines.append(track_coroutine(track))
