extends Node


enum AUDIO_BUSES {
	MUSIC = 1,
	SFX = 2
}

enum SFX {
	explosion,
	thrust,
	success,
	laser_1,
	laser_2,
	lose,
	shield_down,
	shield_up,
	two_tone,
	zap,
	low_freq_explosion,
	impact_metal_1,
	impact_metal_2,
}

enum SFX_stream {
	charge_up
}

enum SONGS {
	The_Benjerman,
	Overall_Control,
	Spaceman,
	Nightfall,
	The_Maze
}

const _AUDIO_BUSES_list = {
	1: &"music",
	2: &"sfx"
}

const _SFX_list = [
	preload("res://assets/audio/sfx/SFX - Death Explosion.ogg"),
	preload("res://assets/audio/sfx/SFX - Main engine thrust.ogg"),
	preload("res://assets/audio/sfx/SFX - Success.ogg"),
	preload("res://assets/audio/sfx/sfx_laser1.ogg"),
	preload("res://assets/audio/sfx/sfx_laser2.ogg"),
	preload("res://assets/audio/sfx/sfx_lose.ogg"),
	preload("res://assets/audio/sfx/sfx_shieldDown.ogg"),
	preload("res://assets/audio/sfx/sfx_shieldUp.ogg"),
	preload("res://assets/audio/sfx/sfx_twoTone.ogg"),
	preload("res://assets/audio/sfx/sfx_zap.ogg"),
	preload("res://assets/audio/sfx/lowFrequency_explosion_001.ogg"),
	preload("res://assets/audio/sfx/impactMetal_001.ogg"),
	preload("res://assets/audio/sfx/impactMetal_002.ogg"),
]

const _SFX_stream_list = [
	preload("res://assets/audio/sfx/spaceEngine_002.ogg"),
]

const _SONGS_list = [
	preload("res://assets/audio/soundtrack/Enigmatic Legend - The Benjerman.mp3"),
	preload("res://assets/audio/soundtrack/Fionn Hodgson - Overall Control (DJDroidFreak Promotion).mp3"),
	preload("res://assets/audio/soundtrack/NIGHTkilla - Spaceman.mp3"),
	preload("res://assets/audio/soundtrack/Nightkilla-Nightfall.mp3"),
	preload("res://assets/audio/soundtrack/Rukkus - The Maze.mp3")
]

var sfx_dir_node: Node
var sfx_stream_dir_node: Node
var _stream_id := 0

var soundtrack_player: AudioStreamPlayer
var playlist: Array
var _playlist_id := 0

var volume_db_music:
	get:
		return AudioServer.get_bus_volume_db(AUDIO_BUSES.MUSIC)
	set(db):
		AudioServer.set_bus_volume_db(AUDIO_BUSES.MUSIC, db)

var volume_db_sfx:
	get:
		return AudioServer.get_bus_volume_db(AUDIO_BUSES.SFX)
	set(db):
		AudioServer.set_bus_volume_db(AUDIO_BUSES.SFX, db)

var mute_music:
	get:
		return AudioServer.is_bus_mute(AUDIO_BUSES.MUSIC)
	set(mute):
		AudioServer.set_bus_mute(AUDIO_BUSES.MUSIC, mute)

var mute_sfx:
	get:
		return AudioServer.is_bus_mute(AUDIO_BUSES.SFX)
	set(mute):
		AudioServer.set_bus_mute(AUDIO_BUSES.SFX, mute)


func _ready() -> void:
	sfx_dir_node = Node.new()
	sfx_dir_node.name = "SFX Directory"
	AudioServer.add_bus()
	AudioServer.add_bus()
	AudioServer.set_bus_name(1, _AUDIO_BUSES_list[AUDIO_BUSES.MUSIC])
	AudioServer.set_bus_name(2, _AUDIO_BUSES_list[AUDIO_BUSES.SFX])
	sfx_stream_dir_node = Node.new()
	sfx_stream_dir_node.name = "SFX Stream Directory"
	soundtrack_player = AudioStreamPlayer.new()
	soundtrack_player.name = "Soundtrack Player"
	soundtrack_player.bus = _AUDIO_BUSES_list[AUDIO_BUSES.MUSIC]
	soundtrack_player.finished.connect(_on_song_end)
	add_child(sfx_dir_node)
	add_child(sfx_stream_dir_node)
	add_child(soundtrack_player)
	
	setup_playlist([SONGS.The_Benjerman, SONGS.Nightfall])
	mute_music = not Debug.SOUNDTRACK_ON_START
	
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_song_end() -> void:
	_playlist_id = (_playlist_id + 1) % len(playlist)
	soundtrack_player.stream = playlist[_playlist_id]
	soundtrack_player.play()


@warning_ignore("incompatible_ternary")
func play_sfx(sfx: SFX, _2d := false, pos := Vector2.ZERO, vol_db := 0.0) -> void:
	var audio = AudioStreamPlayer2D.new() if _2d else AudioStreamPlayer.new()
	if _2d:
		audio.position = pos
	sfx_dir_node.add_child(audio)
	audio.name = "SFX[%s]" % SFX.keys()[sfx]
	audio.finished.connect(audio.queue_free)
	audio.stream = _SFX_list[sfx]
	audio.volume_db = vol_db
	audio.bus = _AUDIO_BUSES_list[AUDIO_BUSES.SFX]
	audio.play()


func play_relative_sound(sfx: SFX, pos: Vector2, pos_mult := 1.0, vol_db := 0.0) -> void:
	play_sfx(sfx, true, pos_mult * (pos - Info.player.camera_pos()), vol_db)


@warning_ignore("incompatible_ternary")
func begin_stream(sfx_stream: SFX_stream, _2d := false, pos := Vector2.ZERO, vol_db := 0.0) -> int:
	var audio = AudioStreamPlayer2D.new() if _2d else AudioStreamPlayer.new()
	if _2d:
		audio.position = pos
	sfx_stream_dir_node.add_child(audio)
	audio.finished.connect(audio.play)
	audio.stream = _SFX_stream_list[sfx_stream]
	var id := _stream_id
	_stream_id += 1
	audio.name = stream_name(id)
	audio.volume_db = vol_db
	audio.bus = _AUDIO_BUSES_list[AUDIO_BUSES.SFX]
	audio.play()
	return id


func cancel_stream(id: int) -> bool:
	var audio = sfx_stream_dir_node.find_child(stream_name(id), false, false)
	if audio:
		audio.queue_free()
		return true
	return false


func stream_name(id: int) -> String:
	return "AudioStream#%s" % str(id)


func setup_playlist(songs: Array[SONGS], starting_id := 0, start_playing := true) -> void:
	playlist.clear()
	for song in songs:
		playlist.push_back(_SONGS_list[song])
	_playlist_id = starting_id
	if start_playing:
		soundtrack_player.stream = playlist[_playlist_id]
		soundtrack_player.play()
