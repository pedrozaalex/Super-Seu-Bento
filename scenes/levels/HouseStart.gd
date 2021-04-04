extends Node2D


func _process(_delta):
	print(Dialogic.get_definitions()["variables"])
