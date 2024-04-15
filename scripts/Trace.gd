extends Line2D
class_name TraceTrail

var target: Node2D
var stopped = false

func setup(_target):
	target = _target
	stopped = false
	show()

func stop():
	stopped = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if points.size() == 360 or points.size() > 0 and stopped:
		remove_point(0)
	
	if target == null or (target is InvocationCursor and not (target as InvocationCursor).moving):
		return
	
	add_point(target.global_position)
