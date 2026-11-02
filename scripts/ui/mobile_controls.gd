extends Node2D

@onready var ui_root: Control = $UIRoot
@onready var left_stick_base: Panel = $UIRoot/LeftStickBase
@onready var left_stick_knob: Panel = $UIRoot/LeftStickBase/Knob
@onready var right_drag_area: Panel = $UIRoot/RightDragArea
@onready var jump_button: Button = $UIRoot/JumpButton
@onready var sprint_button: Button = $UIRoot/SprintButton
@onready var interact_button: Button = $UIRoot/InteractButton
@onready var fire_button: Button = $UIRoot/FireButton
@onready var aim_button: Button = $UIRoot/AimButton
@onready var reload_button: Button = $UIRoot/ReloadButton
@onready var switch_button: Button = $UIRoot/SwitchButton

var left_touch_id: int = -1
var right_touch_id: int = -1
var left_touch_radius: float = 70.0
var player_ref: Node = null
var camera_ref: Node = null

func _ready() -> void:
	visible = OS.has_feature("android")
	if not visible:
		set_process_unhandled_input(false)
		set_process_input(false)
		return
	_assign_refs()
	_ensure_input_actions()
	_layout_controls()

func _assign_refs() -> void:
	var root := get_tree().current_scene
	if root != null:
		player_ref = root.get_node_or_null("Player")
		camera_ref = root.get_node_or_null("ThirdPersonCamera")

func _ensure_input_actions() -> void:
	var actions: Array[String] = [
		"move_forward",
		"move_back",
		"move_left",
		"move_right",
		"sprint",
		"jump",
		"interact",
		"fire",
		"aim",
		"reload",
		"weapon_next",
		"weapon_prev",
	]
	for action_name in actions:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

func _layout_controls() -> void:
	if ui_root == null:
		return
	ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_root.offset_left = 0.0
	ui_root.offset_top = 0.0
	ui_root.offset_right = 0.0
	ui_root.offset_bottom = 0.0
	var viewport_size := get_viewport_rect().size
	left_stick_base.size = Vector2(180.0, 180.0)
	left_stick_base.position = Vector2(32.0, viewport_size.y - 220.0)
	left_touch_radius = min(left_stick_base.size.x, left_stick_base.size.y) * 0.34
	left_stick_knob.size = Vector2(62.0, 62.0)
	left_stick_knob.position = left_stick_base.size * 0.5 - left_stick_knob.size * 0.5
	right_drag_area.size = Vector2(240.0, 240.0)
	right_drag_area.position = Vector2(viewport_size.x - 270.0, viewport_size.y - 270.0)
	jump_button.size = Vector2(112.0, 112.0)
	jump_button.position = Vector2(viewport_size.x - 160.0, viewport_size.y - 170.0)
	sprint_button.size = Vector2(96.0, 96.0)
	sprint_button.position = Vector2(viewport_size.x - 276.0, viewport_size.y - 246.0)
	interact_button.size = Vector2(96.0, 96.0)
	interact_button.position = Vector2(viewport_size.x - 160.0, viewport_size.y - 300.0)
	fire_button.size = Vector2(90.0, 90.0)
	fire_button.position = Vector2(viewport_size.x - 128.0, viewport_size.y - 420.0)
	aim_button.size = Vector2(90.0, 90.0)
	aim_button.position = Vector2(viewport_size.x - 238.0, viewport_size.y - 420.0)
	reload_button.size = Vector2(90.0, 90.0)
	reload_button.position = Vector2(viewport_size.x - 128.0, viewport_size.y - 520.0)
	switch_button.size = Vector2(90.0, 90.0)
	switch_button.position = Vector2(viewport_size.x - 238.0, viewport_size.y - 520.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_controls()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if touch_event.pressed:
			var half_width := get_viewport_rect().size.x * 0.5
			if left_touch_id == -1 and touch_event.position.x < half_width:
				left_touch_id = touch_event.index
				_handle_left_touch(touch_event.position)
			elif right_touch_id == -1 and touch_event.position.x >= half_width:
				right_touch_id = touch_event.index
				_handle_right_touch(touch_event.position)
		else:
			if touch_event.index == left_touch_id:
				left_touch_id = -1
				_reset_left_joystick()
			elif touch_event.index == right_touch_id:
				right_touch_id = -1
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event
		if drag_event.index == left_touch_id:
			_handle_left_drag(drag_event.position)
		elif drag_event.index == right_touch_id:
			_handle_right_drag(drag_event.relative)

func _handle_left_touch(position: Vector2) -> void:
	_handle_left_drag(position)

func _handle_left_drag(position: Vector2) -> void:
	var base_center := left_stick_base.position + left_stick_base.size * 0.5
	var delta := position - base_center
	var clamped := delta.limit_length(maxf(left_touch_radius, 1.0))
	left_stick_knob.position = left_stick_base.size * 0.5 + clamped - left_stick_knob.size * 0.5
	var normalized := Vector2(clamped.x / maxf(left_touch_radius, 1.0), -clamped.y / maxf(left_touch_radius, 1.0))
	if normalized.length() < 0.05:
		_reset_left_joystick()
		return
	if player_ref != null and player_ref.has_method("set_mobile_move_vector"):
		player_ref.set_mobile_move_vector(normalized)

func _reset_left_joystick() -> void:
	left_stick_knob.position = left_stick_base.size * 0.5 - left_stick_knob.size * 0.5
	if player_ref != null and player_ref.has_method("set_mobile_move_vector"):
		player_ref.set_mobile_move_vector(Vector2.ZERO)

func _handle_right_touch(_position: Vector2) -> void:
	pass

func _handle_right_drag(relative: Vector2) -> void:
	if camera_ref != null and camera_ref.has_method("apply_rotation_input"):
		camera_ref.apply_rotation_input(relative)

func _on_jump_pressed() -> void:
	jump_button.modulate = Color(0.9, 1.0, 0.6, 1.0)
	if player_ref != null and player_ref.has_method("set_mobile_jump_active"):
		player_ref.set_mobile_jump_active(true)
	elif InputMap.has_action("jump"):
		Input.action_press("jump")

func _on_jump_released() -> void:
	jump_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if player_ref != null and player_ref.has_method("set_mobile_jump_active"):
		player_ref.set_mobile_jump_active(false)
	elif InputMap.has_action("jump"):
		Input.action_release("jump")

func _on_sprint_pressed() -> void:
	sprint_button.modulate = Color(0.7, 0.95, 1.0, 1.0)
	if player_ref != null and player_ref.has_method("set_mobile_sprint_active"):
		player_ref.set_mobile_sprint_active(true)
	elif InputMap.has_action("sprint"):
		Input.action_press("sprint")

func _on_sprint_released() -> void:
	sprint_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if player_ref != null and player_ref.has_method("set_mobile_sprint_active"):
		player_ref.set_mobile_sprint_active(false)
	elif InputMap.has_action("sprint"):
		Input.action_release("sprint")

func _on_interact_pressed() -> void:
	interact_button.modulate = Color(1.0, 0.8, 0.45, 1.0)
	if InputMap.has_action("interact"):
		Input.action_press("interact")

func _on_interact_released() -> void:
	interact_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if InputMap.has_action("interact"):
		Input.action_release("interact")

func _on_fire_pressed() -> void:
	fire_button.modulate = Color(1.0, 0.55, 0.4, 1.0)
	if InputMap.has_action("fire"):
		Input.action_press("fire")

func _on_fire_released() -> void:
	fire_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if InputMap.has_action("fire"):
		Input.action_release("fire")

func _on_aim_pressed() -> void:
	aim_button.modulate = Color(0.5, 0.9, 1.0, 1.0)
	if InputMap.has_action("aim"):
		Input.action_press("aim")

func _on_aim_released() -> void:
	aim_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if InputMap.has_action("aim"):
		Input.action_release("aim")

func _on_reload_pressed() -> void:
	reload_button.modulate = Color(0.9, 0.8, 0.35, 1.0)
	if InputMap.has_action("reload"):
		Input.action_press("reload")

func _on_reload_released() -> void:
	reload_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if InputMap.has_action("reload"):
		Input.action_release("reload")

func _on_switch_pressed() -> void:
	switch_button.modulate = Color(0.6, 1.0, 0.6, 1.0)
	if InputMap.has_action("weapon_next"):
		Input.action_press("weapon_next")
	if InputMap.has_action("weapon_prev"):
		Input.action_release("weapon_prev")

func _on_switch_released() -> void:
	switch_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if InputMap.has_action("weapon_next"):
		Input.action_release("weapon_next")

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if jump_button.get_global_rect().has_point(mouse_event.position):
				_on_jump_pressed()
			elif sprint_button.get_global_rect().has_point(mouse_event.position):
				_on_sprint_pressed()
			elif interact_button.get_global_rect().has_point(mouse_event.position):
				_on_interact_pressed()
			elif fire_button.get_global_rect().has_point(mouse_event.position):
				_on_fire_pressed()
			elif aim_button.get_global_rect().has_point(mouse_event.position):
				_on_aim_pressed()
			elif reload_button.get_global_rect().has_point(mouse_event.position):
				_on_reload_pressed()
			elif switch_button.get_global_rect().has_point(mouse_event.position):
				_on_switch_pressed()
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			if jump_button.button_pressed:
				_on_jump_released()
			if sprint_button.button_pressed:
				_on_sprint_released()
			if interact_button.button_pressed:
				_on_interact_released()
			if fire_button.button_pressed:
				_on_fire_released()
			if aim_button.button_pressed:
				_on_aim_released()
			if reload_button.button_pressed:
				_on_reload_released()
			if switch_button.button_pressed:
				_on_switch_released()
