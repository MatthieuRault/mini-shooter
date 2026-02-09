extends CharacterBody2D

var speed := 100.0
var player : CharacterBody2D
var health := 3

func _ready() -> void:
	add_to_group("enemy")
	#$Sprite2D.modulate = Color.RED

func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if not is_instance_valid(player):
		return
		
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
		
	# Contact damage
	if global_position.distance_to(player.global_position) < 30:
		if player.has_method("take_damage"):
			player.take_damage(1)


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		var main = get_tree().current_scene
		if main.has_method("add_score"):
			main.add_score(10)
		queue_free()  # Death
	else:
		$Sprite2D.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = Color.WHITE
