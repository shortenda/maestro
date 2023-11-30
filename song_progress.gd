extends Node

const SMF = preload("res://addons/midi/SMF.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_time = 0

var song_timers

var smf_data: SMF.SMFData

# Called when the node enters the scene tree for the first time.
func _ready():
    song_timers = TimerCollection.new(self)
    self.add_child(song_timers)
    if tempo == 0:
        set_tempo(60000000.0 / float(120))
    current_time = -5000

var tempo: float = 0

var timebase_to_seconds: float

var seconds_to_timebase: float

func set_tempo( bpm:float ) -> void:
    #
    # テンポ設定
    # @param	bpm	テンポ
    #

    tempo = bpm
    self.seconds_to_timebase = tempo / 60.0
    self.timebase_to_seconds = 60.0 / tempo

# TODO make this real
func real_time_to_midi_ticks(duration):
    return float( self.smf_data.timebase ) * duration * self.seconds_to_timebase

# Show the note two seconds before it plays.
const note_preview_time:float = 2.0

# How long the player has to press the key before the note plays.
const key_press_interval:float = 0.5

const track_min_gap: float = 0.1

# Leave two seconds to display the note.
func time_to_spool_event(event_chunk):
    return event_chunk.time -  real_time_to_midi_ticks(note_preview_time)

# static func fake_time(event_chunk):
#    return event_chunk.time / 30.0

var _paused = false

func toggle_paused():
    _paused = !_paused

func _process(delta):
    if !_paused:
        current_time += real_time_to_midi_ticks(delta)
        song_timers.check_timers(current_time)


# Tempo is set in microseconds per quarter note

# Header determines the number of ticks per quarter note

# microseconds per tick = microseconds per quarter note / ticks per quarter note


class SongTimer:
    signal time_reached
    var time: float
    
    func _signal_time_reached():
        emit_signal("time_reached")
    
    func _init(t: float):
        time = t

class TimerCollection extends Node:
    var signal_count = 0
    var song_timers = []
    var next_timer_index = -1
    
    var _song_progress = null
    
    func _init(song_progress):
        self._song_progress = song_progress
    
    func check_timers(current_time: float):
        while true:
            if next_timer_index == -1:
                return

            var song_timer = song_timers[next_timer_index]
            if current_time < song_timer.time:
                return
            
            # else, trigger next_timer_index, and swap a new timer into the same
            # place in the array before removing the last element.
            song_timer._signal_time_reached()
            var back_timer = song_timers.pop_back()
            
            # If there's no back element, or this was the back element, return.
            if back_timer == null:
                return
                
            if next_timer_index < song_timers.size():
                song_timers[next_timer_index] = back_timer
            
            update_timer_index()

    func update_timer_index():
        var min_timer_value = 0
        var min_timer_index = -1
        for timer_index in range(song_timers.size()):
            var timer = song_timers[timer_index]
            if min_timer_index == -1 or timer.time < min_timer_value:
                min_timer_index = timer_index
                min_timer_value = timer.time
        next_timer_index = min_timer_index

    # Place a connection on 'target' that will call "time_reached" at 't'
    func await_time(t: float):
        var timer = SongTimer.new(t)
        song_timers.append(timer)
        maybe_update_timer_index(t, song_timers.size() - 1)
        return timer
        
    func await_event_chunk_spool(event_chunk: SMF.MIDIEventChunk):
        return await_time(_song_progress.time_to_spool_event(event_chunk))
        

    func await_event_chunk(event_chunk: SMF.MIDIEventChunk):
        return await_time(event_chunk.time)

    func maybe_update_timer_index(new_timer_value: float, new_timer_index: int):
        if next_timer_index == -1 or new_timer_value < song_timers[next_timer_index].time:
            next_timer_index = new_timer_index
    
