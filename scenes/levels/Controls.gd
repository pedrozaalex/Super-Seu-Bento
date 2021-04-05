extends Sprite


func _ready():
	$Press.visible = false


func start_timer():
	$Timer.start()


func hide_button():
	$TextureButton.hide()


func _on_Button_pressed():
	get_tree().change_scene("res://scenes/levels/Menu.tscn")
	pass # Replace with function body.


func _on_Timer_timeout():
	$Press.visible = !$Press.visible
