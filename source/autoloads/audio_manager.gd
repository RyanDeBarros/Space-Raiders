extends Node


enum SFX {
	explosion,
	#thrust,
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

const _SFX_list = [
	preload("res://assets/audio/sfx/SFX - Death Explosion.ogg"),
	#preload("res://assets/audio/sfx/SFX - Main engine thrust.ogg"),
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

var sfx_dir_node: Node
var sfx_stream_dir_node: Node
var _stream_id := 0


func _ready() -> void:
	sfx_dir_node = Node.new()
	sfx_dir_node.name = "SFX Directory"
	sfx_stream_dir_node = Node.new()
	sfx_stream_dir_node.name = "SFX Stream Directory"
	add_child(sfx_dir_node)
	add_child(sfx_stream_dir_node)


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
	audio.volume_db = vol_db
	var id := _stream_id
	_stream_id += 1
	audio.name = stream_name(id)
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
