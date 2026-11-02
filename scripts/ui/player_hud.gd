extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HUD/HealthBar
@onready var stamina_bar: ProgressBar = $MarginContainer/HUD/StaminaBar
@onready var status_label: Label = $MarginContainer/HUD/StatusLabel

var player_ref: Node

func _ready() -> void:
	_bind_player()
	_update_status_label()

func _process(_delta: float) -> void:
	if player_ref == null:
		_bind_player()
		return

	if player_ref.has_method("get_health_ratio"):
		health_bar.value = player_ref.get_health_ratio() * 100.0
	if player_ref.has_method("get_stamina_ratio"):
		stamina_bar.value = player_ref.get_stamina_ratio() * 100.0
	_update_status_label()

func _bind_player() -> void:
	var root := get_tree().current_scene
	if root == null:
		return
	player_ref = root.get_node_or_null("Player")

func _update_status_label() -> void:
	if player_ref == null:
		status_label.text = "Awaiting player"
		return
	if player_ref.has_method("get_player_state"):
		status_label.text = player_ref.get_player_state()
		return
	var health_ratio := 1.0
	if player_ref.has_method("get_health_ratio"):
		health_ratio = player_ref.get_health_ratio()
	if health_ratio <= 0.25:
		status_label.text = "Critical"
	elif health_ratio <= 0.6:
		status_label.text = "Wounded"
	else:
		status_label.text = "Stable"
