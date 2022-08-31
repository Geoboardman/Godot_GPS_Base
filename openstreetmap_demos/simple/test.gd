extends Spatial

onready var camera = get_node("Camera")
onready var map = get_node("Map")
onready var player = get_node("Player")

var singleton
var quads = []
var texture_cache = {}
var reference_position = Vector2(0, 0)
var event_timestamp = 0

var glat = 47.6750793
var glon = -122.1140707

func _ready():
	if OS.get_name() == "Android":
		get_tree().connect("on_request_permission_result", self, "result")
		if(OS.request_permissions()):
			result("", true)
	teleport(glat, glon)

func result(permission, granted):
	print("connect gps signals")
	if granted:
		print("granted")
		if Engine.has_singleton("LocationPlugin"):
			print("engine has location plug")
			singleton = Engine.get_singleton("LocationPlugin")
			singleton.connect("onLocationUpdates", self, "gotLocationUpdate")
			singleton.connect("onLastKnownLocation", self, "gotLastKnown")
			singleton.connect("onLocationError", self, "gotLocationError")
			singleton.startLocationUpdates(6000, 10000)

func _on_Ground_input_event(_c, event, click_pos, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				event_timestamp = OS.get_ticks_msec()
			elif OS.get_ticks_msec()-event_timestamp < 200:
				if event.doubleclick:
					pass
				elif camera != null:
					player.set_target_pos_mouse(click_pos)
					#camera.set_target_pos(click_pos)
					#map.set_center(Vector2(click_pos.x, click_pos.z))

func teleport(lat : float, lon : float):
	if map != null:
		var default_pos = osm.pos2tile(lon, lat)
		map.reference_position = Vector2(default_pos.x, default_pos.y)
		map.set_center(Vector2(0, 0))

func updateLocationText(latitude, longitude):
	var lat = str(latitude)
	var lon = str(longitude)
	var newPos = osm.pos2tile(longitude, latitude)
	newPos -= map.reference_position
	newPos *= osm.TILE_SIZE
	$UserInterface2/LatLabel.text = "Latitude %s" % lat
	$UserInterface2/LonLabel.text = "Longitude %s" % lon
	$UserInterface2/PlayerX.text = "PlayerX %s" % str(newPos.x)
	$UserInterface2/PlayerZ.text = "PlayerX %s" % str(newPos.y)

func gotLocationUpdate(locData):
	updateLocationText(locData.latitude, locData.longitude)
	if map != null:	
		teleport(locData.latitude, locData.longitude)
		player.set_target_pos(locData, map.reference_position)
	
func gotLastKnown(locData):
	updateLocationText(locData.latitude, locData.longitude)
	teleport(locData.latitude, locData.longitude)

func _on_GPSAndroid_locationUpdate(locData):
	gotLocationUpdate(locData)
	print("location updating")


func _on_GPSAndroid_lastKnownLocation(locData):
	gotLastKnown(locData)
	print("got last known")
