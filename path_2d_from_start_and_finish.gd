extends Path2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    self.curve.clear_points ()
    self.curve.add_point($Start.position)
    self.curve.add_point($Finish.position)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
