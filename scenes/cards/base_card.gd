# base_card.gd
extends TextureButton

onready var tween: Tween = $"../../Tween"
onready var card_desc = $"../../../../card_desc"
onready var landlord_sprite = $"../../../../bg/landlord"
onready var seal_texturerect = $seal_texturerect

var card_data: Dictionary
var currentDefaultCard: Dictionary
var active: bool = false
var defaultPosition: Vector2


func _init():
	add_to_group("card")

func _ready():
	connect("pressed", self, "_on_pressed")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	defaultPosition = rect_position
	
	if card_data.empty(): card_data = {"base": randi() % Global.defaultCards.size(), "seal": ""}
	currentDefaultCard = Global.defaultCards[card_data["base"]]
	texture_normal = load(currentDefaultCard["texture"])
	if card_data["seal"] != "":
		seal_texturerect.rect_rotation = rand_range(-15, 15)
		seal_texturerect.texture = load(Global.seals[card_data["seal"]]["texture"])
		seal_texturerect.show()
	
	disabled = true
	tween.interpolate_property(self, "rect_position:y", defaultPosition.y + 128.0, defaultPosition.y, 1.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(1.0), "timeout")
	disabled = false

func _on_pressed():
	active = not active
	
	if get_tree().get_nodes_in_group("active card").size() >= int(Global.maxCards / 2):
		active = false
	
	if active: add_to_group("active card")
	else:      remove_from_group("active card")
	
	if active:
		tween.interpolate_property(self, "rect_position:y", defaultPosition.y, defaultPosition.y - 32.0, 0.2, Tween.TRANS_BACK, Tween.EASE_OUT)
	else:
		tween.interpolate_property(self, "rect_position:y", rect_position.y, defaultPosition.y, 0.35, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()

func _on_mouse_entered():
	card_desc.rect_position.y = rect_global_position.y - card_desc.rect_size.y - 8
	card_desc.show()
	tween.interpolate_property(card_desc, "rect_position:x", card_desc.rect_position.x, 8 + rect_position.x - rect_size.x, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE*1.2, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(self, "rect_rotation", rect_rotation, rand_range(-4, 4), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	var text: String = tr(currentDefaultCard["name"])
	var seal: String = card_data["seal"]
	if seal != "":
		text += " [color=gray][" + tr(Global.seals[seal]["name"]) + "]"
	text += "\n\n[color=]" + tr(currentDefaultCard["desc"])
	if seal != "":
		text += "\n\n[color=gray]" + tr(Global.seals[seal]["desc"])
	card_desc.bbcode_text = "[center]" + text

func _on_mouse_exited():
	card_desc.hide()
	tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(self, "rect_rotation", rect_rotation, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func apply_animation():
	remove_from_group("active card")
	var target: Vector2 = landlord_sprite.rect_global_position + landlord_sprite.rect_size / 2 - rect_size / 2
	
	tween.interpolate_property(self, "rect_global_position", rect_global_position, target, 0.35, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.interpolate_property(self, "rect_rotation", rect_rotation, 45.0, 0.35, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.start()
	
	yield(get_tree().create_timer(0.35), "timeout")
	
	tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE*2, 0.15)
	tween.interpolate_property(self, "modulate:a", modulate.a, 0.0, 0.15)
	tween.interpolate_property(self, "rect_rotation", rect_rotation, rect_rotation + 90.0, 0.15)
	tween.interpolate_property(self, "rect_position", rect_position, rect_position + Vector2(rand_range(-128, 128), rand_range(-128, 128)), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	yield(get_tree().create_timer(0.15), "timeout")
	
	queue_free()

func remove():
	tween.interpolate_property(self, "modulate:a", modulate.a, 0.0, 0.3)
	tween.interpolate_property(self, "rect_scale", rect_scale, rect_scale*1.2, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(0.31), "timeout")
	queue_free()
