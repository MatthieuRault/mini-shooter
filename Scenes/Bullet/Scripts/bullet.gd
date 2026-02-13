extends Area2D

var damage := 1
var speed := 500.0
var piercing := false
var hits := 0
var max_pierce := 5

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move bullet forward
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func set_piercing(value: bool) -> void:
	piercing = value

# Destroy bullet when hit
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
	if piercing:
		hits += 1
		if hits >= max_pierce:
			queue_free()
	else:
		queue_free()	
	
# Remove bullet when it leaves the screen
func _on_screen_exited() -> void:
	queue_free()
