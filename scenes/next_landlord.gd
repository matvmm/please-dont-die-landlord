extends CanvasLayer

onready var all = $all
onready var prev_landlord = $all/prevLandlord
onready var next_landlord = $all/nextLandlord
onready var prev_landlord_label = $all/prevLandlordLabel
onready var next_landlord_label = $all/nextLandlordLabel
onready var tween = $Tween
onready var fade = $fade

var double_click: int = 0


func _ready():
	if Global.health <= 0:
		prev_landlord.texture = load("res://sprites/landlords/dead_1.png")
	else:
		prev_landlord.texture = load(Global.landlords[Global.currentLandlordIndex]["texture"])
	
	randomize()
	var nextLandlordIndex: int = Global.currentLandlordIndex + 1 + randi() % 2 # +1 or +2
	while nextLandlordIndex >= Global.landlords.size():
		randomize()
		nextLandlordIndex = Global.currentLandlordIndex + 1 + randi() % 2 # +1 or +2
	next_landlord.texture = load(Global.landlords[nextLandlordIndex]["texture"])
	next_landlord_label.text = str(Global.landlords[nextLandlordIndex]["name"]) + "\n\n" + str(Global.landlords[nextLandlordIndex]["desc"])
	prev_landlord_label.text = str(Global.landlords[Global.currentLandlordIndex]["name"]) + "\n\n" + str(Global.landlords[Global.currentLandlordIndex]["desc"])
	
	Global.currentLandlordIndex = nextLandlordIndex
	
	
	fade.modulate.a = 1.0
	fade.show()
	all.rect_position.x = 400.0
	tween.interpolate_property(fade, "modulate:a", 1.0, 0.0, 1.0)
	tween.start()
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(1.5), "timeout")
	fade.hide()
	
	tween.interpolate_property(all, "rect_position:x", 400.0, -400.0, 2.0, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(2.5), "timeout")
	
	fade.modulate.a = 0.0
	fade.show()
	tween.interpolate_property(fade, "modulate:a", 0.0, 1.0, 1.0)
	tween.start()
	yield(tween, "tween_all_completed")
	
	get_tree().change_scene("res://scenes/main.tscn")

func _input(event):
	if event is InputEvent:
		if event.is_pressed():
			double_click += 1
			if double_click > 1:
				get_tree().change_scene("res://scenes/main.tscn")
