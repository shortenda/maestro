extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Resource) var health_sprite

const _num_healths = 6

var _missed_notes = 0

var _health_sprites = []

func _on_note_scheduled(note):
    note.connect("note_missed", self, "_on_note_missed")

func _on_note_missed(note):
    _missed_notes += 1
    if _missed_notes >= 6:
        get_tree().change_scene("res://3d_in_2d.tscn")
        # TODO end game better
    # Notes are placed left to right, and disabled right to left.
    (_health_sprites[_num_healths - _missed_notes]).set_healthy(false)
    
func _ready():
    # 0 through 6
    # 
    for i in range(_num_healths):
        var width = 1.0 / _num_healths
        var health_control = health_sprite.instance() as Control
        health_control.set_healthy(true)
        health_control.anchor_left = i * width
        health_control.anchor_right = i * width
        self.add_child(health_control)
        _health_sprites.append(health_control)
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
