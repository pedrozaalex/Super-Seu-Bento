extends Sprite


func _on_Timer_timeout():
	$Press.visible = !$Press.visible
