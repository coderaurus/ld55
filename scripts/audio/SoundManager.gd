extends AudioStreamPlayer

@export var sounds : Dictionary = {}
var stored_db = 0
const MUTE_DB = -80
const MAX_DB = -6

signal volume_changed

func _ready():
	volume_db = MAX_DB

func toggle() -> bool:
	if volume_db == MUTE_DB:
		unmute_sounds()
		return true
	else:
		mute_sounds()
		return false


func mute_sounds():
	stored_db = volume_db
	volume_db = MUTE_DB
	
func unmute_sounds():
	volume_db = stored_db
#	print("Unmute sound to %s" % stored_db)
	sound("click")

func sound(sfx_name = "", _pitch = 1, vol_mod = -999):
	pitch_scale = _pitch
	if sounds.has(sfx_name):
		stream = sounds.get(sfx_name)
		if vol_mod == -999:
			play_sound(0.0, volume_db)
		else: 
			play_sound(0.0, volume_db + vol_mod)

func play_sound(from_position=0.0, volume = MUTE_DB):
#	var asp = self.duplicate(DUPLICATE_USE_INSTANCING)
	var asp = AudioStreamPlayer.new()
	add_child(asp)
	asp.mix_target = mix_target
	asp.pitch_scale = pitch_scale
	if volume > MUTE_DB:
		asp.volume_db = volume
	else:
		asp.volume_db = volume_db
	asp.stream = stream
	asp.play()
	await asp.finished
	asp.queue_free()

func _on_range_change(value):
	volume_db = value
	sound("click")
	
	for child in get_children():
		child.volume_db = value
	
	emit_signal("volume_changed", value)
