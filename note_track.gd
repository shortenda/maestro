extends Node2D

const Note = preload("res://note.gd")

# head is next note to play.
var scheduled_notes = []

var key_to_press

func _ready():
    pass
    
signal missed_note

signal hit_note

func _unhandled_input(event):
    if not event is InputEventKey:
        return
        
    if not event.pressed or event.scancode != OS.find_scancode_from_string(key_to_press):
        return
        
    if scheduled_notes.empty(): 
        return
        
    scheduled_notes.front().key_pressed()

func _on_note_completed(note: Note):
    if note != scheduled_notes.front():
        breakpoint
    scheduled_notes.pop_front()
    
    if not note.key_pressed:
        emit_signal("missed_note")
    
    note.queue_free()

func add_note(note: Note):
    add_child(note)
    scheduled_notes.append(note)
    note.connect("note_completed", self, "_on_note_completed")

func can_accept_note(note: Note):
    if scheduled_notes.empty():
        return true
    # Leave a gap
    return scheduled_notes.back().note_end_time() + SongProgress.real_time_to_midi_ticks(0.1) < note.note_start_time()
