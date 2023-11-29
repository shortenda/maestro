extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _text: String setget update_text

func _init(text):
    self._text = text
    
func update_text(text):
    self.bbcode_text = text
    _text = text

# Called when the node enters the scene tree for the first time.
func _ready():
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
