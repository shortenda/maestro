extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const DialogResource = preload("res://dialog_resource.gd")

export (Resource) var dialog_resource
onready var dialog = dialog_resource as DialogResource

export (Resource) var next_scene

var current_line = 0

func _unhandled_input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_ENTER:
            # Load next line of dialog
            $DialogNode.text = dialog.lines[0]

# Called when the node enters the scene tree for the first time.
func _ready():
    #for line in dialog.lines:
    #    print(line)
    # TODO remove this scene, and add the new scene
    self.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
