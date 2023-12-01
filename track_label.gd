extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Triggered when a note can be played.
func _on_note_can_play(_note: Note):
	$ColorRect.color = Color(0, 255, 255)

func _on_note_hit(_note: Note):
	$ColorRect.color = Color(0, 255, 0)

func _on_note_missed(_note: Note):
	$ColorRect.color = Color(255, 0, 0)

func _on_note_completed(_note: Note):
	$ColorRect.color = Color(255, 255, 255)

func _on_note_scheduled(note: Note):
	note.connect("note_missed", self, "_on_note_missed")
	note.connect("note_hit", self, "_on_note_hit")
	note.connect("note_completed", self, "_on_note_completed")
	note.connect("note_can_play", self, "_on_note_can_play")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
