extends Control

onready var ver = $ver
onready var music_slider = $settings/musicSlider/HSlider
onready var sound_slider = $settings/soundSlider/HSlider
onready var move_by_mouse_check_box = $settings/moveByMouseCheckBox
onready var fullscreen_check_box = $settings/fullscreenCheckBox
onready var pause_button = $"../pauseButton"
onready var language_option_box = $settings/languageOptionBox
onready var expand_window_check_box = $settings/expandWindowCheckBox
onready var warning_label = $settings/warningLabel
onready var main = $"../.."


func _ready():
	ver.text = Global.ver
	
	language_option_box.add_item("Russian")
	language_option_box.add_item("English")
	language_option_box.selected = 0 if TranslationServer.get_locale() == "ru" else 1
	expand_window_check_box.pressed = Global.expandWindow
	
	pause_button.connect("pressed", self, "_on_pause_button_pressed")
	music_slider.connect("value_changed", self, "_on_slider_changed", [false])
	sound_slider.connect("value_changed", self, "_on_slider_changed", [true])
	move_by_mouse_check_box.connect("pressed", self, "_on_move_by_mouse_check_box_pressed")
	expand_window_check_box.connect("pressed", self, "_on_expand_window_check_box_pressed")
	fullscreen_check_box.connect("pressed", self, "_on_fullscreen_check_box_pressed")
	language_option_box.connect("item_selected", self, "_on_language_option_box_item_selected")
	
	Global.update_music_volume(-50.0)

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

func _on_language_option_box_item_selected(index: int):
	TranslationServer.set_locale("ru" if index == 0 else "en")
	
	warning_label.show()
	
#	get_tree().change_scene("res://scenes/main.tscn")

func _on_expand_window_check_box_pressed():
	get_tree().set_screen_stretch(
		SceneTree.STRETCH_MODE_VIEWPORT,
		SceneTree.STRETCH_ASPECT_EXPAND if expand_window_check_box.pressed else SceneTree.STRETCH_ASPECT_KEEP,
		Vector2(640.0, 480.0)
	)
	
	Global.expandWindow = expand_window_check_box.pressed
	main.reset_m_screen_motion(true)
	warning_label.show()
