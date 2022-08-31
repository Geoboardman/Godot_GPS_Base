extends KinematicBody

export(float) var run_speed = 10.0

var moving = true
var motion = Vector3(0, 0, 0)
var previous_position = Vector3(0, 0, 0)
var target_pos = Vector3(0,0,0)

func _ready():
	pass

func _physics_process(delta):
	motion.y += -9.8*delta
	move_and_slide(motion, Vector3(0, 1, 0))
	var direction = Vector2(0, 0)
	direction.y += run_speed*Input.get_joy_axis(0, 0)
	direction.x -= run_speed*Input.get_joy_axis(0, 1)
	if Input.is_action_pressed("ui_up"):
		direction.x += run_speed
	if Input.is_action_pressed("ui_down"):
		direction.x -= run_speed
	if Input.is_action_pressed("ui_left"):
		direction.y -= run_speed
	if Input.is_action_pressed("ui_right"):
		direction.y += run_speed
	if direction.length() > run_speed:
		direction /= direction.length()
		direction *= run_speed
	var camera = get_node("../Camera")
	if camera != null:
		direction = direction.rotated(-0.5*PI - camera.rotation.y)
	var h_motion_influence = delta
	if is_on_floor():
		h_motion_influence *= 10
		motion.y = 0
	var h_motion = Vector2(motion.x, motion.z)
	h_motion.x = lerp(h_motion.x, direction.x, h_motion_influence)
	h_motion.y = lerp(h_motion.y, direction.y, h_motion_influence)
	if (previous_position-translation).length()/delta > 1:
		$Model.anim("Run")
		rotation.y = 0.5*PI - h_motion.angle()
	else:
		$Model.anim("Idle")
	previous_position = translation
	motion.x = h_motion.x
	motion.z = h_motion.y

func move_target(delta):
	#if moving and OS.get_name() == "Android":
		var t = get_translation()
		t += 150*delta*(target_pos-t).normalized()
		set_translation(t)
		if (target_pos-t).length() < 1:
			moving = false

func teleport(_lat, _lon):
	translation = Vector3(0, 0, 0)
	motion = Vector3(0, 0, 0)
	previous_position = Vector3(0, 0, 0)

func set_target_pos(locData, map_reference_pos):
	var newPos = osm.pos2tile(locData.longitude, locData.latitude)
	newPos -= map_reference_pos	
	target_pos = Vector3(newPos.x, 0, newPos.y)
	translation = target_pos
	moving = true
	
func set_target_pos_mouse(click_pos):
	print("Moving to "+str(Vector2(click_pos.x, click_pos.y)))
	target_pos = Vector3(click_pos.x, 0, click_pos.z)
	moving = true
