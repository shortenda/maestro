extends Node2D

const SMF = preload("res://addons/midi/SMF.gd")

class_name Note

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

    func _init(event_chunk):
        self.event_chunk = event_chunk

# The length of the note in units
var note_length = 0

# The length of the note in song-seconds
var note_duration = 0

var _note_start_time

var _note_end_time

# How far to animate the note between animation_start_time and animation_end_time.
var note_animation_length = 0

var note_stage_length = 0

var key_pressed


# Triggered when this note is next and the key for the track is pressed
func key_pressed():
    var target = SongProgress.real_time_to_midi_ticks(0.3)
    var val = abs(_note_start_time - SongProgress.current_time)
    if val < target:
        key_pressed = true

func note_start_time():
    return _note_start_time

func note_end_time():
    return _note_end_time

signal note_completed(note)

# Called when the node enters the scene tree for the first time.
func _ready():
    # The length of the stage, + 
    var note_speed = note_stage_length / SongProgress.real_time_to_midi_ticks(2.0)
    note_duration = animation_end_time - animation_start_time - SongProgress.real_time_to_midi_ticks(2.0)
    note_length = note_speed * note_duration
    note_animation_length = note_stage_length + note_length

    # A 1 second note is display for the whole time period, so scale it based
    # on the multiple of two seconds, with 1 being the whole path legth.
    #var scale =  
    self.scale.y = note_length / $Sprite.get_rect().size.y
    $Sprite.position.y = -$Sprite.get_rect().size.y
    
    for effect in effects:
        yield(SongProgress.song_timers.await_event_chunk(effect.event_chunk), "time_reached")
        if not key_pressed:
            break
        # Check if input was pressed, if not, then return.
        MidiPlayerSingleton.midi_player.receive_raw_smf_midi_event(
            effect.event_chunk.channel_number, effect.event_chunk.event)
    yield(SongProgress.song_timers.await_time(animation_end_time), "time_reached")
    self.emit_signal("note_completed", self)

func _process(_delta):
    # lerp between animation_start_time and animation_end_time
    var time_since_start: float = SongProgress.current_time - animation_start_time
    if animation_end_time != animation_start_time:
        var new_pos = note_animation_length * \
            (time_since_start/(animation_end_time - animation_start_time))
        self.position.y = new_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
