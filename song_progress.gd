extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_time = -5

var song_timers = TimerCollection.new()

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _process(delta):
    current_time += delta
    song_timers.check_timers(current_time)

class SongTimer:
    signal time_reached
    var time: float
    
    func _signal_time_reached():
        emit_signal("time_reached")
    
    func _init(t: float):
        time = t

class TimerCollection:
    var signal_count = 0
    var song_timers = []
    var next_timer_index = -1
    
    func _init():
        pass
    
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

    func maybe_update_timer_index(new_timer_value: float, new_timer_index: int):
        if next_timer_index == -1 or new_timer_value < song_timers[next_timer_index].time:
            next_timer_index = new_timer_index
    
