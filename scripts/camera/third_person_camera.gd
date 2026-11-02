extends Node3D

@export var target_path: NodePath = NodePath()
@export var follow_distance: float = 5.0
@export var camera_height: float = 2.2
@export var mouse_sensitivity: Vector2 = Vector2(0.003, 0.003)
@export var smoothing: float = 8.0
@export var min_pitch: float = -60.0
@export var max_pitch: float = 55.0
@export var collision_push: float = 0.15

@onready var camera: Camera3D = $Camera3D
@onready var wall_check: RayCast3D = $WallCheck

var target: Node3D
var current_yaw: float = 0.0
var current_pitch: float = -0.15
var look_active: bool = false


func _ready() -> void:
	if target_path != NodePath():
		target = get_node(target_path)
	else:
		var parent_player := get_parent().get_node_or_null("Player")
		if parent_player is Node3D:
			target = parent_player

	if target == null:
		push_warning("ThirdPersonCamera target not found. Camera will remain in place until a valid target is assigned.")
		return

	camera.current = true
	_input_ready()


func _input_ready() -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			if mouse_event.pressed:
				look_active = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				look_active = false
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_viewport().set_input_as_handled()

	if event is InputEventMouseMotion and look_active:
		var mouse_movement := event as InputEventMouseMotion
		current_yaw -= mouse_movement.relative.x * mouse_sensitivity.x
		current_pitch -= mouse_movement.relative.y * mouse_sensitivity.y
		current_pitch = clamp(current_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if target == null:
		return

	var target_origin := target.global_position + Vector3(0.0, camera_height, 0.0)
	var desired_offset := Vector3(
		sin(current_yaw) * follow_distance,
		camera_height + sin(current_pitch) * follow_distance,
		cos(current_yaw) * follow_distance
	)
	var desired_position := target_origin + desired_offset

	var from_target := desired_position - target_origin
	wall_check.global_position = target_origin
	wall_check.target_position = to_local(desired_position)
	wall_check.force_raycast_update()

	if wall_check.is_colliding():
		var hit_point := wall_check.get_collision_point()
		var hit_normal := wall_check.get_collision_normal()
		desired_position = hit_point + hit_normal * collision_push
	
	var blend_factor := 1.0 - exp(-delta * smoothing)
	global_position = global_position.lerp(desired_position, blend_factor)
	look_at(target_origin, Vector3.UP)
	camera.global_transform = global_transform


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
