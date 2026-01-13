extends Camera3D

@export var sensitivity: float = 0.003
@export var outline_material: ShaderMaterial
@export var max_distance: float = 1000.0

const PERFECT_OUTLINE_SHADER := preload("uid://5xmiss1l4sy7") # your shader

var yaw: float = 0.0
var pitch: float = 0.0
var current_target: MeshInstance3D = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if outline_material == null:
		outline_material = ShaderMaterial.new()
		outline_material.shader = PERFECT_OUTLINE_SHADER

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, -1.5, 1.5)
		rotation = Vector3(pitch, yaw, 0)

func _physics_process(_delta):
	update_hover_target()

func update_hover_target():
	var center := get_viewport().get_visible_rect().size * 0.5
	var space := get_world_3d().direct_space_state
	var from := project_ray_origin(center)
	var to := from + project_ray_normal(center) * max_distance

	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space.intersect_ray(query)

	if result:
		var mesh := extract_mesh(result.collider)
		if mesh:
			set_outline(mesh)
			return

	clear_outline()

func extract_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	if node.get_parent() is MeshInstance3D:
		return node.get_parent()
	return null

func set_outline(mesh: MeshInstance3D):
	if current_target == mesh:
		return

	clear_outline()

	current_target = mesh
	# Duplicate material so it is unique per piece
	current_target.material_overlay = outline_material.duplicate()

func clear_outline():
	if current_target:
		current_target.material_overlay = null
		current_target = null
