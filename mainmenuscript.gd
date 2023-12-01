extends Sprite

func _ready():
    $MainMenuPlayer.play()
    pass # Replace with function body.


func _on_TextureButton_pressed():
    $ButtonPlayer.play()
    get_tree().change_scene("res://Instructions.tscn")

func _on_TextureButton2_pressed():
    $ButtonPlayer.play()
    get_tree().quit()
