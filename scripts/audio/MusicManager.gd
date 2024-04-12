extends AudioStreamPlayer


@export var ost : Dictionary = {}
var fade_step = 5
var stored_db = 0

const MUTE_DB = -80
const MAX_DB = -5


func _ready():
	volume_db = -20

func song_playing(song):
	for key in ost.keys():
		if stream == ost.get(key) and key == song:
			return true
	return false
	
func toggle() -> bool:
	if volume_db == MUTE_DB:
		unmute_music()
		return true
	else:
		mute_music()
		return false

func mute_music():
	stored_db = volume_db
	volume_db = MUTE_DB
	
func unmute_music():
	volume_db = stored_db
	return volume_db
#	print("Unmute music to %s" % stored_db)

func fade():
	while volume_db > MUTE_DB:
		volume_db -= fade_step
		await get_tree().create_timer(0.1).timeout
	stream_paused = true
	stream = null
	stop()

func play_song(song = "", fade = false):
	var last_song = stream
	if ost.has(song) and stream != ost.get(song):
		stop()
		if fade and stream != null:
			while volume_db > MUTE_DB:
				volume_db -= fade_step
				await get_tree().create_timer(0.05).timeout
		stop()
		stream = ost.get(song)
		if fade:
			while volume_db < stored_db:
				volume_db = clamp(volume_db + fade_step, MUTE_DB, stored_db)
				await get_tree().create_timer(0.05).timeout
		play()
		emit_signal("finished", last_song)


func _on_range_change(value):
	volume_db = value
	stored_db = value

