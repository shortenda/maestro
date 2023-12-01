extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready():
    if (pressed == true):
        get_tree().change_scene("res://3d_in_2d.tscn")
