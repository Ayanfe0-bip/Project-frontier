extends CharacterBody3D

@export_group("Movement")
@export var walk_speed: float = 4.5
@export var sprint_speed: float = 7.0
@export var acceleration: float = 12.0
@export var deceleration: float = 14.0
@export var jump_velocity: float = 5.2

@export_group("Physics")
@export var gravity: float = 20.0
@export var interaction_radius: float = 2.5

@onready var player_stats: Node = $PlayerStats
@onready var interaction_component: Node3D = $PlayerInteraction

var move_input: Vector2 = Vector2.ZERO
var is_sprinting: bool = false
var mobile_move_input: Vector2 = Vector2.ZERO

func _ready() -> void:
	_configure_input_actions()
	if interaction_component != null and interaction_component.has_method("set_interaction_radius"):
		interaction_component.set_interaction_radius(interaction_radius)
	if player_stats != null and player_stats.has_method("_reset_state"):
		player_stats._reset_state()

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement(delta)
	_handle_interaction_input()
	move_and_slide()

func set_mobile_move_vector(vector: Vector2) -> void:
	mobile_move_input = vector

func set_mobile_sprint_active(active: bool) -> void:
	if active:
		Input.action_press("sprint")
	else:
		Input.action_release("sprint")

func set_mobile_jump_active(active: bool) -> void:
	if active:
		Input.action_press("jump")
	else:
		Input.action_release("jump")

func _configure_input_actions() -> void:
	var action_names: Array[String] = [
		"move_forward",
		"move_back",
		"move_left",
		"move_right",
		"sprint",
		"jump",
		"interact",
	]

	for action_name in action_names:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

	_add_key_if_missing("move_forward", KEY_W)
	_add_key_if_missing("move_forward", KEY_UP)
	_add_key_if_missing("move_back", KEY_S)
	_add_key_if_missing("move_back", KEY_DOWN)
	_add_key_if_missing("move_left", KEY_A)
	_add_key_if_missing("move_left", KEY_LEFT)
	_add_key_if_missing("move_right", KEY_D)
	_add_key_if_missing("move_right", KEY_RIGHT)
	_add_key_if_missing("sprint", KEY_SHIFT)
	_add_key_if_missing("jump", KEY_SPACE)
	_add_key_if_missing("interact", KEY_E)

func _add_key_if_missing(action_name: String, keycode: Key) -> void:
	for existing_event in InputMap.action_get_events(action_name):
		if existing_event is InputEventKey and existing_event.keycode == keycode:
			return

	var key_event := InputEventKey.new()
	key_event.keycode = keycode
	InputMap.action_add_event(action_name, key_event)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func _handle_movement(delta: float) -> void:
	var keyboard_move := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_back", "move_forward")
	)
	move_input = keyboard_move
	if mobile_move_input.length() > 0.05:
		move_input = mobile_move_input

	var stamina_consumed := false
	if Input.is_action_pressed("sprint") and move_input.length() > 0.1:
		if player_stats != null and player_stats.has_method("consume_stamina"):
			stamina_consumed = player_stats.consume_stamina(18.0 * delta)
		if not stamina_consumed:
			is_sprinting = false
		else:
			is_sprinting = true
	else:
		is_sprinting = false
		if player_stats != null and player_stats.has_method("recover_stamina"):
			player_stats.recover_stamina(20.0 * delta)

	var target_speed: float = sprint_speed if is_sprinting else walk_speed
	var direction := Vector3.ZERO
	if move_input.length() > 0.05:
		direction.x = move_input.x
		direction.z = move_input.y
		direction = direction.normalized()

		var desired_velocity := Vector3(direction.x * target_speed, velocity.y, direction.z * target_speed)
		var current_horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)

		if current_horizontal_velocity.length() > 0.01:
			current_horizontal_velocity = current_horizontal_velocity.lerp(
				desired_velocity,
				min(1.0, acceleration * delta)
			)
		else:
			current_horizontal_velocity = desired_velocity

		velocity.x = current_horizontal_velocity.x
		velocity.z = current_horizontal_velocity.z
		rotation.y = atan2(direction.x, direction.z)
	else:
		var current_horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
		var target_horizontal_velocity := Vector3.ZERO
		current_horizontal_velocity = current_horizontal_velocity.lerp(
			target_horizontal_velocity,
			min(1.0, deceleration * delta)
		)
		velocity.x = current_horizontal_velocity.x
		velocity.z = current_horizontal_velocity.z

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	if is_on_floor() and velocity.y < 0.0:
		velocity.y = -0.1

func _handle_interaction_input() -> void:
	if Input.is_action_just_pressed("interact"):
		if interaction_component != null and interaction_component.has_method("try_interact"):
			interaction_component.try_interact()

func take_damage(amount: float, source: String = "world") -> float:
	if player_stats != null and player_stats.has_method("take_damage"):
		return player_stats.take_damage(amount, source)
	return 0.0

func heal(amount: float) -> float:
	if player_stats != null and player_stats.has_method("heal"):
		return player_stats.heal(amount)
	return 0.0

func get_health_ratio() -> float:
	if player_stats != null and player_stats.has_method("get_health_ratio"):
		return player_stats.get_health_ratio()
	return 1.0

func get_stamina_ratio() -> float:
	if player_stats != null and player_stats.has_method("get_stamina_ratio"):
		return player_stats.get_stamina_ratio()
	return 1.0

func get_player_state() -> String:
	if get_health_ratio() <= 0.25:
		return "Critical"
	if get_health_ratio() <= 0.6:
		return "Wounded"
	return "Stable"

func try_interact() -> bool:
	if interaction_component != null and interaction_component.has_method("try_interact"):
		return interaction_component.try_interact()
	return false

func register_interactable(node: Node) -> void:
	if interaction_component != null and interaction_component.has_method("register_interactable"):
		interaction_component.register_interactable(node)

func unregister_interactable(node: Node) -> void:
	if interaction_component != null and interaction_component.has_method("unregister_interactable"):
		interaction_component.unregister_interactable(node)
