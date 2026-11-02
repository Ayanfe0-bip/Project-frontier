extends Node3D

@export var open_angle_degrees: float = 90.0
@export var door_speed: float = 4.0

@onready var pivot: Node3D = $DoorPivot

var player_ref: Node = null
var is_open: bool = false

func _process(delta: float) -> void:
	var target_rotation := 0.0
	if is_open:
		target_rotation = deg_to_rad(open_angle_degrees)
	pivot.rotation.y = lerp_angle(pivot.rotation.y, target_rotation, min(1.0, door_speed * delta))

func interact(_source: Node) -> void:
	is_open = not is_open

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body == null or body.name != "Player":
		return
	player_ref = body
	if player_ref.has_method("register_interactable"):
		player_ref.register_interactable(self)

func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body == null or body.name != "Player":
		return
	player_ref = body
	if player_ref.has_method("unregister_interactable"):
		player_ref.unregister_interactable(self)
