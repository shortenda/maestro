extends Container

class_name NoteTrack

const Note = preload("res://note.gd")

const track_label_scene = preload("track_label.tscn")
        
const note_track = preload("res://note_track.tscn")

# head is next note to play.
var _scheduled_notes = []

var _key_to_press: String

signal note_scheduled(note)

var _track_label: Control

var _track_node: Node

func _init(key: String, track_i: int, track_container: Control, key_container: Node, owner: Node):
    _key_to_press = key
    
    var track_container_width = track_container.rect_size.x 
    var track_gap = track_container_width/7.0

    _track_label = track_label_scene.instance()
    _track_label.set_position(Vector2(track_gap * track_i, 0))
    _track_label.get_node("Label").bbcode_text = "[center][color=black][b]"+ key + "[/b][/color][/center]"
    self.connect("note_scheduled", _track_label, "_on_note_scheduled")
    key_container.add_child(_track_label)
    
    _track_node = note_track.instance()
    _track_node.connect("tree_entered", _track_node, "set_owner", [owner]);
    _track_node.set_position(Vector2(track_gap * track_i, 0))
    track_container.add_child(_track_node)
    track_container.move_child(_track_node, 0)
    
func _on_note_hit(_note: Note):
    _scheduled_notes.pop_front()

func _on_note_missed(_note: Note):
    _scheduled_notes.pop_front()

func _on_note_completed(note: Note):
    note.queue_free()

func _on_note_scheduled(note: Note):
    note.connect("note_missed", self, "_on_note_missed")
    note.connect("note_hit", self, "_on_note_hit")
    note.connect("note_completed", self, "_on_note_completed")

func _unhandled_input(event):
    if not event is InputEventKey:
        return
        
    if not event.pressed or event.scancode != OS.find_scancode_from_string(_key_to_press):
        return
    
    if _scheduled_notes.empty(): 
        return
    
    _scheduled_notes.front().key_pressed()

func add_note(note: Note):
    _track_node.add_child(note)
    _scheduled_notes.append(note)
    self.emit_signal("note_scheduled", note)
    _on_note_scheduled(note)

func can_accept_note(note: Note):
    if _scheduled_notes.empty():
        return true
    # Leave a gap
    return _scheduled_notes.back().note_end_time() + get_node("%SongProgress").real_time_to_midi_ticks(get_node("%SongProgress").track_min_gap) < note.note_start_time()
