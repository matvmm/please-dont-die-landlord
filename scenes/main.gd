# main.gd
extends Node2D

onready var endturn_button = $CanvasLayer/bottom/hbox/endturn_button
onready var cards = $CanvasLayer/bottom/hbox/cards
onready var healthbar_label = $CanvasLayer/top/hbox/healthbar/Label
onready var healthbar = $CanvasLayer/top/hbox/healthbar
onready var turnlabel = $CanvasLayer/top/hbox/labels/turnlabel
onready var colonylabel = $CanvasLayer/top/hbox/labels/colonylabel
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
onready var thought_texturerect = $CanvasLayer/thought/TextureRect
onready var thought_label = $CanvasLayer/thought/Label
onready var cpu_particles_2d_healthbar = $CanvasLayer/top/hbox/healthbar/CPUParticles2D
onready var shading = $CanvasLayer/shading
onready var thought_control = $CanvasLayer/thought

var endturn_already_pressed: bool = false
var currentLandlord: Dictionary
var thought: Dictionary
var round_over: bool = false
var mScreenMotion: Dictionary = {
	"top": Vector2.ZERO,
	"right": Vector2.ZERO,
	"bottom": Vector2.ZERO,
	"thought": Vector2.ZERO,
	"landlord": Vector2.ZERO
}


func _init():
	randomize()

func _ready():
	right.hide()
	fade.modulate.a = 1.0
	fade.show()
	currentLandlord = Global.landlords[Global.currentLandlordIndex]
	landlord_texturerect.texture = load(currentLandlord["texture"])
	healthbar.max_value = currentLandlord["health"]
	Global.health = currentLandlord["health"]
	
	mScreenMotion["bottom"] = bottom.rect_position
	mScreenMotion["top"] = top.rect_position
	mScreenMotion["right"] = right.rect_position
	mScreenMotion["thought"] = thought_control.rect_position
	mScreenMotion["landlord"] = landlord_texturerect.rect_position
	
	if Global.currentLandlordIndex < 3: Global.play_audio("res://music/default_music_1.mp3")
	else:                               Global.play_audio("res://music/default_music_2.mp3")
	
#	match Global.currentLandlordIndex:
#		0,1,2: Global.maxCards = 5
#		3,4  : Global.maxCards = 7
#	Global.maxCards = 2 + Global.currentLandlordIndex * 1.5
#	Global.maxCards = Global.currentLandlordIndex % 3 + 2
	Global.maxCards = 4 + 2 * int(Global.currentLandlordIndex / 3)
	
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

func _run_default_animation():
	defaultanimation.repeat = true
	defaultanimation.interpolate_property(landlord_texturerect, "rect_scale:x", 1.0, -1.0, 0.8, Tween.TRANS_BACK, Tween.EASE_OUT, 7.5)
	defaultanimation.interpolate_property(landlord_texturerect, "rect_scale:x", -1.0, 1.0, 0.8, Tween.TRANS_BACK, Tween.EASE_OUT, 15.0)
	defaultanimation.start()

func _process(delta):
	var m: Vector2 = get_global_mouse_position()
	var mSM: Dictionary = mScreenMotion
	var s1: float = 0.02
	var s2: float = 0.01
	
	bottom.rect_position = lerp(bottom.rect_position, mSM["bottom"] + m * s2, 15 * delta)
	top.rect_position = lerp(top.rect_position, mSM["top"] + m * s2, 15 * delta)
	right.rect_position = lerp(right.rect_position, mSM["right"] + m * s2, 15 * delta)
	
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
	
	var gain := 0
	for card in played:
		randomize()
#		gain += 1 + randi() % 3 if card.currentDefaultCard["bestPlace"] == attack else 1
		if card.currentDefaultCard["bestPlace"] == attack:
			match attack:
				1: gain += 6 + randi() % 4
				2: gain += 4 + randi() % 2
				3: gain += 1 + randi() % 1
		else:
			match attack:
				1: gain -= 2 + randi() % 3
				2: gain -= 1 + randi() % 2
				3: gain -= 0 + randi() % 1
		card.apply_animation()
	yield(get_tree().create_timer(0.6), "timeout")
	
	Global.turns += 1
	
	randomize()
	if Global.headColony > 0: Global.headColony += (1 + randi() % 2) * int(Global.headColony / 16)
	if Global.bodyColony > 0: Global.bodyColony += (1 + randi() % 2) * int(Global.bodyColony / 10)
	if Global.legsColony > 0: Global.legsColony += (randi() % 3) * int(Global.legsColony / 16)
	
	match attack:
		1: Global.headColony += gain
		2: Global.bodyColony += gain
		3: Global.legsColony += gain
	
	Global.health -= int(Global.headColony / 2)
	Global.health -= int(Global.bodyColony / 3)
	Global.health -= 1
	Global.health = max(Global.health, 0)
	
	apply_thought()
	plan_thought()
	
	shake(landlord_texturerect, 2.0, 16)
	
	tween.interpolate_property(bg, "modulate:a", bg.modulate.a, clamp(0.2 - Global.health * 0.002, 0.0, 0.2), 5.0)
	tween.start()
	
#	tween.interpolate_property(top, "rect_scale", Vector2.ONE*1.05, Vector2.ONE, 0.6, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
#	tween.start()
	shake(top, 4.0, 8.0)
	update_label()
	if round_over: return
	
	yield(get_tree().create_timer(0.6), "timeout")
	give_cards(Global.maxCards)
	yield(get_tree().create_timer(0.2), "timeout")
	
	tween.interpolate_property(bottom, "modulate:a", bottom.modulate.a, 1.0, 0.2)
	tween.start()
	
	endturn_already_pressed = false

func give_cards(amount: int):
	while cards.get_child_count() < amount:
		yield(get_tree().create_timer(0.1), "timeout")
		cards.add_child(load("res://scenes/cards/card1.tscn").instance())

func update_label():
	var colony: int = Global.headColony+Global.bodyColony+Global.legsColony
	turnlabel.text = tr("Ход") + ": " + str(Global.turns)
	colonylabel.text = tr("Колония") + ": " + str(colony) + " / " + str(currentLandlord["need"])
	tween.interpolate_property(healthbar, "value", healthbar.value, Global.health, 0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
#	healthbar.value = Global.health
	healthbar_label.text = " " + tr("Здоровье") + ": " + str(Global.health) + "%"
	head_colony_label.text = tr("Голова") + ": " + str(Global.headColony) + " "
	body_colony_label.text = tr("Тело") + ": " + str(Global.bodyColony) + " "
	legs_colony_label.text = tr("Ноги") + ": " + str(Global.legsColony) + " "
	
	tween.interpolate_property(shading, "texture:fill_to", shading.texture.fill_to, Vector2(2.8, 0) if !is_scared() else Vector2(1.2, 0.0), 4.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
#	shading.texture.fill_to = Vector2(2.5, 0) if !is_scared() else Vector2(1.5, 0)
	
	if colony >= currentLandlord["need"]:
		if Global.landlords.size() <= Global.currentLandlordIndex+1:
			go_to_next_scene("res://scenes/win.tscn")
			return
		go_to_next_scene("res://scenes/roadmap.tscn")
		round_over = true
		return
	
	if Global.health <= 0:
		landlord_texturerect.texture = load("res://sprites/landlords/dead_1.png")
		yield(get_tree().create_timer(0.5), "timeout")
		fade.modulate.a = 0.0
		fade.show()
		tween.interpolate_property(fade, "modulate:a", 0.0, 1.0, 2.5)
		tween.start()
		yield(get_tree().create_timer(2.5), "timeout")
		get_tree().change_scene("res://scenes/gameover.tscn")
		
		round_over = true
		return
	if is_scared():
		landlord_texturerect.texture = load(currentLandlord["lowhealth_texture"])
		shake(landlord_texturerect, 1.0, 9999999)
		cpu_particles_2d_healthbar.emitting = true
	else:
		landlord_texturerect.texture = load(currentLandlord["texture"])
		shake(landlord_texturerect, 0.0, 0, true)
		cpu_particles_2d_healthbar.emitting = false

func go_to_next_scene(scenePath: String):
	if scenePath == "": return
	
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	tween.interpolate_property(bottom, "modulate:a", 1.0, 0.0, 1.0)
	tween.interpolate_property(right, "modulate:a", 1.0, 0.0, 1.0)
	tween.interpolate_property(top, "modulate:a", 1.0, 0.0, 1.0)
	tween.interpolate_property(thought_label.get_parent(), "modulate:a", 1.0, 0.0, 1.0)
	tween.start()
	
	yield(get_tree().create_timer(1.5), "timeout")
	
	fade.modulate.a = 0.0
	fade.show()
	tween.interpolate_property(fade, "modulate:a", 0.0, 1.0, 1.5)
	tween.start()
	
	yield(get_tree().create_timer(2.0), "timeout")
	
	get_tree().change_scene(scenePath)

func shake(node: Control, strength: float = 8.0, times: int = 8, stopshake: bool = false):
	if stopshake: node.remove_meta("shaking")
	if node.has_meta("shaking"): return
	
	node.set_meta("shaking", true)
	var origin = node.rect_position
	for i in times:
		node.rect_position = origin + Vector2(rand_range(-strength, strength), rand_range(-strength, strength))
		yield(get_tree().create_timer(0.03), "timeout")
	node.rect_position = origin
	node.remove_meta("shaking")








func is_scared():
	return Global.health <= currentLandlord["health"] / 2.0

func get_danger_zone():
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
		return {"text": danger[zone]["texts"].pick_random(), "effect": danger[zone]["effect"]}
	return {"text": activity["default_text"].pick_random(), "effect": activity["effect"]}

func plan_thought():
	thought = make_thought(pick_activity(), get_danger_zone())
	thought_label.text = thought["text"]
	thought_label.text = thought["text"] + "\n" + describe_effect(thought["effect"])

func apply_thought():
	var effect: Dictionary = thought["effect"]
	Global.health += effect.get("health", 0)
	change_colony(effect.get("colony", 0))

func change_colony(amount: int):
	var step = 1 if amount > 0 else -1
	for i in abs(amount):
		var options: Array = []
		for zone in ["headColony", "bodyColony", "legsColony"]:
			if step > 0 or Global.get(zone) > 0:
				options.append(zone)
		if options.empty(): return
		var chosen = options.pick_random()
		Global.set(chosen, Global.get(chosen) + step)

func describe_effect(effect: Dictionary) -> String:
	var parts: Array = []
	var health: int = effect.get("health", 0)
	var colony: int = effect.get("colony", 0)
	if health != 0:
		parts.append("Здоровье %+d%%" % health)
	if colony != 0:
		parts.append("Колония %+d" % colony)
	if parts.empty():
		return "[Без эффекта]"
	return "[" + PoolStringArray(parts).join(", ") + "]"
