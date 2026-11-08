# win.gd
extends CanvasLayer

var double_click: int = 0
var label_defpos: Vector2 = Vector2.ZERO

onready var tween = $Tween
onready var label = $Label
onready var mn = $mN


func _ready():
	label.text = (
		tr("Поздравляем! Вы смогли развить колонию из %d паразитов!") % (Global.headColony+Global.bodyColony+Global.legsColony) + "\n" +
		tr("Вы сделали %d ходов!") % Global.turns + "\n" +
		tr("Вы паразитировали %d существ!") % (Global.currentLandlordIndex+1) + "\n\n" +
		tr("Теперь ваши паразиты будут продолжать мучать других существ, заставляя их шугаться от любого урчания в животе.") + "\n\n" +
		tr("Это ли не повод для гордости?")
	)
	
	Global.play_audio("")
	Global.currentLandlordIndex = 0
	Global.health = 100
	Global.headColony = 0
	Global.bodyColony = 0
	Global.legsColony = 0
	Global.turns = 0
	
	label_defpos = label.rect_position
	
	yield(get_tree().create_timer(0.25), "timeout")

	label.percent_visible = 0.0
	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 5.0)
	tween.start()
	yield(get_tree().create_timer(30.0), "timeout")
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 5.0)
	tween.start()
	yield(get_tree().create_timer(5.50), "timeout")
	
	get_tree().change_scene("res://scenes/intro.tscn")

func _process(delta):
	var m: Vector2 = mn.get_global_mouse_position()
	label.rect_position = lerp(label.rect_position, label_defpos + m * 0.02, 15 * delta)

func _input(event):
	if event is InputEvent:
		if event.is_pressed():
			double_click += 1
			if double_click > 1:
				get_tree().change_scene("res://scenes/intro.tscn")
