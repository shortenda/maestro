extends Control

const health_yes = preload("res://Assets/health_y.png")

const health_no = preload("res://Assets/health_na.png")

func set_healthy(healthy: bool):
    if healthy:
        $Sprite.texture = health_yes
    else:
        $Sprite.texture = health_no        
