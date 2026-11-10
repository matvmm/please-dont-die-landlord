extends Control

onready var ver = $ver
onready var music_slider = $settings/musicSlider/HSlider
onready var sound_slider = $settings/soundSlider/HSlider
onready var move_by_mouse_check_box = $settings/moveByMouseCheckBox
onready var fullscreen_check_box = $settings/fullscreenCheckBox
onready var pause_button = $"../pauseButton"


func _ready():
	ver.text = Global.ver
	
	pause_button.connect("pressed", self, "_on_pause_button_pressed")
	music_slider.connect("value_changed", self, "_on_slider_changed", [false])
	sound_slider.connect("value_changed", self, "_on_slider_changed", [true])
	move_by_mouse_check_box.connect("pressed", self, "_on_move_by_mouse_check_box_pressed")
	fullscreen_check_box.connect("pressed", self, "_on_fullscreen_check_box_pressed")

func _on_pause_button_pressed():
	visible = not visible

func _input(event):
	if event is InputEvent:
		if event.is_action_pressed("PAUSE"):
			visible = not visible
		
		get_tree().paused = visible

func _on_slider_changed(value: float, music_or_sound: bool):
	match music_or_sound:
		false: Global.update_music_volume(value)
		true : Global.update_sound_volume(value)

func _on_move_by_mouse_check_box_pressed():
	Global.moveByMouse = move_by_mouse_check_box.pressed

func _on_fullscreen_check_box_pressed():
	Global.toggle_fullscreen(fullscreen_check_box.pressed)
