extends AudioStreamPlayer

const MUTE_DB = -80
const MAX_DB = -10

@export var ost : Dictionary = {}

var additional_track: AudioStreamPlayer

var stored_db = MAX_DB

var track_one_muted = false
var track_two_muted = false

func _ready():
	var initial_db = MAX_DB
	volume_db = initial_db
	additional_track = AudioStreamPlayer.new()
	add_child(additional_track)
	
	additional_track.volume_db = initial_db

func song_playing(song, use_second_track=false):
	var _stream = stream
	if use_second_track:
		_stream = additional_track.stream
	
	for key in ost.keys():
		if _stream == ost.get(key) and key == song:
			return true
	return false
	
func toggle(only_one_track = false, track = 0) -> bool:
	if volume_db == MUTE_DB or only_one_track and track == 1 \
	and additional_track.volume_db == MUTE_DB:
		unmute_music(only_one_track, track)
		return true
	else:
		mute_music(only_one_track, track)
		return false

func mute_music(only_one_track = false, track = 0):
	stored_db = volume_db
	if not only_one_track or only_one_track and track == 0:
		volume_db = MUTE_DB
		track_one_muted = true
	if not only_one_track or only_one_track and track == 1:
		additional_track.volume_db = MUTE_DB
		track_two_muted = true
	
func unmute_music(only_one_track = false, track = 0):
	if not only_one_track or only_one_track and track == 0:
		volume_db = stored_db
		track_one_muted = false
		
		if track_two_muted:
			track_two_muted = false
		
		if only_one_track and track == 0:
			return volume_db
	if not only_one_track or only_one_track and track == 1:
		additional_track.volume_db = stored_db
		track_two_muted = false
		if only_one_track and track == 1:
			return additional_track.volume_db
	return volume_db
#	print("Unmute music to %s" % stored_db)

func fade_out(stop_it = false, use_second_track = false):
	if track_one_muted or use_second_track and track_two_muted:
		return
	
	stored_db = volume_db
	var tween = get_tree().create_tween()
	
	if use_second_track:
		tween.tween_property(additional_track, "volume_db", MUTE_DB, 0.75)
		if stop_it:
			additional_track.stream_paused = true
			additional_track.stream = null
			additional_track.stop()
	else:
		tween.tween_property(self, "volume_db", MUTE_DB, 0.75)
		if stop_it:
			stream_paused = true
			stream = null
			stop()

func fade_in(use_second_track = false):
	if track_one_muted or use_second_track and track_two_muted:
		return
	
	var tween = get_tree().create_tween()
	if use_second_track:
		tween.tween_property(additional_track, "volume_db", stored_db, 0.75)
	else:
		tween.tween_property(self, "volume_db", stored_db, 0.75)

func play_song(song = "", use_second_track = false):
	var _stream = stream
	if use_second_track:
		_stream = additional_track.stream
	
	var last_song = _stream
	if ost.has(song) and _stream != ost.get(song):
		if use_second_track:
			additional_track.stream = ost.get(song)
			print("Playing %s in second track at %s" % [song, additional_track.volume_db])
			additional_track.play()
		else:
			stream = ost.get(song)
			print("Playing %s in first track at %s" % [song, volume_db])
			play()
		emit_signal("finished", last_song)


func _on_range_change(value):
	volume_db = value
	stored_db = value
	additional_track.volume_db = value
	additional_track.stored_db = value

