extends Camera

export var distance = 4.0
export var height = 2.0

func _ready():
	pass

func _physics_process(_delta):
	var player = get_node("../Player")
	if player != null:
		var pos = get_global_transform().origin
		var up = Vector3.UP
		var target = player.get_global_transform().origin
		var offset = pos - target
		offset = offset.normalized() * distance
		offset.y = height
		
		pos = target + offset
		look_at_from_position(pos, target, up)
