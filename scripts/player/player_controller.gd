extends CharacterBody3D

@export_group("Movement")
@export var walk_speed: float = 4.5
@export var sprint_speed: float = 7.0
@export var acceleration: float = 12.0
@export var deceleration: float = 14.0
@export var jump_velocity: float = 5.2

@export_group("Physics")
@export var gravity: float = 20.0

var move_input: Vector2 = Vector2.ZERO
var is_sprinting: bool = false


func _ready() -> void:
    _ensure_input_actions()


func _physics_process(delta: float) -> void:
    _apply_gravity(delta)
    _handle_movement(delta)
    move_and_slide()


func _ensure_input_actions() -> void:
    var actions: Array[String] = [
        "move_forward",
        "move_back",
        "move_left",
        "move_right",
        "sprint",
        "jump",
    ]

    for action_name in actions:
        if not InputMap.has_action(action_name):
            InputMap.add_action(action_name)

    if not InputMap.action_has_event("move_forward", InputEventKey.new()):
        _bind_key("move_forward", KEY_W)
        _bind_key("move_forward", KEY_UP)

    if not InputMap.action_has_event("move_back", InputEventKey.new()):
        _bind_key("move_back", KEY_S)
        _bind_key("move_back", KEY_DOWN)

    if not InputMap.action_has_event("move_left", InputEventKey.new()):
        _bind_key("move_left", KEY_A)
        _bind_key("move_left", KEY_LEFT)

    if not InputMap.action_has_event("move_right", InputEventKey.new()):
        _bind_key("move_right", KEY_D)
        _bind_key("move_right", KEY_RIGHT)

    if not InputMap.action_has_event("sprint", InputEventKey.new()):
        _bind_key("sprint", KEY_SHIFT)

    if not InputMap.action_has_event("jump", InputEventKey.new()):
        _bind_key("jump", KEY_SPACE)


func _bind_key(action_name: String, keycode: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = keycode
    InputMap.action_add_event(action_name, event)


func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta


func _handle_movement(delta: float) -> void:
    move_input = Vector2(
        Input.get_axis("move_left", "move_right"),
        Input.get_axis("move_forward", "move_back")
    )

    is_sprinting = Input.is_action_pressed("sprint") and move_input.length() > 0.1
    var target_speed: float = sprint_speed if is_sprinting else walk_speed

    var direction := Vector3.ZERO
    if move_input.length() > 0.05:
        direction.x = move_input.x
        direction.z = move_input.y
        direction = direction.normalized()

        var target_velocity := transform.basis * direction * target_speed
        var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
        var desired_velocity := Vector3(target_velocity.x, 0.0, target_velocity.z)

        if horizontal_velocity.length() > 0.01:
            var blend := acceleration * delta
            horizontal_velocity = horizontal_velocity.lerp(desired_velocity, min(1.0, blend))
        else:
            horizontal_velocity = desired_velocity

        velocity.x = horizontal_velocity.x
        velocity.z = horizontal_velocity.z

        var look_direction := Vector2(direction.x, direction.z)
        if look_direction.length() > 0.1:
            rotation.y = atan2(direction.x, direction.z)
    else:
        var current_horizontal := Vector3(velocity.x, 0.0, velocity.z)
        var target_horizontal := Vector3.ZERO
        current_horizontal = current_horizontal.lerp(target_horizontal, min(1.0, deceleration * delta))
        velocity.x = current_horizontal.x
        velocity.z = current_horizontal.z

    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    if is_on_floor() and velocity.y < 0.0:
        velocity.y = -0.1
