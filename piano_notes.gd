extends CanvasLayer

const SMF = preload("res://addons/midi/SMF.gd")

const Utility = preload("res://addons/midi/Utility.gd")

const MidiScheduler = preload("res://midi_scheduler.gd")

const MidiSchdulerTrack = preload("res://midi_scheduler_track.gd")

const FileBytes = preload("res://addons/midi/sound_font_bytes.gd")

export (Resource) var midi_bytes_resource

export (NodePath) var track_container_node_path

export (NodePath) var key_container_node_path

export (NodePath) var score_tracker_node_path

signal score_updated(misses)

func _on_note_scheduled(note: Note):
    pass

var _tracks: Array = []

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

    get_node("%SongProgress").smf_data = result.data

    var key_array = ["S", "D", "F", "J", "K", "L", "H"]

    var track_i = 0
    for key in key_array:
        var track = MidiSchdulerTrack.new(
            key,
            track_i,
            get_node(self.track_container_node_path),
            get_node(self.key_container_node_path),
            self.owner
        )
        track.connect("tree_entered", track, "set_owner", [self.owner]);
        self.add_child(track)
        self._tracks.append(track)
        track_i += 1

    var midi_scheduler = MidiScheduler.new()
    midi_scheduler.note_tracks = _tracks
    midi_scheduler.connect("note_scheduled", get_node(score_tracker_node_path), "_on_note_scheduled")
    midi_scheduler.midi_tracks = result.data.tracks
    midi_scheduler.stage_length = get_node(self.track_container_node_path).rect_size.y
    midi_scheduler.connect("tree_entered", midi_scheduler, "set_owner", [self.owner]);
    self.add_child(midi_scheduler)

    yield(midi_scheduler, "all_notes_complete")
    get_tree().change_scene("res://EndingScene.tscn")
