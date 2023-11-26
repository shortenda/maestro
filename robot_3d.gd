extends Node


# A simple script to rotate the model.
onready var model = $Model

func _ready():
    pass

func set_piano_viewport(viewport):
    $PianoNotes.texture = viewport.get_texture()

func _process(delta):
    model.rotate_y(delta * 0.7)

