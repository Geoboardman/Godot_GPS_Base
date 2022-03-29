extends Spatial

onready var camera = get_node("Camera")
onready var map = get_node("Map")
var gps_singleton

var quads = []
var texture_cache = {}
var reference_position = Vector2(0, 0)
var x = null
var y = null
var event_timestamp = 0
var gps_loaded = false
var lat = 47.6750793
var lon = -122.1140707

func _ready():
	if OS.get_name() == "android":
		setup_gps()
	else:
		teleport(lat, lon)

func setup_gps():
	if OS.get_name() == "android":
		if get_tree().connect("on_request_permission_result", self, "result") != OK:
			print("Error connecting to on_request_permission_result")
		if(OS.request_permissions()):
			connect_gps_signals("", true)

func _on_Ground_input_event(_c, event, click_pos, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				event_timestamp = OS.get_ticks_msec()
			elif OS.get_ticks_msec()-event_timestamp < 200:
				if event.doubleclick:
					pass
				elif camera != null:
					camera.set_target_pos(click_pos)
					map.set_center(Vector2(click_pos.x, click_pos.z))

func teleport(lat : float, lon : float):
	if map != null:
		var default_pos = osm.pos2tile(lon, lat)
		map.reference_position = Vector2(default_pos.x, default_pos.y)
		map.set_center(Vector2(0, 0))
		gps_loaded = true

func connect_gps_signals(_permission, granted):
	if granted:
		if Engine.has_singleton("LocationPlugin"):
			gps_singleton = Engine.get_singleton("LocationPlugin")
			gps_singleton.connect("onLocationUpdates", self, "gotLocationUpdate")
			gps_singleton.connect("onLastKnownLocation", self, "gotLastKnown")
			gps_singleton.connect("onLocationError", self, "gotLocationError")
			gps_singleton.startLocationUpdates(6000, 10000)

func gotLocationUpdate(locData):
	teleport(locData.latitude, locData.longitude)
	
func gotLastKnown(locData):
		teleport(locData.latitude, locData.longitude)
	
func gotLocationError(error, message):
	print("Error getting location %s %s", error, message)
	pass
