extends Node

func _unhandled_input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_ENTER:
            get_tree().change_scene("res://3d_in_2d.tscn")
