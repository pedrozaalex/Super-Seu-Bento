extends KinematicBody2D

class_name Player


export(int) var WALK_SPEED = 350 # pixels per second
export(int) var ROLL_SPEED = 1000 # pixels per second
export(int) var hitpoints = 3

var linear_vel = Vector2()
var roll_direction = Vector2.DOWN

export(String, "up", "down", "left", "right") var facing = "down"

var despawn_fx = preload("res://scenes/misc/DespawnFX.tscn")

var anim = ""
var new_anim = ""

enum { STATE_BLOCKED, STATE_IDLE, STATE_WALKING }

var state = STATE_BLOCKED

var interact_area

# Move the player to the corresponding spawnpoint, if any and connect to the dialog system
func _ready():
	var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	for spawnpoint in spawnpoints:
		if spawnpoint.name == Globals.spawnpoint:
			global_position = spawnpoint.global_position
			break
	if not (
			Dialogs.connect("dialog_started", self, "_on_dialog_started") == OK and
			Dialogs.connect("dialog_ended", self, "_on_dialog_ended") == OK ):
		printerr("Error connecting to dialog system")
	pass


func _physics_process(_delta):
	## PROCESS STATES
	
	match state:
		STATE_BLOCKED:
			new_anim = "idle_" + facing
			pass
		STATE_IDLE:
			if $WalkSound.playing:
				$WalkSound.stop()
			if (
					Input.is_action_pressed("move_down") or
					Input.is_action_pressed("move_left") or
					Input.is_action_pressed("move_right") or
					Input.is_action_pressed("move_up")
				):
					state = STATE_WALKING
			_update_facing()
			new_anim = "idle_" + facing
			
			if Input.is_action_just_released("interact") and interact_area:
				var new_dialog = Dialogic.start(interact_area.timeline)
				get_tree().current_scene.get_node("CanvasLayer").add_child(new_dialog)
				_on_dialog_started()
				new_dialog.connect("event_start", self, "_on_dialog_ended", [])
				new_dialog.connect("dialogic_signal", get_tree().current_scene, "process_dialogic_event")
			pass
		STATE_WALKING:
			if !$WalkSound.playing:
				$WalkSound.play()
			
			linear_vel = move_and_slide(linear_vel)
			
			var target_speed = Vector2()
			
			if Input.is_action_pressed("move_down"):
				target_speed += Vector2.DOWN
			if Input.is_action_pressed("move_left"):
				target_speed += Vector2.LEFT
			if Input.is_action_pressed("move_right"):
				target_speed += Vector2.RIGHT
			if Input.is_action_pressed("move_up"):
				target_speed += Vector2.UP
			if Input.is_action_just_released("interact") and interact_area:
				var new_dialog = Dialogic.start(interact_area.timeline)
				get_tree().current_scene.get_node("CanvasLayer").add_child(new_dialog)
				_on_dialog_started()
				new_dialog.connect("event_start", self, "_on_dialog_ended", [])
			
			target_speed *= WALK_SPEED
			#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
			linear_vel = target_speed
			roll_direction = linear_vel.normalized()
			
			_update_facing()
			
			if linear_vel.length() > 5:
				new_anim = "walk_" + facing
				if linear_vel.x < 0 && linear_vel.y > 0:
					new_anim = "walk_down_right"
			else:
				goto_idle()
			pass
	
	## UPDATE ANIMATION
	if new_anim != anim:
		anim = new_anim
		if anim == "walk_down_right":
			$AnimatedSprite.play("walk_down")
			$AnimatedSprite.flip_h = true
			return
		$AnimatedSprite.play(anim)
		$AnimatedSprite.flip_h = false
	return


func _on_dialog_started():
	state = STATE_BLOCKED


func _on_dialog_ended(event_type, _event):
	print("event_type: ", event_type)
	print("event_type: ", _event)
	if event_type == "close_dialog":
		state = STATE_IDLE


## HELPER FUNCS
func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + facing
	state = STATE_IDLE


func _update_facing():
	if Input.is_action_pressed("move_left"):
		facing = "left"
	if Input.is_action_pressed("move_right"):
		facing = "right"
	if Input.is_action_pressed("move_up"):
		facing = "up"
	if Input.is_action_pressed("move_down"):
		facing = "down"


func despawn():
	var despawn_particles = despawn_fx.instance()
	get_parent().add_child(despawn_particles)
	despawn_particles.global_position = global_position
	hide()
	yield(get_tree().create_timer(5.0), "timeout")
	get_tree().reload_current_scene()
	pass


func _on_InteractingArea_area_entered(area):
	interact_area = area


func _on_InteractingArea_area_exited(area):
	interact_area = area


func _on_player_correct_choice():
	print("Player made a correct choice")
