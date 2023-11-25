extends Container

const Note = preload("res://note.gd")

# head is next note to play.
var scheduled_notes = []

var key_to_press

var _track_label : Control

var track_label_scene = preload("track_label.tscn")

func _ready():
    self._track_label = track_label_scene.instance()
    self._track_label.get_node("Label").text = key_to_press
    add_child(self._track_label)

func _unhandled_input(event):
    if not event is InputEventKey:
        return
        
    if not event.pressed or event.scancode != OS.find_scancode_from_string(key_to_press):
        return
        
    if scheduled_notes.empty(): 
        return
        
    scheduled_notes.front().key_pressed()


# Triggered when a note can be played.
func _on_note_can_play(_note: Note):
    self._track_label.get_node("ColorRect").color = Color(0, 255, 255)

func _on_note_hit(_note: Note):
    self._track_label.get_node("ColorRect").color = Color(0, 255, 0)

func _on_note_missed(_note: Note):
    self._track_label.get_node("ColorRect").color = Color(255, 0, 0)

func _on_note_completed(note: Note):
    if note != scheduled_notes.front():
        breakpoint
    scheduled_notes.pop_front()    
    self._track_label.get_node("ColorRect").color = Color(255, 255, 255)
    
    note.queue_free()

func add_note(note: Note):
    add_child(note)
    scheduled_notes.append(note)
    note.connect("note_missed", self, "_on_note_missed")
    note.connect("note_hit", self, "_on_note_hit")
    note.connect("note_completed", self, "_on_note_completed")
    note.connect("note_can_play", self, "_on_note_can_play")

func can_accept_note(note: Note):
    if scheduled_notes.empty():
        return true
    # Leave a gap
    return scheduled_notes.back().note_end_time() + SongProgress.real_time_to_midi_ticks(0.1) < note.note_start_time()
