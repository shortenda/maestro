extends Control

class_name DialogNode

export (String) var text setget update_text
export (String) var title setget update_title

func update_text(val):
    text = val
    $TextNode.bbcode_text = "[center][size=32][color=black]" + val + "[/color][/size][/center]"

func update_title(val):
    title = val
    $TitleNode.bbcode_text = "[center][size=32][color=black]" + val + "[/color][/size][/center]"

# Called when the node enters the scene tree for the first time.
func _ready():
    pass
