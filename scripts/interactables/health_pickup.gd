extends Node3D

@export var heal_amount: float = 25.0

@onready var visual: MeshInstance3D = $PickupVisual

var player_ref: Node = null
var active: bool = true

func _ready() -> void:
	player_ref = get_tree().current_scene.get_node_or_null("Player")
	if player_ref != null and player_ref.has_method("register_interactable"):
		player_ref.register_interactable(self)

func interact(_source: Node) -> void:
	if not active:
		return
	if player_ref == null:
		player_ref = get_tree().current_scene.get_node_or_null("Player")
	if player_ref != null and player_ref.has_method("heal"):
		player_ref.heal(heal_amount)
	active = false
	visual.visible = false
	if player_ref != null and player_ref.has_method("unregister_interactable"):
		player_ref.unregister_interactable(self)

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
