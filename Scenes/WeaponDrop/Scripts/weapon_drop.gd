extends Area2D

# ==================== PROPERTIES ====================

var weapon_type  := "shotgun"
var lifetime     := 0.0
var max_lifetime := 20.0     # Drop despawns after 20 seconds
var draw_timer   := 0.0
var blink_timer  := 0.0

# ==================== RARITY ====================

const WEAPON_RARITY := {
	"shotgun": "common",
	"assault": "common",
	"sniper":  "rare",
	"minigun": "rare",
	"rocket":  "epic",
}

const RARITY_COLOR := {
	"common": Color(0.85, 0.85, 0.85),
	"rare":   Color(0.25, 0.55, 1.0),
	"epic":   Color(1.0,  0.45, 0.0),
}

const WEAPON_LABEL := {
	"shotgun": "SHOTGUN",
	"assault": "ASSAULT",
	"sniper":  "SNIPER",
	"minigun": "MINIGUN",
	"rocket":  "ROCKET",
}

# ==================== SETUP ====================

func setup(type: String) -> void:
	weapon_type = type

func _ready() -> void:
	add_to_group("weapon_drops")
	collision_layer = 8
	collision_mask  = 0

	var rarity = WEAPON_RARITY.get(weapon_type, "common")
	var color  = RARITY_COLOR.get(rarity, Color.WHITE)

	# Floating weapon name label above the orb
	var name_label = Label.new()
	name_label.name     = "NameLabel"
	name_label.text     = WEAPON_LABEL.get(weapon_type, weapon_type.to_upper())
	name_label.position = Vector2(-20, -26)
	name_label.modulate = color
	name_label.add_theme_font_size_override("font_size", 8)
	add_child(name_label)

	# [G] swap hint — hidden until player is nearby with a full inventory
	var hint = Label.new()
	hint.name     = "SwapHint"
	hint.text     = "[G] Swap"
	hint.position = Vector2(-18, -38)
	hint.modulate = Color(1.0, 0.85, 0.3, 0.0)   # Start invisible
	hint.add_theme_font_size_override("font_size", 8)
	add_child(hint)

# ==================== GAME LOOP ====================

func _physics_process(delta: float) -> void:
	lifetime    += delta
	draw_timer  += delta
	blink_timer += delta

	# Blink during the final 30 % of lifetime to warn the player
	if lifetime > max_lifetime * 0.7:
		visible = int(blink_timer * 7) % 2 == 0

	if lifetime >= max_lifetime:
		queue_free()
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		queue_redraw()
		return

	var dist = global_position.distance_to(player.global_position)

	# Auto-pickup zone (18 px): grab directly if a slot is free
	if dist < 18.0:
		if player.has_method("pickup_weapon"):
			if player.pickup_weapon(weapon_type):
				queue_free()
				return

	# Swap hint zone (50 px): show [G] when inventory is full
	var swap_hint : Label = get_node_or_null("SwapHint")
	if swap_hint:
		var inv_full       = player.weapons.size() >= player.MAX_WEAPONS
		var target_alpha   = 1.0 if (dist < 50.0 and inv_full) else 0.0
		swap_hint.modulate.a = lerp(swap_hint.modulate.a, target_alpha, 0.15)

	queue_redraw()

# ==================== VISUALS ====================

func _draw() -> void:
	var rarity = WEAPON_RARITY.get(weapon_type, "common")
	var color  = RARITY_COLOR.get(rarity, Color.WHITE)
	var pulse  = 0.7 + sin(draw_timer * 2.5) * 0.3

	# Soft outer glow
	draw_circle(Vector2.ZERO, 12, Color(color.r, color.g, color.b, 0.10 * pulse))
	# Animated ring
	draw_arc(Vector2.ZERO, 8, 0, TAU, 32,
		Color(color.r, color.g, color.b, 0.65 * pulse), 1.5)
	# Solid core
	draw_circle(Vector2.ZERO, 5,
		Color(color.r * pulse, color.g * pulse, color.b * pulse, 0.95))
	# Specular highlight
	draw_circle(Vector2(-1.5, -1.5), 1.5, Color(1, 1, 1, 0.4 * pulse))
