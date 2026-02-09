extends Node2D

var score := 0
var is_game_over := false
var enemy_scene = preload("res://Scenes/Main/Enemy/enemy.tscn")
@onready var score_label = $CanvasLayer/MarginContainer/Label

func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if is_game_over:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player:
		score_label.text = "Score: " + str(score) + "  |  Vie: " + str(player.health)

func _input(event: InputEvent) -> void:
	if is_game_over and event is InputEventKey and event.pressed:
		get_tree().reload_current_scene()

func add_score(amount: int) -> void:
	score += amount
	
func game_over() -> void:
	is_game_over = true
	score_label.text = "GAME OVER ! Score: " + str(score) + "\nAppuyer sur une touche pour rejouer"
	$Timer.stop()
# Clear all remaining enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()
		
func _on_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()	
	# Random spawn at screen edges
	var side = randi() % 4
	var viewport_size = get_viewport_rect().size
	
	match side:
		0: # Top
			enemy.global_position = Vector2(randf() * viewport_size.x, -50)
		1: # Bottom
			enemy.global_position = Vector2(randf() * viewport_size.x, viewport_size.y + 50)
		2: # Left
			enemy.global_position = Vector2(-50, randf() * viewport_size.y)
		3: # Right
			enemy.global_position = Vector2(viewport_size.x + 50, randf() * viewport_size.y)
	
	add_child(enemy)
