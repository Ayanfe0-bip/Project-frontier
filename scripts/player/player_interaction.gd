extends Node3D

var interactables: Array[Node] = []
var interaction_radius: float = 2.5
var current_target: Node = null

func _process(_delta: float) -> void:
	if interactables.is_empty():
		current_target = null
		return

	var nearest: Node = null
	var nearest_distance: float = INF
	for interactable in interactables:
		if interactable == null or not is_instance_valid(interactable):
			continue
		if not interactable.has_method("interact"):
			continue
		var distance := global_position.distance_to(interactable.global_position)
		if distance <= interaction_radius and distance < nearest_distance:
			nearest = interactable
			nearest_distance = distance

	current_target = nearest

func set_interaction_radius(radius: float) -> void:
	interaction_radius = max(0.5, radius)

func register_interactable(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if not interactables.has(node):
		interactables.append(node)

func unregister_interactable(node: Node) -> void:
	if node == null:
		return
	interactables.erase(node)
	if current_target == node:
		current_target = null

func try_interact() -> bool:
	if current_target == null:
		var nearest_target := _find_nearest_interactable()
		if nearest_target == null:
			return false
		current_target = nearest_target

	if current_target == null:
		return false
	if current_target.has_method("interact"):
		current_target.interact(self)
		return true
	return false

func _find_nearest_interactable() -> Node:
	var nearest: Node = null
	var nearest_distance: float = INF
	for interactable in interactables:
		if interactable == null or not is_instance_valid(interactable):
			continue
		if not interactable.has_method("interact"):
			continue
		var distance := global_position.distance_to(interactable.global_position)
		if distance <= interaction_radius and distance < nearest_distance:
			nearest = interactable
			nearest_distance = distance
	return nearest

func get_current_target() -> Node:
	return current_target
