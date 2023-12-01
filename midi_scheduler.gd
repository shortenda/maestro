extends Node

const SMF = preload("res://addons/midi/SMF.gd")

const Note = preload("res://note.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const note_scene = preload("res://Note.tscn")

# MidiSchdulerTrack array
var note_tracks: Array = []

var midi_tracks: Array = []

var stage_length = 0

# Triggered when a note is scheduled
signal note_scheduled(note)

signal all_notes_complete()

func _ready():
    var coroutines = []
    for track in self.midi_tracks:
        coroutines.append(start_track_coroutine(track))
    for coroutine in coroutines:
        if coroutine.is_valid():
            yield(coroutine, "completed")
    for note_track in note_tracks:
        var completion = note_track.wait_for_empty()
        if completion:
            yield(completion, "completed")
    self.emit_signal("all_notes_complete")

# Whether the head of the deque overlaps with note.
func schedule_note(note: Note):
    for note_track in note_tracks:
        if note_track.can_accept_note(note):
            note_track.add_note(note)
            return true
    breakpoint
    return false


func handle_non_note_midi_event(event_chunk: SMF.MIDIEventChunk):
    if (event_chunk.event.type == SMF.MIDIEventType.system_event and
            event_chunk.event.args.type == SMF.MIDISystemEventType.set_tempo):
        get_node("%SongProgress").set_tempo(60000000.0 / float(event_chunk.event.args.bpm))
        return

    yield(get_node("%SongProgress").song_timers.await_event_chunk(event_chunk), "time_reached");
    get_node("%MidiPlayerSingleton").midi_player.receive_raw_smf_midi_event(
        event_chunk.channel_number, event_chunk.event)

class OpenNote:
    var start_note: SMF.MIDIEventChunk
    var effects: Array = []

class MidiTrackHandler extends Object:
    var start_note_by_pitch = {}
    var found_end = false
    var notes_to_schedule = []
    var track = null
    var i = 0
    var have_tempo = false

    var song_progress = null
    var scheduler = null

    func _init(scheduler, track, song_progress):
        self.scheduler = scheduler
        self.track = track
        self.song_progress = song_progress

    func should_spool_event(event_chunk):
        var spool_event_time = song_progress.time_to_spool_event(event_chunk)
        var current_time = song_progress.current_time
        return current_time >= spool_event_time

    func run():
        while i < track.events.size():
            # TODO tempo makes this hard, so just process them all up front.
            # if have_tempo and !notes_to_schedule.empty() and !self.scheduler.should_spool_event(notes_to_schedule[0].start_note):
            #    yield(song_progress.song_timers.await_event_chunk_spool(track.events[i]), "time_reached")
            handle_midi_event()
            i += 1

    func handle_midi_event():
        var event_chunk = track.events[i]
        if event_chunk.event.type == SMF.MIDIEventType.note_on:
            var note_on = event_chunk.event as SMF.MIDIEventNoteOn
            if start_note_by_pitch.has(note_on.note):
                breakpoint
            var open_note = OpenNote.new()
            open_note.start_note = event_chunk
            open_note.effects.append(Note.Effect.new(event_chunk))
            start_note_by_pitch[note_on.note] = open_note
            notes_to_schedule.append(open_note)
        elif event_chunk.event.type == SMF.MIDIEventType.note_off:
            var note_off = event_chunk.event as SMF.MIDIEventNoteOff
            if not start_note_by_pitch.has(note_off.note):
                breakpoint
            var open_note = start_note_by_pitch[note_off.note]
            open_note.effects.append(Note.Effect.new(event_chunk))

            var note_node = note_scene.instance()
            note_node.connect("tree_entered", note_node, "set_owner", [scheduler.owner])
            note_node.animation_start_time = open_note.start_note.time - song_progress.real_time_to_midi_ticks(song_progress.note_preview_time)
            note_node.animation_end_time = event_chunk.time # open_note.start_note.time + get_node("%SongProgress").real_time_to_midi_ticks(0.5)# track.events[i].time
            note_node._note_start_time = open_note.start_note.time
            note_node._note_end_time = event_chunk.time # open_note.start_note.time + get_node("%SongProgress").real_time_to_midi_ticks(0.5)# track.events[i].time
            note_node.note_stage_length = scheduler.stage_length
            note_node.effects = open_note.effects

            if scheduler.schedule_note(note_node):
                scheduler.emit_signal("note_scheduled", note_node)
                notes_to_schedule.pop_front()

            start_note_by_pitch.erase(note_off.note)
        else:
            if (event_chunk.event.type == SMF.MIDIEventType.system_event and
                    event_chunk.event.args.type == SMF.MIDISystemEventType.set_tempo):
                self.have_tempo = true
            scheduler.handle_non_note_midi_event(event_chunk)

# Called when the node enters the scene tree for the first time.
func start_track_coroutine(track: SMF.MIDITrack):
    print("Started coroutine for track", track.track_number)
    var notification =  get_node("%MidiPlayerSingleton").wait_for_ready()
    if notification:
        yield(notification, "completed")

    var midi_track_handler = MidiTrackHandler.new(self, track, get_node("%SongProgress"))
    return midi_track_handler.run()

# place the note type, and in the note check whether the player pressed the button
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
# note.play_start_time = note_start_time
