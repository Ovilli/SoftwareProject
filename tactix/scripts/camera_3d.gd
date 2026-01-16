extends Camera3D

@export var sensitivity: float = 0.003
@onready var PERFECT_OUTLINE_SHADER = preload("uid://5xmiss1l4sy7")

var yaw: float = 0.0
var pitch: float = 0.0

func _ready():
	# Lock mouse for FPS-style rotation
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		shoot_ray()

# this is ai ai ai ai ai ai 
# this not
# https://www.youtube.com/watch?v=mJRDyXsxT9g
# shader #https://godotshaders.com/shader/clean-pixel-perfect-outline-via-material-3/

func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000.0
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	#34343
	var raycast_result = space.intersect_ray(ray_query)
	
			
	if raycast_result:
		var hit_object = raycast_result["collider"]
		#if hit_object:
			#if hit_object.name == "Dice_Black":
