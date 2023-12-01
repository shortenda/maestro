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

onready var _note_can_press_time = _note_start_time - \
	get_node("%SongProgress").real_time_to_midi_ticks(get_node("%SongProgress").key_press_interval)

# How far to animate the note between animation_start_time and animation_end_time.
var note_animation_length = 0

var note_stage_length = 0

var key_was_pressed


# Triggered when this note is next and the key for the track is pressed
func key_pressed():
	var target = get_node("%SongProgress").real_time_to_midi_ticks(get_node("%SongProgress").key_press_interval)
	var val = abs(_note_start_time - get_node("%SongProgress").current_time)
	if val < target:
		self.emit_signal("note_hit", self)

func note_start_time():
	return _note_start_time

func note_end_time():
	return _note_end_time

signal note_missed(note)

signal note_hit(note)

signal note_completed(note)

signal note_can_play(note)

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
	self.scale.y = note_length / $Sprite.get_rect().size.y
	$Sprite.position.y = -$Sprite.get_rect().size.y
		
	yield(get_node("%SongProgress").song_timers.await_time(_note_can_press_time), "time_reached")
	self.emit_signal("note_can_play", self)
	
	var select_state = Coroutines.select_co([
		Coroutines.from_signal(self, "note_hit"),
		Coroutines.from_signal(get_node("%SongProgress").song_timers.await_time(_note_start_time), "time_reached"),
	])
	var select_index = yield(select_state, "completed")
	
	if select_index == 0:
		for effect in effects:
			yield(get_node("%SongProgress").song_timers.await_event_chunk(effect.event_chunk), "time_reached")
			# Check if input was pressed, if not, then return.
			get_node("%MidiPlayerSingleton").midi_player.receive_raw_smf_midi_event(
				effect.event_chunk.channel_number, effect.event_chunk.event)
	elif select_index == 1:
		self.emit_signal("note_missed", self)
	else:
		breakpoint
		
	yield(get_node("%SongProgress").song_timers.await_time(animation_end_time), "time_reached")
	self.emit_signal("note_completed", self)

func _process(_delta):
	# lerp between animation_start_time and animation_end_time
	var time_since_start: float = get_node("%SongProgress").current_time - animation_start_time
	if animation_end_time != animation_start_time:
		var new_pos = note_animation_length * \
			(time_since_start/(animation_end_time - animation_start_time))
		self.position.y = new_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
