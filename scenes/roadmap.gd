# roadmap.gd
extends CanvasLayer

onready var cont = $cont
onready var prev_landlord = $cont/prev_landlord
onready var landlord__1 = $cont/landlord_1
onready var landlord__2 = $cont/landlord_2
onready var landlord__1__label = $cont/landlord_1_label
onready var landlord__2__label = $cont/landlord_2_label
onready var title_label = $title
onready var mn = $mN

onready var fade = $fade
onready var tween = $Tween

var title_label_defpos: Vector2 = Vector2.ZERO
var cont_defpos: Vector2 = Vector2.ZERO


func _ready():
	cont.rect_position.x = 240.0
	
	cont_defpos = cont.rect_position
	title_label_defpos = title_label.rect_position
	
	landlord__1.connect("pressed", self, "_on_landlord__1_pressed")
	landlord__2.connect("pressed", self, "_on_landlord__2_pressed")
	
	prev_landlord.texture = load(Global.landlords[Global.currentLandlordIndex]["texture"])
	if Global.health <= 0: prev_landlord.texture = load("res://sprites/landlords/dead_1.png")
	
	if Global.landlords.size() >= Global.currentLandlordIndex + 1+1:
		landlord__1.texture_normal = load(Global.landlords[Global.currentLandlordIndex + 1]["texture"])
		landlord__1__label.text = tr(str(Global.landlords[Global.currentLandlordIndex + 1]["name"])) + "\n\n" + tr(str(Global.landlords[Global.currentLandlordIndex + 1]["desc"]))
	if Global.landlords.size() >= Global.currentLandlordIndex + 2+1:
		landlord__2.texture_normal = load(Global.landlords[Global.currentLandlordIndex + 2]["texture"])
		landlord__2__label.text = tr(str(Global.landlords[Global.currentLandlordIndex + 2]["name"])) + "\n\n" + tr(str(Global.landlords[Global.currentLandlordIndex + 2]["desc"]))
	else: landlord__2.hide()
	
	Global.health = 999
	
	fade.show()
	tween.interpolate_property(fade, "modulate:a", 1.0, 0.0, 1.0)
	tween.start()
	
	yield(get_tree().create_timer(1.0), "timeout")
	fade.hide()
	
	tween.interpolate_property(cont, "rect_position:x", cont.rect_position.x, -320.0, 1.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(1.5), "timeout")
	cont_defpos = cont.rect_position

func _process(delta):
	if !Global.moveByMouse: return
	
	var m: Vector2 = mn.get_global_mouse_position()
	title_label.rect_position = lerp(title_label.rect_position, title_label_defpos + m * 0.02, 15 * delta)
	cont.rect_position = lerp(cont.rect_position, cont_defpos + m * 0.01, 15 * delta)

func _on_landlord__1_pressed():
	Global.currentLandlordIndex += 1
	go_to_next_scene("res://scenes/main.tscn")

func _on_landlord__2_pressed():
	Global.currentLandlordIndex += 2
	go_to_next_scene("res://scenes/main.tscn")

func go_to_next_scene(scenePath: String):
	if scenePath == "": return
	
	fade.modulate.a = 0.0
	fade.show()
	tween.interpolate_property(fade, "modulate:a", 0.0, 1.0, 1.0)
	tween.start()
	
	yield(get_tree().create_timer(1.2), "timeout")
	
	get_tree().change_scene(scenePath)
