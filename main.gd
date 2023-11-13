extends Node

const SMF = preload( "res://addons/midi/SMF.gd" )
const Utility = preload( "res://addons/midi/Utility.gd" )

onready var midi_player:MidiPlayer = $MidiPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
    print ("test")
    var test = SMF.new()
    var result = test.read_file("res://Assets/midi_files/fairyland_gm.mid")
    if result.error != OK:
        print("Error loading midi file!")
    
    for track in result.data.tracks:
        for event_chunk in track.events:
            print(event_chunk.channel_number)
            print(event_chunk.event.type)
            $MidiPlayer.receive_raw_smf_midi_event(event_chunk.channel_number, event_chunk.event)
            yield(get_tree().create_timer(0.001), "timeout")

