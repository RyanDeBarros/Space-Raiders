class_name SettingsScreen
extends Control


@export var parent: Node
@export_group("Camera Smoothing", "camera_smoothing_")
@export var camera_smoothing_min_value := 0.001
@export var camera_smoothing_max_value := 0.05
@export var camera_smoothing_slider_exp := 3.0

@onready var camera_smoothing_slider: HSlider = %CameraSmoothingSlider
@onready var reset_save_data_confirm: Button = %ResetSaveDataConfirm


func _ready() -> void:
	var value := 100 * (((Settings.player_camera_smoothing - camera_smoothing_min_value)\
			/ (camera_smoothing_max_value - camera_smoothing_min_value))\
			** (1 / camera_smoothing_slider_exp))
	camera_smoothing_slider.value = value
	Utility.propogate_mouse_filter(self, Control.MOUSE_FILTER_IGNORE)


func _on_close_button_pressed() -> void:
	parent.close_settings()


func _on_camera_smoothing_slider_value_changed(value: float) -> void:
	var v := (camera_smoothing_max_value - camera_smoothing_min_value)\
			* ((value / 100) ** camera_smoothing_slider_exp)\
			+ camera_smoothing_min_value
	Settings.player_camera_smoothing = v


func toggle(on: bool) -> void:
	if on:
		var value := 100 * (((Settings.player_camera_smoothing - camera_smoothing_min_value)\
				/ (camera_smoothing_max_value - camera_smoothing_min_value))\
				** (1 / camera_smoothing_slider_exp))
		camera_smoothing_slider.value = value
	
	visible = on
	
	if on:
		Utility.propogate_mouse_filter(self, Control.MOUSE_FILTER_STOP)
	else:
		Utility.propogate_mouse_filter(self, Control.MOUSE_FILTER_IGNORE)
	reset_save_data_confirm.visible = false


func _on_reset_save_data_button_pressed() -> void:
	reset_save_data_confirm.visible = not reset_save_data_confirm.visible


func _on_reset_save_data_confirm_pressed() -> void:
	Info._reset_save_data()
	parent.respond_to_data_reset()
