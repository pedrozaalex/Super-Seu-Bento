extends Node2D


var has_started = false

func _ready():
	get_tree().paused = true
	$CanvasLayer/Controls.show()
	$CanvasLayer/BlackRect.show()
	$CanvasLayer/Controls.hide_button()
	$CanvasLayer/Controls.start_timer()
	$Tween.interpolate_property($CanvasLayer/BlackRect, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$YSort/Player._on_dialog_started()
	
	$BackgroundMusic.play()
	$SceneTransition.interpolate_property($CanvasLayer/SceneTransitionScreen, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$SceneTransition.interpolate_property($BackgroundMusic, "volume_db", 0, -30, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$SceneTransition.interpolate_property($TransitionMusic, "volume_db", -30, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)

func _process(_delta):
	if !has_started:
		if Input.is_action_just_released("ui_select"):
			get_tree().paused = false
			$CanvasLayer/Controls.hide()
			$Tween.start()
			has_started = true


func _on_Tween_tween_all_completed():
	var new_dialog = Dialogic.start("StomachGrowl")
	$YSort/Player._on_dialog_started()
	new_dialog.connect("event_start", $YSort/Player, "_on_dialog_ended")
	get_tree().current_scene.get_node("CanvasLayer").add_child(new_dialog)

func process_dialogic_event(event):
	if event == "ice_cream_start":
		$CanvasLayer/SceneTransitionScreen.show()
		$SceneTransition.start()
		$TransitionMusic.play()


func _on_SceneTransition_tween_all_completed():
	pass


func _on_TransitionMusic_finished():
	$TransitionTimer.start()

func _on_TransitionTimer_timeout():
	get_tree().change_scene("res://scenes/levels/IceCreamShop.tscn")
