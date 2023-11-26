extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _on_score_updated(missed_notes):
    self.text = str(missed_notes)

# Called when the node enters the scene tree for the first time.
func _ready():
    $Viewport/NotesScene.connect("score_updated", self, "_on_score_updated")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
