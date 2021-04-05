extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player._on_dialog_ended("close_dialog", "event")


func process_dialogic_event(event):
	print("event: ", event)
