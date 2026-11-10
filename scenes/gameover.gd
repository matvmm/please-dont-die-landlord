# gameover.gd
extends CanvasLayer

var labelphrase: Array = [
	"Стало тихо.",
	"Больше ни топота лапок. Ни громких шагов. Ни жизни.",
	"Хозяин так и не узнал твоего имени.",
	"Ты и сам его не знал..."
]
var double_click: int = 0
var label_defpos: Vector2 = Vector2.ZERO

onready var tween = $Tween
onready var label = $Label
onready var mn = $mN


func _ready():
	Global.play_music("")
	Global.currentLandlordIndex = 0
	Global.health = 100
	Global.headColony = 0
	Global.bodyColony = 0
	Global.legsColony = 0
	Global.turns = 0
	Global.parasitedLandlords = 0
	Global.reset_deck()
	
	label_defpos = label.rect_position
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	label.percent_visible = 0.0
	label.text = labelphrase[0]
	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
	tween.start()
	yield(get_tree().create_timer(2.0), "timeout")
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, 0.3)
	tween.start()
	yield(get_tree().create_timer(0.31), "timeout")
	
	label.percent_visible = 0.0
	label.modulate.a = 1.0
	label.text = labelphrase[1]
	tween.interpolate_property(label, "percent_visible", 0.0, 1.0, 0.5)
	tween.start()
	yield(get_tree().create_timer(5.5), "timeout")
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
	yield(get_tree().create_timer(1.0), "timeout")
	
	get_tree().change_scene("res://scenes/main.tscn")

func _process(delta):
	if !Global.moveByMouse: return
	
	var m: Vector2 = mn.get_global_mouse_position()
	label.rect_position = lerp(label.rect_position, label_defpos + m * 0.02, 15 * delta)

func _input(event):
	if event is InputEvent:
		if event.is_pressed():
			double_click += 1
			if double_click > 1:
				get_tree().change_scene("res://scenes/main.tscn")
