extends Node2D


var viewport_initial_size = Vector2()

export (NodePath) var robot_scene_node_path
onready var robot_scene_node = get_node(robot_scene_node_path)

export (NodePath) var robot_viewport_node_path
onready var robot_viewport_node = get_node(robot_viewport_node_path)

export (NodePath) var piano_viewport_path
onready var piano_viewport = get_node(piano_viewport_path)

func _ready():
    $AnimatedSprite.play()
    #warning-ignore:return_value_discarded
    get_viewport().connect("size_changed", self, "_root_viewport_size_changed")
    viewport_initial_size = robot_viewport_node.size
    
    robot_scene_node.set_piano_viewport(piano_viewport)

# Called when the root's viewport size changes (i.e. when the window is resized).
# This is done to handle multiple resolutions without losing quality.
func _root_viewport_size_changed():
    # The viewport is resized depending on the window height.
    # To compensate for the larger resolution, the viewport sprite is scaled down.
    robot_viewport_node.size = Vector2.ONE * get_viewport().size.y
    $ViewportSprite.scale = Vector2(1, 1) * viewport_initial_size.y / get_viewport().size.y

