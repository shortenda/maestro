extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func _ready():
    $MainMenuPlayer.play()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_pressed():
    $ButtonPlayer.play()
    get_tree().change_scene("res://3d_in_2d.tscn")
    # Replace with function body.


func _on_TextureButton2_pressed():
    $ButtonPlayer.play()
    get_tree().quit()
    pass # Replace with function body.
