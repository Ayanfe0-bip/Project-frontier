extends CanvasLayer

@onready var weapon_name_label: Label = $MarginContainer/HUD/WeaponName
@onready var ammo_label: Label = $MarginContainer/HUD/AmmoText
@onready var reload_label: Label = $MarginContainer/HUD/ReloadText
@onready var crosshair: Control = $Crosshair

var player_ref: Node = null
var combat_ref: Node = null

func _ready() -> void:
	_bind_player()
	_update_hud()

func _process(_delta: float) -> void:
	if player_ref == null:
		_bind_player()
		return
	if combat_ref == null:
		combat_ref = player_ref.get_node_or_null("CombatRig")
	_update_hud()

func _bind_player() -> void:
	var root := get_tree().current_scene
	if root == null:
		return
	player_ref = root.get_node_or_null("Player")
	if player_ref != null:
		combat_ref = player_ref.get_node_or_null("CombatRig")

func _update_hud() -> void:
	if combat_ref == null:
		weapon_name_label.text = "No weapon"
		ammo_label.text = "0 / 0"
		reload_label.text = ""
		return
	var state := combat_ref.get_current_weapon_state()
	weapon_name_label.text = state["name"]
	ammo_label.text = "%d / %d" % [state["magazine"], state["reserve"]]
	if state["aiming"]:
		crosshair.modulate = Color(0.3, 1.0, 0.7, 1.0)
	else:
		crosshair.modulate = Color(1.0, 1.0, 1.0, 1.0)
	reload_label.text = ""
