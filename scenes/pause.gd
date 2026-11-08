extends Control


func _input(event):
	if event is InputEvent:
		if event.is_action_pressed("PAUSE"):
			visible = not visible
		
		get_tree().paused = visible
