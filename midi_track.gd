extends Node

const SMF = preload("res://addons/midi/SMF.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var track: SMF.MIDITrack = null

const note_scene = preload("res://Note.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    print("Started coroutine for track", track.track_number)
    var notification = MidiPlayerSingleton.wait_for_ready()
    if notification:
        yield(notification, "completed")

    for event_chunk in track.events:
        # TODO instead, yield for some period of time before the event chunk,
        # and start animating the note.
        yield(SongProgress.song_timers.await_time(event_chunk.time/200 - 5), "time_reached")
        if event_chunk.event.type == SMF.MIDIEventType.note_on:
            var note = note_scene.instance()
            # When the note starts animating
            note.animation_start_time = event_chunk.time/200 - 5
            note.animation_end_time = event_chunk.time/200
        
            $Path2D.add_child(note)
        # print("Note will play soon!")
        MidiPlayerSingleton.midi_player.receive_raw_smf_midi_event(event_chunk.channel_number, event_chunk.event)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
