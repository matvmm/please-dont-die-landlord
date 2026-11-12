extends CanvasLayer

onready var tween = $Tween
onready var seals_control = $seals
onready var seal__1 = $seals/seal_1
onready var seal__2 = $seals/seal_2
onready var seal__3 = $seals/seal_3
onready var seal__1__label = $seals/seal_1_label
onready var seal__2__label = $seals/seal_2_label
onready var seal__3__label = $seals/seal_3_label
onready var fade = $fade
onready var mn = $mN
onready var title_label = $title
onready var sound_player = $soundPlayer

var seal__1_data: String = ""
var seal__2_data: String = ""
var seal__3_data: String = ""
var already_pressed: bool = false
var title_label_defpos: Vector2 = Vector2.ZERO
var seals_control_defpos: Vector2 = Vector2.ZERO

func _ready():
	fade.modulate.a = 1.0
	fade.show()
	
	title_label_defpos = title_label.rect_position
	seals_control_defpos = seals_control.rect_position
	
	randomize()
	
	for i in 3:
		var keys: Array = Global.seals.keys()
		keys.shuffle()
		seal__1_data = str(keys[0])
		seal__2_data = str(keys[1])
		seal__3_data = str(keys[2])
#	seal__1_data = str(Global.seals.keys().pick_random())
#	seal__2_data = str(Global.seals.keys().pick_random())
#	seal__3_data = str(Global.seals.keys().pick_random())
	
	seal__1.connect("pressed", self, "_on_pressed", [seal__1, seal__1__label])
	seal__2.connect("pressed", self, "_on_pressed", [seal__2, seal__2__label])
	seal__3.connect("pressed", self, "_on_pressed", [seal__3, seal__3__label])
	seal__1.connect("mouse_entered", self, "_on_mouse_entered", [seal__1])
	seal__2.connect("mouse_entered", self, "_on_mouse_entered", [seal__2])
	seal__3.connect("mouse_entered", self, "_on_mouse_entered", [seal__3])
	seal__1.connect("mouse_exited", self, "_on_mouse_exited", [seal__1])
	seal__2.connect("mouse_exited", self, "_on_mouse_exited", [seal__2])
	seal__3.connect("mouse_exited", self, "_on_mouse_exited", [seal__3])
	
	seal__1__label.text = "[" + tr(str(Global.seals[seal__1_data]["name"])) + "]\n\n" + tr(str(Global.seals[seal__1_data]["desc"]))
	seal__2__label.text = "[" + tr(str(Global.seals[seal__2_data]["name"])) + "]\n\n" + tr(str(Global.seals[seal__2_data]["desc"]))
	seal__3__label.text = "[" + tr(str(Global.seals[seal__3_data]["name"])) + "]\n\n" + tr(str(Global.seals[seal__3_data]["desc"]))
	seal__1.texture_normal = load(Global.seals[seal__1_data]["texture"])
	seal__2.texture_normal = load(Global.seals[seal__2_data]["texture"])
	seal__3.texture_normal = load(Global.seals[seal__3_data]["texture"])
	
	tween.interpolate_property(fade, "modulate:a", 1.0, 0.0, 1.0)
	tween.start()
	yield(get_tree().create_timer(1.0), "timeout")
	fade.hide()

func _process(delta):
	var m: Vector2 = mn.get_global_mouse_position()
	title_label.rect_position = lerp(title_label.rect_position, title_label_defpos + m * 0.02, 15 * delta)
	seals_control.rect_position = lerp(seals_control.rect_position, seals_control_defpos + m * 0.01, 15 * delta)

func _on_mouse_entered(seal_texturebutton: TextureButton):
	tween.interpolate_property(seal_texturebutton, "rect_scale", seal_texturebutton.rect_scale, Vector2.ONE*1.5, 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

func _on_mouse_exited(seal_texturebutton: TextureButton):
	tween.interpolate_property(seal_texturebutton, "rect_scale", seal_texturebutton.rect_scale, Vector2.ONE, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()

func _on_pressed(seal_texturebutton: TextureButton, seal_label: Label):
	if already_pressed: return
	already_pressed = true
	
	var applySeal: String
	match seal_texturebutton:
		seal__1: applySeal = seal__1_data
		seal__2: applySeal = seal__2_data
		seal__3: applySeal = seal__3_data
	
	var deckCopy: Array = Global.deck.duplicate()
	deckCopy.shuffle()
	
	for card in deckCopy:
		if card["seal"] == "":
			card["seal"] = applySeal
			break
	
	Global.deck = deckCopy
	
	var seals: Array = [seal__1, seal__2, seal__3]
	for i in seals: if i == seal_texturebutton: seals.remove(seals.find(seal_texturebutton))
	var seals_label: Array = [seal__1__label, seal__2__label, seal__3__label]
	for i in seals_label: if i == seal_label: seals_label.remove(seals_label.find(seal_label))
	
	sound_player.volume_db = Global.soundVolume
	sound_player.stream.audio_stream = load("res://sounds/seal1.mp3"); sound_player.play()
	
	tween.interpolate_property(seals[0], "modulate:a", 1.0, 0.0, 0.4)
	tween.interpolate_property(seals[1], "modulate:a", 1.0, 0.0, 0.4)
	tween.interpolate_property(seals_label[0], "modulate:a", 1.0, 0.0, 0.4)
	tween.interpolate_property(seals_label[1], "modulate:a", 1.0, 0.0, 0.4)
	tween.interpolate_property(seals[0], "rect_position:y", seals[0].rect_position.y, seals[0].rect_position.y - 32.0, 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(seals[1], "rect_position:y", seals[1].rect_position.y, seals[1].rect_position.y - 32.0, 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(seals_label[0], "rect_position:y", seals_label[0].rect_position.y, seals_label[0].rect_position.y - 32.0, 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(seals_label[1], "rect_position:y", seals_label[1].rect_position.y, seals_label[1].rect_position.y - 32.0, 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.start()
	go_to_next_scene("res://scenes/next_landlord.tscn")

func go_to_next_scene(scenePath: String):
	if scenePath == "": return
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	fade.modulate.a = 0.0
	fade.show()
	tween.interpolate_property(fade, "modulate:a", 0.0, 1.0, 0.8)
	tween.start()
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	get_tree().change_scene(scenePath)
