class_name SettingsScreen
extends Control


@export var parent: Node
@export var slider_zero_threshold := 0.0
@export_group("Camera Smoothing", "camera_smoothing_")
@export var camera_smoothing_min_value := 0.001
@export var camera_smoothing_max_value := 0.05
@export var camera_smoothing_slider_exp := 3.0
@export_group("Audio", "audio_")
@export var audio_db_min := -30.0
@export var audio_db_max := 0.0

@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var camera_smoothing_slider: HSlider = %CameraSmoothingSlider
@onready var screen_border_check_box: CheckBox = %ScreenBorderCheckBox
@onready var reset_save_data_confirm: Button = %ResetSaveDataConfirm


func _ready() -> void:
	Utility.propogate_mouse_filter(self, Control.MOUSE_FILTER_IGNORE)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and visible:
		Input.action_release("pause")
		parent.close_settings()


func _on_close_button_pressed() -> void:
	parent.close_settings()


func _on_music_volume_slider_value_changed(value: float) -> void:
	if value <= slider_zero_threshold:
		AudioManager.mute_music = true
	else:
		AudioManager.mute_music = false
		AudioManager.volume_db_music = lerpf(audio_db_min, audio_db_max, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	if value <= slider_zero_threshold:
		AudioManager.mute_sfx = true
	else:
		AudioManager.mute_sfx = false
		AudioManager.volume_db_sfx = lerpf(audio_db_min, audio_db_max, value)


func _on_camera_smoothing_slider_value_changed(value: float) -> void:
	var v := (camera_smoothing_max_value - camera_smoothing_min_value)\
			* ((value / 100) ** camera_smoothing_slider_exp)\
			+ camera_smoothing_min_value
	Info.player_camera_smoothing = v


func _on_reset_save_data_button_pressed() -> void:
	reset_save_data_confirm.visible = not reset_save_data_confirm.visible


func _on_reset_save_data_confirm_pressed() -> void:
	Info._reset_save_data()
	parent.respond_to_data_reset()


func _on_screen_border_check_box_toggled(_toggled_on: bool) -> void:
	Debug.OVERLAY_BORDER_VISIBLE = screen_border_check_box.button_pressed
	if is_instance_valid(Info.main_stage):
		Info.main_stage.level_overlay.sync_screen_border_visibility()


func toggle(on: bool) -> void:
	if on:
		var value := 100 * (((Info.player_camera_smoothing - camera_smoothing_min_value)\
				/ (camera_smoothing_max_value - camera_smoothing_min_value))\
				** (1 / camera_smoothing_slider_exp))
		camera_smoothing_slider.value = value
		music_volume_slider.value = 0.0 if AudioManager.mute_music else\
				(AudioManager.volume_db_music - audio_db_min) / (audio_db_max - audio_db_min)
		sfx_volume_slider.value = 0.0 if AudioManager.mute_sfx else\
				(AudioManager.volume_db_sfx - audio_db_min) / (audio_db_max - audio_db_min)
		screen_border_check_box.button_pressed = Debug.OVERLAY_BORDER_VISIBLE
		reset_save_data_confirm.visible = false
		Utility.propogate_mouse_filter(self, Control.MOUSE_FILTER_STOP)
	else:
		Utility.propogate_mouse_filter(self, Control.MOUSE_FILTER_IGNORE)
	visible = on
