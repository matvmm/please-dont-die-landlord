# win.gd
extends CanvasLayer

var double_click: int = 0

onready var tween = $Tween
onready var label = $Label


func _ready():
	label.text = (
		"Поздравляем! Вы смогли\nразвить колонию из " + str(Global.headColony+Global.bodyColony+Global.legsColony) + " паразитов!\n" + 
		"Вы сделали " + str(Global.turns) + " ходов!\n" +
		"Вы паратизировали " + str(Global.currentLandlordIndex+1) + " существ!\n\n" +
		"Теперь ваши паразиты будут продолжать\nмучать других существ, заставляя\nих шугаться от любого урчания в животе.\n\n" + 
		"Это ли не повод для гордости?"
	)
	
	Global.play_audio("")
	Global.currentLandlordIndex = 0
	Global.health = 100
	Global.headColony = 0
	Global.bodyColony = 0
	Global.legsColony = 0
	Global.turns = 0
	
	yield(get_tree().create_timer(0.25), "timeout")

	label.percent_visible = 0.0
	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 5.0)
	tween.start()
	yield(get_tree().create_timer(30.0), "timeout")
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 5.0)
	tween.start()
	yield(get_tree().create_timer(5.50), "timeout")
#
#	label.percent_visible = 0.0
#	label.modulate.a = 1.0
#	label.text = labelphrase[1]
#	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
#	tween.start()
#	yield(get_tree().create_timer(4.0), "timeout")
#	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 0.3)
#	tween.start()
#	yield(get_tree().create_timer(0.31), "timeout")
#
#	label.percent_visible = 0.0
#	label.modulate.a = 1.0
#	label.text = labelphrase[2]
#	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
#	tween.start()
#	yield(get_tree().create_timer(2.5), "timeout")
#	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 0.3)
#	tween.start()
#	yield(get_tree().create_timer(0.31), "timeout")
#
#	label.percent_visible = 0.0
#	label.modulate.a = 1.0
#	label.text = labelphrase[3]
#	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
#	tween.start()
#	yield(get_tree().create_timer(3.0), "timeout")
#	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 2.0)
#	tween.start()
#	yield(get_tree().create_timer(3.0), "timeout")
	
	get_tree().change_scene("res://scenes/intro.tscn")

func _input(event):
	if event is InputEvent:
		if event.is_pressed():
			double_click += 1
			if double_click > 1:
				get_tree().change_scene("res://scenes/intro.tscn")
