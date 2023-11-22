extends Node

const SMF = preload("res://addons/midi/SMF.gd")

const Note = preload("res://note.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const note_scene = preload("res://Note.tscn")

var note_tracks: Array = []

# Whether the head of the deque overlaps with note.
func schedule_note(note: Note):
    for note_track in note_tracks:
        if note_track.can_accept_note(note):
            note_track.add_note(note)
            return true
    return false

static func should_spool_event(event_chunk):
    return SongProgress.current_time >= SongProgress.time_to_spool_event(event_chunk)

static func schedule_midi_event(event_chunk: SMF.MIDIEventChunk):
    yield(SongProgress.song_timers.await_event_chunk(event_chunk), "time_reached");
    MidiPlayerSingleton.midi_player.receive_raw_smf_midi_event(
        event_chunk.channel_number, event_chunk.event)

static func handle_non_note_midi_event(event_chunk: SMF.MIDIEventChunk):
    if (event_chunk.event.type == SMF.MIDIEventType.system_event and
            event_chunk.event.args.type == SMF.MIDISystemEventType.set_tempo):
        SongProgress.set_tempo(60000000.0 / float( event_chunk.event.args.bpm ))
        pass
    schedule_midi_event(event_chunk)


# Called when the node enters the scene tree for the first time.
func start_track_coroutine(track: SMF.MIDITrack, stage_length):
    print("Started coroutine for track", track.track_number)
    var notification = MidiPlayerSingleton.wait_for_ready()
    if notification:
        yield(notification, "completed")

    var i = 0
    while true and i < track.events.size():
        if not should_spool_event(track.events[i]):
            yield(SongProgress.song_timers.await_event_chunk_spool(track.events[i]), "time_reached")
        
        if track.events[i].event.type != SMF.MIDIEventType.note_on:
            # schedule the event and move on
            handle_non_note_midi_event(track.events[i])
            i += 1
            continue
            
        var open_note_count = 0
        var start_note = null
        # We have to handle the note on event, continue until we have no open notes.

        var note_effects = []
        
        while true:
            if track.events[i].event.type == SMF.MIDIEventType.note_on:
                if start_note == null:
                    start_note = track.events[i]
                note_effects.append(Note.Effect.new(track.events[i]))
                open_note_count += 1
            elif track.events[i].event.type == SMF.MIDIEventType.note_off:
                note_effects.append(Note.Effect.new(track.events[i]))
                open_note_count -= 1
            else:
                handle_non_note_midi_event(track.events[i])
            
            var found_end = false
            if open_note_count == 0:
                # place the note type, and in the note check whether the player pressed the button
                var note = note_scene.instance()
                # When the note starts animating, it will take two seconds to reach the
                # bottom of the note animation area, past which it will start to play, until the
                # top of the note reaches the bottom of the play area.
                # The note's speed should be constant, and since distance = rate * time, 
                # If the length of the staging area is L, then the note moves across it at L = r * 2 seconds,
                # r = L / 2. Then we can express the required length of the note as NoteL = L/2 * NoteDuration.
                # Note: the bottom .8 of the track is reserved for the play time.
                
                # L is 450, and the note is 90 long natively.
                # So, NoteL = 600 / 2 * NoteDuration
                # NoteL = 600 / 2 * NoteDuration
                # And NoteL = NoteScale * 90
                # So NoteScale * 90 = 600 / 2 * NoteDuration
                # and then NoteScale = 600 / 2 / 90 * NoteDuration
                
                # TODO if the tempo changes, this time would be wrong. Changing the tempo increases
                # the speed, so the animation time before playing would be too short,
                # but only for those notes, so this may be ok.
                note.animation_start_time = start_note.time - SongProgress.real_time_to_midi_ticks(2)
                note.animation_end_time = track.events[i].time
                note._note_start_time = start_note.time
                note._note_end_time = track.events[i].time
                note.note_stage_length = stage_length
                # note.play_start_time = note_start_time
                note.effects = note_effects
                schedule_note(note)
                found_end = true
            i += 1
            if found_end:
                break

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
