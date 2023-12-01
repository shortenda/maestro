extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const DialogResource = preload("res://dialog_resource.gd")

export (Resource) var dialog_resource
onready var dialog = dialog_resource as DialogResource

export (Resource) var next_scene

var current_line = -1

func next_line():
    # Load next line of dialog
    current_line += 1
    if current_line == dialog.lines.size():
        self.queue_free()
        get_tree().quit()
        return
    $DialogNode.text = dialog.lines[current_line]

func _unhandled_input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_ENTER:
            next_line()

# Called when the node enters the scene tree for the first time.
func _ready():
    next_line()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
