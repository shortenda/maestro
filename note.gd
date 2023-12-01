extends Node2D

class_name Note


const SMF = preload("res://addons/midi/SMF.gd")

const Coroutines = preload("res://coroutines.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var animation_start_time = 0
var animation_end_time = 0
# var play_start_time = 0

var enabled = false

var effects = []

class Effect:
    var event_chunk: SMF.MIDIEventChunk

    func _init(evt_chunk):
        self.event_chunk = evt_chunk

# The length of the note in units
var note_length = 0

# The length of the note in song-seconds
var note_duration = 0

var _note_start_time

var _note_end_time

# How far to animate the note between animation_start_time and animation_end_time.
var note_animation_length = 0

var note_stage_length = 0

var can_play = false

const red_dot = preload("res://Assets/dot_red.png")

# Triggered when this note is next and the key for the track is pressed
func key_pressed():
    if can_play:
        self.emit_signal("note_hit", self)

func note_start_time():
    return _note_start_time

func note_end_time():
    return _note_end_time

signal note_missed(note)

signal note_hit(note)

signal note_completed(note)

signal note_can_play(note)

func calculate_position():
    # lerp between animation_start_time and animation_end_time
    var time_since_start: float = get_node("%SongProgress").current_time - animation_start_time
    if animation_end_time != animation_start_time:
        var new_pos = note_animation_length * \
            (time_since_start/(animation_end_time - animation_start_time))
        self.position.y = new_pos

# Called when the node enters the scene tree for the first time.
func _ready():
    # The length of the stage, +
    var note_speed = note_stage_length / get_node("%SongProgress").real_time_to_midi_ticks(get_node("%SongProgress").note_preview_time)
    note_duration = animation_end_time - animation_start_time - get_node("%SongProgress").real_time_to_midi_ticks(get_node("%SongProgress").note_preview_time)
    note_length = note_speed * note_duration
    note_animation_length = note_stage_length + note_length

    # A 1 second note is display for the whole time period, so scale it based
    # on the multiple of two seconds, with 1 being the whole path legth.
    #var scale =
    # Note Area2D doesn't work correctly if it's been scaled, so do it manually.
    var sprite_height = $Sprite.get_rect().size.y

    $Sprite.position.y = -note_length / 2
    var size_multiplier = note_length / sprite_height
    $Sprite.scale.y = size_multiplier

    $Area2D.position.y = -note_length / 2

    # Note: shape is reference counted, so make a new one and then change it.
    $Area2D/CollisionShape2D.shape = $Area2D/CollisionShape2D.shape.duplicate()
    $Area2D/CollisionShape2D.shape.set_extents(Vector2(15, note_length / 2))

    self.calculate_position()
    print($Area2D/CollisionShape2D.shape.extents.x)
    print($Area2D/CollisionShape2D.shape.extents.y)

    # Enable collisions now that the position is set.
    $Area2D/CollisionShape2D.set_deferred("disabled", false)

    # Wait for a collision with the window collider
    yield($Area2D, "area_entered")

    self.emit_signal("note_can_play", self)
    can_play = true
    # TODO can change texture here to indicate note can be played
    # $Sprite.texture = red_dot

    # Wait for either the note to be hit, or the time that it needs to be played.
    var select_state = Coroutines.select_co([
        Coroutines.from_signal(self, "note_hit"),
        Coroutines.from_signal(get_node("%SongProgress").song_timers.await_time(_note_start_time), "time_reached"),
    ])
    var select_index = yield(select_state, "completed")

    if select_index == 0:
        for effect in effects:
            yield(get_node("%SongProgress").song_timers.await_event_chunk(effect.event_chunk), "time_reached")
            get_node("%MidiPlayerSingleton").midi_player.receive_raw_smf_midi_event(
                effect.event_chunk.channel_number, effect.event_chunk.event)
    elif select_index == 1:
        self.emit_signal("note_missed", self)
    else:
        breakpoint

    yield(get_node("%SongProgress").song_timers.await_time(animation_end_time), "time_reached")
    self.emit_signal("note_completed", self)

func _process(_delta):
    self.calculate_position()

