extends Node2D

const Note = preload("res://note.gd")


var last_scheduled_note_end_time = null

var key_to_press

func _ready():
    pass

func add_note(note: Note):
    note.key_to_press = key_to_press
    add_child(note)
    last_scheduled_note_end_time = note.note_end_time()

func can_accept_note(note: Note):
    if last_scheduled_note_end_time == null:
        return true
    # Leave a gap
    return last_scheduled_note_end_time + SongProgress.real_time_to_midi_ticks(0.1) < note.note_start_time()
