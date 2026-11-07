# intro.gd
extends CanvasLayer

var labelphrase: Array = [
	"Игра сделана Drimer544 (Matvey Maksimovich)\nДля ЧРЕВАТОГО ДЖЕМА (2026) от OKNOgmdv",
	"Музыка написана Scewix.",
	"Помогали в тестировании\nULTRAЗемлеройка;\ntapoksila.",
	"Сделано с помощью Godot Engine 3.6.2-stable.",
	"Please Don't Die, Landlord."
]
#var labelphrase: Array = [
#	"UwU",
#	"UwU",
#	"UwU",
#	"UwU",
#]
var double_click: int = 0
var label_defpos: Vector2 = Vector2.ZERO
onready var mn = $mN

onready var tween = $Tween
onready var label = $Label


func _ready():
	Global.play_audio("")
#	Global.currentLandlordIndex = 0
#	Global.health = 100
#	Global.headColony = 0
#	Global.bodyColony = 0
#	Global.legsColony = 0
#	Global.turns = 0
	
	label_defpos = label.rect_position
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	label.percent_visible = 0.0
	label.text = labelphrase[0]
	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
	tween.start()
	yield(get_tree().create_timer(6.0), "timeout")
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 0.3)
	tween.start()
	yield(get_tree().create_timer(0.31), "timeout")
	
	label.percent_visible = 0.0
	label.modulate.a = 1.0
	label.text = labelphrase[1]
	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
	tween.start()
	yield(get_tree().create_timer(3.0), "timeout")
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 0.3)
	tween.start()
	yield(get_tree().create_timer(0.31), "timeout")
	
	label.percent_visible = 0.0
	label.modulate.a = 1.0
	label.text = labelphrase[2]
	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
	tween.start()
	yield(get_tree().create_timer(3.5), "timeout")
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 0.3)
	tween.start()
	yield(get_tree().create_timer(0.31), "timeout")
	
	label.percent_visible = 0.0
	label.modulate.a = 1.0
	label.text = labelphrase[3]
	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
	tween.start()
	yield(get_tree().create_timer(2.5), "timeout")
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 0.3)
	tween.start()
	yield(get_tree().create_timer(0.31), "timeout")
	
	label.percent_visible = 0.0
	label.modulate.a = 1.0
	label.text = labelphrase[4]
	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
	tween.start()
	yield(get_tree().create_timer(3.0), "timeout")
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 2.0)
	tween.start()
	yield(get_tree().create_timer(3.0), "timeout")
	
	get_tree().change_scene("res://scenes/main.tscn")

func _process(delta):
	var m: Vector2 = mn.get_global_mouse_position()
	label.rect_position = lerp(label.rect_position, label_defpos + m * 0.02, 15 * delta)

func _input(event):
	if event is InputEvent:
		if event.is_pressed():
			double_click += 1
			if double_click > 1:
				get_tree().change_scene("res://scenes/main.tscn")
