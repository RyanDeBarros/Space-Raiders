extends Node


const BUS_MUSIC := &"music"
const BUS_INDEX_MUSIC := 1
const BUS_SFX := &"sfx"
const BUS_INDEX_SFX := 2

const music_muted_db := 100.0
const sfx_muted_db := 100.0


class SFXs:
	static var EXPLOSION := preload("res://assets/audio/sfx/SFX - Death Explosion.ogg")
	static var THRUST := preload("res://assets/audio/sfx/SFX - Main engine thrust.ogg")
	static var SUCCESS := preload("res://assets/audio/sfx/SFX - Success.ogg")
	static var LASER_1 := preload("res://assets/audio/sfx/sfx_laser1.ogg")
	static var LASER_2 := preload("res://assets/audio/sfx/sfx_laser2.ogg")
	static var LOSE := preload("res://assets/audio/sfx/sfx_lose.ogg")
	static var SHIELD_DOWN := preload("res://assets/audio/sfx/sfx_shieldDown.ogg")
	static var SHIELD_UP := preload("res://assets/audio/sfx/sfx_shieldUp.ogg")
	static var TWO_TONE := preload("res://assets/audio/sfx/sfx_twoTone.ogg")
	static var ZAP := preload("res://assets/audio/sfx/sfx_zap.ogg")
	static var LOW_FREQ_EXPLOSION := preload("res://assets/audio/sfx/lowFrequency_explosion_001.ogg")
	static var IMPACT_METAL_1 := preload("res://assets/audio/sfx/impactMetal_001.ogg")
	static var IMPACT_METAL_2 := preload("res://assets/audio/sfx/impactMetal_002.ogg")


class UI_SFXs:
	static var CLICK_1 := preload("res://assets/audio/ui_sfx/click1.ogg")
	static var CLICK_3 := preload("res://assets/audio/ui_sfx/click3.ogg")
	static var CLICK_5 := preload("res://assets/audio/ui_sfx/click5.ogg")
	static var STARTING := preload("res://assets/audio/ui_sfx/starting.ogg")


class SFX_Streams:
	static var CHARGE_UP := preload("res://assets/audio/sfx/spaceEngine_002.ogg")


class Songs:
	static var The_Benjerman := preload("res://assets/audio/soundtrack/Enigmatic Legend - The Benjerman.mp3")
	static var Overall_Control := preload("res://assets/audio/soundtrack/Fionn Hodgson - Overall Control (DJDroidFreak Promotion).mp3")
	static var Spaceman := preload("res://assets/audio/soundtrack/NIGHTkilla - Spaceman.mp3")
	static var Nightfall := preload("res://assets/audio/soundtrack/Nightkilla-Nightfall.mp3")
	static var The_Maze := preload("res://assets/audio/soundtrack/Rukkus - The Maze.mp3")


class Playlists:
	static var MAIN_MENU := Playlist.new([Songs.The_Benjerman])
	static var MAIN_LEVEL := Playlist.new([Songs.Nightfall, Songs.The_Maze, Songs.Spaceman,
			Songs.Overall_Control])


class Playlist:
	var _tracks: Array[AudioStream]
	var _tracks_available: Array[AudioStream]
	
	
	func _init(tracks: Array[AudioStream]) -> void:
		self._tracks = tracks
		reset()
	
	
	func reset() -> void:
		for t in _tracks:
			_tracks_available.push_back(t)
	
	
	func play_next(soundtrack_player: AudioStreamPlayer) -> void:
		if len(_tracks_available) == 0:
			reset()
		var track := _tracks_available.pick_random() as AudioStream
		_tracks_available.erase(track)
		soundtrack_player.stream = track
		soundtrack_player.play()


var sfx_dir_node: Node
var sfx_stream_dir_node: Node
var _stream_id := 0

var soundtrack_player: AudioStreamPlayer
var current_playlist: Playlist

var vol_db_music
var dim_db_music := 0.0

var volume_db_music:
	get:
		return vol_db_music
	set(db):
		vol_db_music = db
		AudioServer.set_bus_volume_db(BUS_INDEX_MUSIC, db + dim_db_music)

var volume_db_sfx:
	get:
		return AudioServer.get_bus_volume_db(BUS_INDEX_SFX)
	set(db):
		AudioServer.set_bus_volume_db(BUS_INDEX_SFX, db)


func dim_music(db: float) -> void:
	dim_db_music = db
	AudioServer.set_bus_volume_db(BUS_INDEX_MUSIC, vol_db_music + db)


var mute_music:
	get:
		return AudioServer.is_bus_mute(BUS_INDEX_MUSIC)
	set(mute):
		AudioServer.set_bus_mute(BUS_INDEX_MUSIC, mute)

var mute_sfx:
	get:
		return AudioServer.is_bus_mute(BUS_INDEX_SFX)
	set(mute):
		AudioServer.set_bus_mute(BUS_INDEX_SFX, mute)


func _init() -> void:
	sfx_dir_node = Node.new()
	sfx_dir_node.name = "SFX Directory"
	AudioServer.add_bus()
	AudioServer.add_bus()
	AudioServer.set_bus_name(BUS_INDEX_MUSIC, BUS_MUSIC)
	AudioServer.set_bus_name(BUS_INDEX_SFX, BUS_SFX)
	sfx_stream_dir_node = Node.new()
	sfx_stream_dir_node.name = "SFX Stream Directory"
	soundtrack_player = AudioStreamPlayer.new()
	soundtrack_player.name = "Soundtrack Player"
	soundtrack_player.bus = BUS_MUSIC
	soundtrack_player.finished.connect(_on_song_end)
	add_child(sfx_dir_node)
	add_child(sfx_stream_dir_node)
	add_child(soundtrack_player)

	mute_music = not Debug.SOUNDTRACK_ON_START
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_song_end() -> void:
	current_playlist.play_next(soundtrack_player)


@warning_ignore("incompatible_ternary")
func play_sfx(sfx: AudioStream, _2d := false, pos := Vector2.ZERO, vol_db := 0.0) -> void:
	var audio = AudioStreamPlayer2D.new() if _2d else AudioStreamPlayer.new()
	if _2d:
		audio.position = pos
	sfx_dir_node.add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.stream = sfx
	audio.volume_db = vol_db
	audio.bus = BUS_SFX
	audio.play()


func play_relative_sound(sfx: AudioStream, pos: Vector2, pos_mult := 1.0, vol_db := 0.0) -> void:
	play_sfx(sfx, true, pos_mult * (pos - Info.player.camera_pos()), vol_db)


@warning_ignore("incompatible_ternary")
func begin_stream(sfx_stream: AudioStream, _2d := false, pos := Vector2.ZERO, vol_db := 0.0) -> int:
	var audio = AudioStreamPlayer2D.new() if _2d else AudioStreamPlayer.new()
	if _2d:
		audio.position = pos
	sfx_stream_dir_node.add_child(audio)
	audio.finished.connect(audio.play)
	audio.stream = sfx_stream
	var id := _stream_id
	_stream_id += 1
	audio.name = stream_name(id)
	audio.volume_db = vol_db
	audio.bus = BUS_SFX
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


func setup_playlist(playlist: Playlist) -> void:
	if current_playlist:
		current_playlist.reset()
	current_playlist = playlist
	_on_song_end()
