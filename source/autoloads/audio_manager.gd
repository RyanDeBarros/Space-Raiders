extends Node


const SFX = {
	"laser_1": preload("res://assets/audio/sfx/sfx_laser1.ogg"),
	"laser_2": preload("res://assets/audio/sfx/sfx_laser2.ogg"),
	"lose": preload("res://assets/audio/sfx/sfx_lose.ogg"),
	"shield_down": preload("res://assets/audio/sfx/sfx_shieldDown.ogg"),
	"shield_up": preload("res://assets/audio/sfx/sfx_shieldUp.ogg"),
	"two_tone": preload("res://assets/audio/sfx/sfx_twoTone.ogg"),
	"zap": preload("res://assets/audio/sfx/sfx_zap.ogg"),
}

var sfx_dir_node: Node


func _ready() -> void:
	sfx_dir_node = Node.new()
	add_child(sfx_dir_node)


func play_sfx(name: String, _2d := false, pos := Vector2.ZERO) -> void:
	var audio = AudioStreamPlayer2D.new() if _2d else AudioStreamPlayer.new()
	if _2d:
		audio.position = pos
	sfx_dir_node.add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.stream = SFX[name]
	audio.play()
