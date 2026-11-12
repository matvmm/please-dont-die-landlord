# main.gd
extends Node2D

onready var canvas_layer = $CanvasLayer
onready var endturn_button = $CanvasLayer/bottom/hbox/endturn_button
onready var cards = $CanvasLayer/bottom/hbox/cards
onready var healthbar_label = $CanvasLayer/top/healthbar/Label
onready var healthbar = $CanvasLayer/top/healthbar
onready var turnlabel = $CanvasLayer/pBottom/hbox/turnlabel
onready var colonylabel = $CanvasLayer/pBottom/hbox/colonylabel
onready var tween = $Tween
onready var right = $CanvasLayer/right
onready var head_button = $CanvasLayer/right/vbox/head_button
onready var body_button = $CanvasLayer/right/vbox/body_button
onready var legs_button = $CanvasLayer/right/vbox/legs_button
onready var bottom = $CanvasLayer/bottom
onready var head_colony_label = $CanvasLayer/right/head_colony_label
onready var body_colony_label = $CanvasLayer/right/body_colony_label
onready var legs_colony_label = $CanvasLayer/right/legs_colony_label
onready var top = $CanvasLayer/top
onready var bg = $CanvasLayer/bg/bg
onready var landlord_texturerect = $CanvasLayer/bg/landlord
onready var fade = $CanvasLayer/fade
onready var defaultanimation = $defaultanimation
onready var defaultanimation2 = $defaultanimation2
onready var thought_texturerect = $CanvasLayer/thought/TextureRect
onready var thought_label = $CanvasLayer/thought/Label
onready var shading = $CanvasLayer/shading
onready var thought_control = $CanvasLayer/thought
onready var p_bottom = $CanvasLayer/pBottom
onready var colonyadd_label = $CanvasLayer/pBottom/colonyadd
onready var colonybar = $CanvasLayer/pBottom/colonybar
onready var status_control = $CanvasLayer/status
onready var label_status = $CanvasLayer/status/Label
onready var rain_event_particles = $CanvasLayer/bg/rain_event
onready var sound_player = $soundPlayer
onready var canvas_modulate = $CanvasLayer/CanvasModulate
onready var heat_event_particles = $CanvasLayer/bg/heat_event
onready var cold_event_particles = $CanvasLayer/bg/cold_event

var draw_pile: Array = []
var discard_pile: Array = []
var endturn_already_pressed: bool = false
var currentLandlord: Dictionary
var thought: Dictionary
var round_over: bool = false
var thought_muted: bool = false
var replace_hand: bool = false
var defaultanimdtionTime: float = 1.0
var mScreenMotion: Dictionary = {
	"top": Vector2.ZERO,
	"right": Vector2.ZERO,
	"bottom": Vector2.ZERO,
	"pBottom": Vector2.ZERO,
	"thought": Vector2.ZERO,
	"landlord": Vector2.ZERO
}
var sounds: Array = [
	preload("res://sounds/landlord_died1.mp3"),
]


func _init():
	randomize()

func _ready():
	right.hide()
	fade.modulate.a = 1.0
	fade.show()
#	currentLandlord = Global.landlords[Global.currentLandlordIndex]
	currentLandlord = build_landlord(Global.landlords[Global.currentLandlordIndex])
	landlord_texturerect.texture = load(currentLandlord["texture"])
	healthbar.max_value = currentLandlord["health"]
	colonybar.max_value = currentLandlord["need"]
	Global.health = currentLandlord["health"]
	if Global.deck.empty(): Global.reset_deck()
	draw_pile = Global.deck.duplicate()
	draw_pile.shuffle()
	trigger_random_event()
	
	reset_m_screen_motion()
	
#	if Global.currentLandlordIndex < 3: Global.play_music("res://music/default_music_1.mp3")
#	else:                               Global.play_music("res://music/default_music_2.mp3")
	Global.play_music("res://music/default_music_1.mp3")
	
#	match Global.currentLandlordIndex:
#		0,1,2: Global.maxCards = 5
#		3,4  : Global.maxCards = 7
#	Global.maxCards = 2 + Global.currentLandlordIndex * 1.5
#	Global.maxCards = Global.currentLandlordIndex % 3 + 2
	Global.maxCards = clamp(4 + 2 * int(Global.currentLandlordIndex / 3), 4, 7)
	
	endturn_button.connect("pressed", self, "_on_endturn_button_pressed")
	head_button.connect("pressed", self, "_on_head_button_pressed")
	body_button.connect("pressed", self, "_on_body_button_pressed")
	legs_button.connect("pressed", self, "_on_legs_button_pressed")
	
	update_label()
	endturn_button.text = tr("ЗАВЕРШИТЬ ХОД").replace(" ", "\n")
	defaultanimation.connect("tween_all_completed", self, "_run_default_animation")
	_run_default_animation()
	plan_thought()
	give_cards(Global.maxCards)
	
	tween.interpolate_property(fade, "modulate:a", 1.0, 0.0, 1.0)
	tween.start()
	
	yield(get_tree().create_timer(1.0), "timeout")
	fade.hide()

func reset_m_screen_motion(fromSettings: bool = false):
	var mSave: bool = Global.moveByMouse
	Global.moveByMouse = false
	
	if fromSettings:
		yield(get_tree(), "idle_frame")
		
		bottom.rect_position = mScreenMotion["bottom"]
		p_bottom.rect_position = mScreenMotion["pBottom"]
		top.rect_position = mScreenMotion["top"]
		right.rect_position = mScreenMotion["right"]
		thought_control.rect_position = mScreenMotion["thought"]
		landlord_texturerect.rect_position = mScreenMotion["landlord"]
	
	get_tree().paused = false
	yield(get_tree(), "idle_frame")
	
	mScreenMotion["bottom"] = bottom.rect_position
	mScreenMotion["pBottom"] = p_bottom.rect_position
	mScreenMotion["top"] = top.rect_position
	mScreenMotion["right"] = right.rect_position
	mScreenMotion["thought"] = thought_control.rect_position
	mScreenMotion["landlord"] = landlord_texturerect.rect_position
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if fromSettings: get_tree().paused = true
	
	Global.moveByMouse = mSave

func _run_default_animation():
#	defaultanimation.repeat = true
#	defaultanimation.interpolate_property(landlord_texturerect, "rect_scale:x", 1.0, -1.0, 0.8, Tween.TRANS_BACK, Tween.EASE_OUT, 7.5)
#	defaultanimation.interpolate_property(landlord_texturerect, "rect_scale:x", -1.0, 1.0, 0.8, Tween.TRANS_BACK, Tween.EASE_OUT, 15.0)
#	defaultanimation.start()
	defaultanimation2.repeat = true
	defaultanimation2.interpolate_property(landlord_texturerect, "rect_scale", Vector2(1.0, 0.95), Vector2(0.95, 1.0), defaultanimdtionTime, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	defaultanimation2.interpolate_property(landlord_texturerect, "rect_scale", Vector2(0.95, 1.0), Vector2(1.0, 0.95), defaultanimdtionTime, Tween.TRANS_CIRC, Tween.EASE_IN_OUT, defaultanimdtionTime)
	defaultanimation2.start()

func _process(delta):
	if !Global.moveByMouse: return
	
	var m: Vector2 = get_global_mouse_position()
	var mSM: Dictionary = mScreenMotion
	var s1: float = 0.04
	var s2: float = 0.01
	var s3: float = 0.02
	
	bottom.rect_position = lerp(bottom.rect_position, mSM["bottom"] + m * s2, 15 * delta)
	top.rect_position = lerp(top.rect_position, mSM["top"] + m * s2, 15 * delta)
	right.rect_position = lerp(right.rect_position, mSM["right"] + m * s2, 15 * delta)
	p_bottom.rect_position = lerp(p_bottom.rect_position, mSM["pBottom"] + m * s3, 15 * delta)
	
	thought_control.rect_position = lerp(thought_control.rect_position, mSM["thought"] + m * s1, 15 * delta)
	landlord_texturerect.rect_position = lerp(landlord_texturerect.rect_position, mSM["landlord"] + m * s1, 15 * delta)

func _on_endturn_button_pressed():
	if endturn_already_pressed: return
	
	var played: Array = []
	for card in cards.get_children():
		if card.active: played.append(card)
	if played.empty(): return
	
	right.show()
	tween.interpolate_property(right, "rect_position:x", get_viewport_rect().size.x+128.0, get_viewport_rect().size.x-96.0-8.0, 0.4, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

func _on_head_button_pressed():
	right.hide()
	end_turn(1)
func _on_body_button_pressed():
	right.hide()
	end_turn(2)
func _on_legs_button_pressed():
	right.hide()
	end_turn(3)

func end_turn(attack: int):   # 1 - head, 2 - body, 3 - legs
	var played: Array = []
	for card in cards.get_children():
		if card.active: played.append(card)
	if played.empty(): return
	
	endturn_already_pressed = true
	
#	tween.interpolate_property(bottom, "modulate:a", bottom.modulate.a, 0.5, 0.25)
#	tween.start()
	yield(get_tree().create_timer(0.3), "timeout")
	
	### считаем бонус при верном попадании паразита, или наоборот вычет из колонии, если он не прижился.
	thought_muted = false
	replace_hand = false
	var gains := {1: 0, 2: 0, 3: 0}
	for card in played:
		apply_card(card, attack, played, gains)
		if card.card_data["seal"] == "clingy" && card.currentDefaultCard["bestPlace"] == attack:
			draw_pile.append(card.card_data)
		else:
			discard_pile.append(card.card_data)
		card.apply_animation()
	if replace_hand:
		for i in cards.get_children():
			if !i.active:
				discard_pile.append(i)
				i.remove()
	
	yield(get_tree().create_timer(0.6), "timeout")
	
	Global.turns += 1
	
	var prev_colony: int = Global.headColony+Global.bodyColony+Global.legsColony
	### если колония в одной из частей тела начата, то она продолжает размножаться автономно
	randomize()
	if Global.headColony > 0: Global.headColony += int(ceil(Global.headColony / 6.0))
	if Global.bodyColony > 0: Global.bodyColony += int(ceil(Global.bodyColony / 9.0))
	if Global.legsColony > 0: Global.legsColony += int(ceil(Global.legsColony / 11.0))
	
	### применяем бонус
#	match attack:
#		1: Global.headColony += gains[1]
#		2: Global.bodyColony += gains[2]
#		3: Global.legsColony += gains[3]
	Global.headColony += gains[1]
	Global.bodyColony += gains[2]
	Global.legsColony += gains[3]
	
	### не даём колонии уйти в минус
	Global.headColony = max(Global.headColony, 0)
	Global.bodyColony = max(Global.bodyColony, 0)
	Global.legsColony = max(Global.legsColony, 0)
	
	### вычитаем здоровье
	Global.health -= int(ceil(Global.headColony / 2.0))
	Global.health -= int(ceil(Global.bodyColony / 3.0))
	Global.health -= int(ceil(Global.legsColony / 3.5))
	Global.health = max(Global.health, 0)
	
	### применяем действия из текущей мысли и планируем новую
	if !thought_muted: apply_thought()
	plan_thought()
	
	### не даём здоровью выйти за рамки
	Global.health = clamp(Global.health, 0, currentLandlord["health"])
	
	shake(landlord_texturerect, 2.0, 16)
	
	tween.interpolate_property(bg, "modulate:a", bg.modulate.a, clamp(0.1 - Global.health * 0.001, 0.0, 0.2), 5.0)
	tween.start()
	
#	tween.interpolate_property(top, "rect_scale", Vector2.ONE*1.05, Vector2.ONE, 0.6, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
#	tween.start()
	shake(top, 4.0, 8.0)
	update_label(prev_colony)
	if round_over: return
	
	yield(get_tree().create_timer(0.6), "timeout")
	give_cards(Global.maxCards)
	yield(get_tree().create_timer(0.2), "timeout")
	
	tween.interpolate_property(bottom, "modulate:a", bottom.modulate.a, 1.0, 0.2)
	tween.start()
	
	endturn_already_pressed = false

func draw_card() -> Dictionary:
	if draw_pile.empty():
		draw_pile = discard_pile.duplicate()
		draw_pile.shuffle()
		discard_pile.clear()
	if draw_pile.empty(): return {}
	return draw_pile.pop_back()

func give_cards(amount: int):
	while cards.get_child_count() < amount:
		yield(get_tree().create_timer(0.1), "timeout")
		var card = load("res://scenes/cards/card1.tscn").instance()
		card.card_data = draw_card()
		cards.add_child(card)

func base_amount(zone: int) -> int:
	match zone:
		1: return 1 + randi() % 2
		2: return 1 + randi() % 2
	return 1 + randi() % 2

func show_status(sText: String, duration: int = 6.0):
	label_status.text = sText
	status_control.show()
	tween.interpolate_property(status_control, "modulate:a", 0.0, 1.0, 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	yield(get_tree().create_timer(duration - 1.0), "timeout")
	
	tween.interpolate_property(status_control, "modulate:a", 1.0, 0.0, 2.0)
	tween.start()
	
	yield(get_tree().create_timer(2.1), "timeout")
	
	status_control.hide()

func trigger_random_event():
	if Global.currentLandlordIndex == 0: return
	randomize()
	if randf() > 0.50: return # 50%
	
	var event_type = randi() % 4
	match event_type:
		0:  # дождь
			rain_event_particles.emission_rect_extents.x = get_viewport_rect().size.x/2
			rain_event_particles.position.x = get_viewport_rect().size.x/2
			rain_event_particles.emitting = true
			rain_event_particles.show()
			currentLandlord["activities"]["event_rain_weather"] = 10
			currentLandlord["activities"].erase("jog")
			currentLandlord["activities"].erase("hide")
			show_status("На улице начался дождь. Хозяин раздражен.", 3.5)
		1:  # сильный ливень
			rain_event_particles.emission_rect_extents.x = get_viewport_rect().size.x/2
			rain_event_particles.position.x = get_viewport_rect().size.x/2
			rain_event_particles.emitting = true
			rain_event_particles.amount *= 8.0
			rain_event_particles.speed_scale *= 1.25
			rain_event_particles.texture.height *= 2.0
			rain_event_particles.show()
			currentLandlord["activities"]["event_rain_weather"] = 10
			currentLandlord["activities"].erase("jog")
			currentLandlord["activities"].erase("hide")
			show_status("На улице начался сильный ливень. Хозяин раздражен.", 3.5)
		2:  # жара
			heat_event_particles.emission_rect_extents.x = get_viewport_rect().size.x/2
			heat_event_particles.position.x = get_viewport_rect().size.x/2
			heat_event_particles.emitting = true
			heat_event_particles.show()
			currentLandlord["activities"]["event_heat"] = 10
			currentLandlord["activities"].erase("sleep")
			currentLandlord["activities"].erase("nap")
			currentLandlord["activities"].erase("bath")
			show_status("На улице невыносимая жара. Хозяин страдает от обезвоживания.", 3.5)
		3:  # холод
			cold_event_particles.emission_rect_extents.x = get_viewport_rect().size.x/2
			cold_event_particles.position.x = get_viewport_rect().size.x/2
			cold_event_particles.emitting = true
			cold_event_particles.show()
			currentLandlord["activities"]["event_cold_weather"] = 10
			currentLandlord["activities"].erase("jog")
			currentLandlord["activities"].erase("bath")
			currentLandlord["activities"].erase("drink")
			show_status(tr("На улице резко похолодало. Хозяин дрожит."), 3.5)











func apply_card(card, attack: int, played: Array, gains: Dictionary):
	var best: int = card.currentDefaultCard["bestPlace"]
	var seal: String = card.card_data["seal"]
	var amount: int = base_amount(attack)
	
	if best == attack:
		gains[attack] += amount
		match seal:
			"greedy":
				gains[attack] += int(ceil(amount / 2.0))
			"scavenger":
				if is_scared():
					gains[attack] += amount
			"sleepy":
				thought_muted = true
			"pack":
				for other in played:
					if other != card && other.currentDefaultCard["bestPlace"] == attack:
						gains[attack] += int(ceil(amount / 2.0))
			"megacool":
				gains[attack] = currentLandlord["need"]
			"randomity":
				randomize()
				gains[attack] += int(rand_range(-currentLandlord["need"] / 2, currentLandlord["need"] / 2))
			"replacement":
				replace_hand = true
	else:
		match seal:
			"exile":
				gains[best] += int(amount / 2)
			"greedy":
				gains[attack] -= amount * 2
			"megacool":
				gains[attack] = currentLandlord["need"]
			"randomity":
				randomize()
				gains[attack] += int(rand_range(-currentLandlord["need"] / 4, currentLandlord["need"] / 4))
			"replacement":
				replace_hand = true
			_:
				gains[attack] -= amount











func update_label(prev_colony: int = -1):
	var colony: int = Global.headColony+Global.bodyColony+Global.legsColony
	turnlabel.text = tr("Ход") + ": " + str(Global.turns)
	colonylabel.text = tr("Колония") + ": " + str(colony) + " / " + str(currentLandlord["need"])
	tween.interpolate_property(healthbar, "value", healthbar.value, Global.health, 0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(colonybar, "value", colonybar.value, colony, 0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(colonybar, "modulate:a", 1.0, 0.1, 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	if prev_colony != -1:
		colonyadd_label.text = ("+" if prev_colony < colony else "") + str(colony - prev_colony)
		tween.interpolate_property(colonyadd_label, "rect_position:y", 11.0-colonyadd_label.rect_size.y, 11.0-18.0, 0.75, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(colonyadd_label, "modulate:a", 1.0, 0.0, 1.0)
	Global.nColony = colony
	tween.start()
#	healthbar.value = Global.health
	healthbar_label.text = " " + tr("Здоровье") + ": " + str(Global.health) + " / " + str(currentLandlord["health"]) + " %"
	head_colony_label.text = tr("Голова") + ": " + str(Global.headColony) + " "
	body_colony_label.text = tr("Тело") + ": " + str(Global.bodyColony) + " "
	legs_colony_label.text = tr("Ноги") + ": " + str(Global.legsColony) + " "
	
	tween.interpolate_property(shading, "texture:fill_to", shading.texture.fill_to, Vector2(2.8, 0) if !is_scared() else Vector2(1.2, 0.0), 4.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
#	shading.texture.fill_to = Vector2(2.5, 0) if !is_scared() else Vector2(1.5, 0)
	
	sound_player.volume_db = Global.soundVolume
	if colony >= currentLandlord["need"]:
		round_over = true
		Global.parasitedLandlords += 1
		
		if Global.health <= 0:
			landlord_texturerect.texture = load("res://sprites/landlords/dead_1.png")
			defaultanimation2.stop_all()
			sound_player.stream.audio_stream = sounds[0]; sound_player.play()
			shake(canvas_layer, 2.0, 24.0)
			
			var prevColony: int = colony
			Global.nColony = prevColony
			
			var loss_mult: float = rand_range(0.5, 0.75)
			Global.headColony = int(Global.headColony * loss_mult)
			Global.bodyColony = int(Global.bodyColony * loss_mult)
			Global.legsColony = int(Global.legsColony * loss_mult)
			
			var targetColony: int = Global.headColony+Global.bodyColony+Global.legsColony
			var addText: String = "[" + str(prevColony) + " - " + str(prevColony - targetColony) + " = " + str(targetColony) + "]"
			# [11/11/2026] господи как же я заебался это писать, 5 час идёт сидения за этим ебаный, обоссанным кодом. это ощущается словно меня в жопу ебут. быстрее бы это закончилось.
			
			yield(show_status("Хозяин умер, но вы успели развить колонию. Из-за этого часть вашей колонии вымерла!" + "\n" + addText, 5.0), "completed")
		
		if Global.landlords.size() <= Global.currentLandlordIndex+1:
			go_to_next_scene("res://scenes/win.tscn")
			return
		go_to_next_scene("res://scenes/seal_give.tscn")
		round_over = true
		return
	
	if Global.health <= 0 || (colony <= (currentLandlord["need"] * 0.2) && Global.currentLandlordIndex != 0):
		if Global.health <= 0:
			defaultanimation2.stop_all()
			landlord_texturerect.texture = load("res://sprites/landlords/dead_1.png")
			shake(canvas_layer, 2.0, 24.0)
			sound_player.stream.audio_stream = sounds[0]; sound_player.play()
		go_to_next_scene("res://scenes/gameover.tscn")
		round_over = true
		return
	if is_scared():
		landlord_texturerect.texture = load(currentLandlord["lowhealth_texture"])
		shake(landlord_texturerect, 1.0, 9999999)
		defaultanimdtionTime = 1.8; _run_default_animation()
		shake(canvas_layer, 2.0, 12.0)
	else:
		landlord_texturerect.texture = load(currentLandlord["texture"])
		shake(landlord_texturerect, 0.0, 0, true)

func go_to_next_scene(scenePath: String):
	if scenePath == "": return
	
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	tween.interpolate_property(bottom, "modulate:a", 1.0, 0.0, 1.0)
	tween.interpolate_property(right, "modulate:a", 1.0, 0.0, 1.0)
	tween.interpolate_property(top, "modulate:a", 1.0, 0.0, 1.0)
	tween.interpolate_property(p_bottom, "modulate:a", 1.0, 0.0, 1.0)
	tween.interpolate_property(thought_label.get_parent(), "modulate:a", 1.0, 0.0, 1.0)
	tween.start()
	
	yield(get_tree().create_timer(1.5), "timeout")
	
	fade.modulate.a = 0.0
	fade.show()
	tween.interpolate_property(fade, "modulate:a", 0.0, 1.0, 1.5)
	tween.start()
	
	yield(get_tree().create_timer(2.0), "timeout")
	
	get_tree().change_scene(scenePath)

func shake(node, strength: float = 8.0, times: int = 8, stopshake: bool = false):
	if stopshake: node.remove_meta("shaking")
	if node.has_meta("shaking"): return
	
	node.set_meta("shaking", true)
	var origin
	if node == canvas_layer:
		origin = node.offset
	else:
		origin = node.rect_position
	for i in times:
		if node == canvas_layer:
			node.offset = origin + Vector2(rand_range(-strength, strength), rand_range(-strength, strength))
		else:
			node.rect_position = origin + Vector2(rand_range(-strength, strength), rand_range(-strength, strength))
		yield(get_tree().create_timer(0.03), "timeout")
	if node == canvas_layer:
		node.offset = origin
	else:
		node.rect_position = origin
	node.remove_meta("shaking")








func is_scared() -> bool:
	return Global.health <= currentLandlord["health"] / 2.0

func get_danger_zone() -> String:
	if !is_scared(): return ""
	
	var zones = {"head": Global.headColony, "body": Global.bodyColony, "legs": Global.legsColony}
	var best = ""
	var best_value = 0
	for i in zones:
		if zones[i] > best_value:
			best = i
			best_value = zones[i]
	return best

func pick_activity() -> String:
	var pool: Array = []
	var weights: Dictionary = currentLandlord["activities"]
	for name in weights:
		for i in weights[name]:
			pool.append(name)
	return pool.pick_random()

func make_thought(name: String, zone: String) -> Dictionary:
	var activity: Dictionary = Global.activities[name]
	var danger: Dictionary = activity.get("danger", {})
	if danger.has(zone):
		return {"text": danger[zone]["texts"].pick_random(), "effect": danger[zone]["effect"], "zone": zone}
	return {"text": activity["default_text"].pick_random(), "effect": activity["effect"], "zone": activity.get("zone", "biggest")}

func plan_thought():
	thought = make_thought(pick_activity(), get_danger_zone())
	
	if is_scared(): shake(thought_control, 2.0, 36.0)
	tween.interpolate_property(thought_label, "modulate:a", 1.0, 0.0, 0.3)
	tween.interpolate_property(thought_texturerect, "modulate:a", 1.0, 0.5, 0.3)
	tween.start()
	yield(get_tree().create_timer(0.4), "timeout")
	
	thought_label.text = tr(thought["text"]) + "\n" + describe_effect(thought["effect"], thought["zone"])
	
	tween.interpolate_property(thought_label, "modulate:a", 0.0, 1.0, 0.2)
	tween.interpolate_property(thought_texturerect, "modulate:a", 0.5, 1.0, 0.2)
	tween.start()

func apply_thought():
	var effect: Dictionary = thought["effect"]
	Global.health += scaled(effect.get("health", 0), currentLandlord["health"])
	change_colony(scaled(effect.get("colony", 0), currentLandlord["need"]), thought["zone"])

func biggest_zone() -> String:
	var zones = {"head": Global.headColony, "body": Global.bodyColony, "legs": Global.legsColony}
	var best = "head"
	for z in zones:
		if zones[z] > zones[best]:
			best = z
	return best

func change_colony(amount: int, zone: String):
	if amount == 0: return
	if not zone in ["head", "body", "legs", "biggest"]:
		zone = "biggest"
	if zone == "biggest": zone = biggest_zone()
	if amount > 0 and Global.get(zone + "Colony") <= 0:
		zone = biggest_zone()
	var key = zone + "Colony"
	Global.set(key, max(0, Global.get(key) + amount))

func zone_label(zone: String):
	match zone:
		"head": return tr("Голова")
		"body": return tr("Тело")
		"legs": return tr("Ноги")
	
	### если не указана зона (голова, тело или ноги)
	return zone_label(biggest_zone())

func describe_effect(effect: Dictionary, zone: String) -> String:
	var parts: Array = []
	var health: int = scaled(effect.get("health", 0), currentLandlord["health"])
	var colony: int = scaled(effect.get("colony", 0), currentLandlord["need"])
	if health != 0:
		parts.append(tr("Здоровье") + " %+d%%" % health)
	if colony != 0:
		parts.append(tr("Колония") + " %+d (%s)" % [colony, zone_label(zone)])
	if parts.empty():
		return "[" + tr("Без эффекта") + "]"
	return "[" + PoolStringArray(parts).join(", ") + "]"

func build_landlord(base: Dictionary) -> Dictionary:
	var l: Dictionary = base.duplicate(true)
	if !l.has("need_mod"): return l
	var depth: int = Global.currentLandlordIndex
	var colony: int = Global.headColony+Global.bodyColony+Global.legsColony
	
	var need: int = int(round(((9 + 4 * depth) + Global.nColony) * l["need_mod"]))
	l["need"] = need
	l["health"] = int(round(need * 1.1 * l.get("health_mod", 1.0)))
	
	return l

func scaled(value: int, base: int) -> int:
	if value == 0: return 0
	
	var v: int = int(round(value * base / 60.0))
	if v == 0: v = int(sign(value))
	
	return v
