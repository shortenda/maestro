class_name Coroutines

class _Emitter:
    signal selected(i)
    func emit(i):
        emit_signal("selected", i)

static func from_signal(obj, signal_string):
    yield(obj, signal_string)

static func select_co(coroutines):
    var emitter = _Emitter.new()
    for i in range(len(coroutines)):
        coroutines[i].connect("completed", emitter, "emit", [i])
    return yield(emitter, "selected")

static func select(specs):
    var emitter = _Emitter.new()
    for triplet in specs:
        match triplet:
            [var object, var signal_name, var retval]:
                object.connect(signal_name, emitter, 'emit', [retval])
            [var object, var signal_name]:
                object.connect(signal_name, emitter, 'emit', [object])
    return yield(emitter, 'emitted')
