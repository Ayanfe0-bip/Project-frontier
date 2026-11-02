extends CharacterBody3D

@export var max_health: float = 50.0
@export var move_speed: float = 2.4
@export var attack_damage: float = 10.0
@export var detection_range: float = 12.0
@export var attack_range: float = 1.7
@export var attack_cooldown: float = 1.0

var health: float
var player_ref: Node3D = null
var attack_timer: float = 0.0

func _ready() -> void:
	health = max_health
	player_ref = get_tree().current_scene.get_node_or_null("Player")

func _physics_process(delta: float) -> void:
	if health <= 0.0:
		return
	attack_timer = max(0.0, attack_timer - delta)
	if player_ref == null:
		player_ref = get_tree().current_scene.get_node_or_null("Player")
		if player_ref == null:
			return
	var target_dir := player_ref.global_position - global_position
	var distance_to_player := target_dir.length()
	if distance_to_player <= detection_range:
		target_dir.y = 0.0
		if target_dir.length() > 0.01:
			look_at(player_ref.global_position, Vector3.UP)
			var movement := target_dir.normalized() * move_speed
			if distance_to_player > attack_range:
				velocity.x = movement.x
				velocity.z = movement.z
			else:
				velocity.x = 0.0
				velocity.z = 0.0
				if attack_timer <= 0.0:
					attack_timer = attack_cooldown
					if player_ref.has_method("take_damage"):
						player_ref.take_damage(attack_damage, name)
		else:
			velocity.x = move_toward(velocity.x, 0.0, 6.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, 6.0 * delta)
	move_and_slide()

func apply_damage(amount: float, _source: String = "weapon") -> void:
	if health <= 0.0:
		return
	health -= amount
	if health <= 0.0:
		health = 0.0
		queue_free()

func get_health_ratio() -> float:
	if max_health <= 0.0:
		return 0.0
	return health / max_health
