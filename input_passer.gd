extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var input_receiver_path

onready var _node = get_node(input_receiver_path)

func _input(event):
    _node.input(event)

func _unhandled_input(event):
    _node.unhandled_input(event)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
