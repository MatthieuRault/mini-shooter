extends Control

var music = preload("res://Sounds/Music/Iwan Gabovitch - Dark Ambience Loop.ogg")

var particles : Array = []
var _time := 0.0

# ==================== INITIALIZATION ====================

func _ready() -> void:
	_create_background()
	_create_particles()
	_create_rift()
	_create_title()
	_create_menu()
	_create_version()
	_play_music()
	_animate_in()
	
func _play_music() -> void:
	var player = AudioStreamPlayer.new()
	player.stream    = music
	player.volume_db = -14
	add_child(player)
	player.play()

# ==================== BACKGROUND ====================

func _create_background() -> void:
	# Deep dark base
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.05, 1.0)
	bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	add_child(bg)

	# Subtle vignette overlay (dark edges)
	var vignette = ColorRect.new()
	vignette.anchor_right = 1.0; vignette.anchor_bottom = 1.0
	vignette.color = Color(0, 0, 0, 0)
	add_child(vignette)

# ==================== RIFT VISUAL ====================

func _create_rift() -> void:
	var rift = Node2D.new()
	rift.name = "Rift"
	var script = GDScript.new()
	script.source_code = '''extends Node2D
var t := 0.0
func _process(delta):
	t += delta; queue_redraw()
func _draw():
	var cx = 480.0; var cy = 270.0
	# Outer glow rings
	for i in 5:
		var r = 80 + i * 28.0
		var alpha = (0.06 - i * 0.01) * (0.8 + sin(t * 0.7 + i) * 0.2)
		draw_arc(Vector2(cx, cy), r, -PI*0.6, PI*0.6, 48,
			Color(0.45, 0.1, 0.7, alpha), 2.0)
		draw_arc(Vector2(cx, cy), r, PI*0.4, PI*1.6, 48,
			Color(0.45, 0.1, 0.7, alpha), 2.0)
	# Central rift crack
	var crack_alpha = 0.18 + sin(t * 1.2) * 0.06
	draw_line(Vector2(cx, cy - 160), Vector2(cx - 8, cy - 60), Color(0.6, 0.15, 0.9, crack_alpha), 2.0)
	draw_line(Vector2(cx - 8, cy - 60), Vector2(cx + 5, cy + 40), Color(0.6, 0.15, 0.9, crack_alpha), 2.0)
	draw_line(Vector2(cx + 5, cy + 40), Vector2(cx - 3, cy + 160), Color(0.6, 0.15, 0.9, crack_alpha), 2.0)
	# Energy sparks around rift
	for i in 8:
		var angle = t * 0.4 + i * TAU / 8.0
		var dist  = 95 + sin(t * 2.0 + i) * 15
		var sx    = cx + cos(angle) * dist
		var sy    = cy + sin(angle) * dist * 0.55
		var sa    = 0.25 + sin(t * 3.0 + i * 1.3) * 0.2
		draw_circle(Vector2(sx, sy), 2.0, Color(0.7, 0.3, 1.0, sa))
'''
	script.reload()
	rift.set_script(script)
	add_child(rift)

# ==================== FLOATING PARTICLES ====================

func _create_particles() -> void:
	var pnode = Node2D.new()
	pnode.name = "Particles"
	var script = GDScript.new()
	script.source_code = '''extends Node2D
var pts := []
var t   := 0.0
func _ready():
	for i in 40:
		pts.append({
			"x": randf() * 960, "y": randf() * 540,
			"vy": randf_range(-8.0, -2.0),
			"vx": randf_range(-1.5, 1.5),
			"size": randf_range(0.8, 2.2),
			"phase": randf() * TAU,
			"color": [Color(0.5,0.15,0.9), Color(0.2,0.1,0.6), Color(0.8,0.3,1.0)][randi()%3]
		})
func _process(delta):
	t += delta
	for p in pts:
		p["y"] += p["vy"] * delta
		p["x"] += p["vx"] * delta
		if p["y"] < -5: p["y"] = 545; p["x"] = randf() * 960
	queue_redraw()
func _draw():
	for p in pts:
		var alpha = 0.3 + sin(t * 1.5 + p["phase"]) * 0.2
		draw_circle(Vector2(p["x"], p["y"]), p["size"], Color(p["color"].r, p["color"].g, p["color"].b, alpha))
'''
	script.reload()
	pnode.set_script(script)
	add_child(pnode)

# ==================== TITLE ====================

func _create_title() -> void:
	# SIGMA — large, animated pulse
	var sigma = Label.new()
	sigma.name = "Sigma"
	sigma.text = "SIGMA"
	sigma.add_theme_font_size_override("font_size", 52)
	sigma.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sigma.anchor_left = 0.5; sigma.anchor_right = 0.5
	sigma.anchor_top = 0.10
	sigma.offset_left = -200; sigma.offset_right = 200
	sigma.modulate = Color(1, 1, 1, 0)
	add_child(sigma)

	# Animated pulse on SIGMA
	var pulse_script = GDScript.new()
	pulse_script.source_code = '''extends Label
var t := 0.0
func _process(delta):
	t += delta
	var glow = 0.92 + sin(t * 1.4) * 0.08
	modulate = Color(glow, glow * 0.95, glow, 1.0)
'''
	pulse_script.reload()
	sigma.set_script(pulse_script)

	# DEADRIFT — red accent
	var dead = Label.new()
	dead.name = "Deadrift"
	dead.text = "DEADRIFT"
	dead.add_theme_font_size_override("font_size", 26)
	dead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dead.anchor_left = 0.5; dead.anchor_right = 0.5
	dead.anchor_top = 0.26
	dead.offset_left = -200; dead.offset_right = 200
	dead.modulate = Color(0.85, 0.2, 0.2, 0)
	add_child(dead)

	# Separator line
	var line = ColorRect.new()
	line.anchor_left = 0.5; line.anchor_right = 0.5
	line.anchor_top = 0.35
	line.offset_left = -100; line.offset_right = 100
	line.offset_bottom = 1
	line.color = Color(0.6, 0.15, 0.15, 0)
	add_child(line)

	# Tagline
	var tagline = Label.new()
	tagline.text = "La faille s'ouvre. Les morts se relèvent. Tu es le dernier."
	tagline.add_theme_font_size_override("font_size", 10)
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.modulate = Color(1, 1, 1, 0)
	tagline.anchor_left = 0.5; tagline.anchor_right = 0.5
	tagline.anchor_top = 0.38
	tagline.offset_left = -220; tagline.offset_right = 220
	add_child(tagline)

# ==================== MENU ====================

func _create_menu() -> void:
	var vbox = VBoxContainer.new()
	vbox.name = "Menu"
	vbox.anchor_left = 0.5; vbox.anchor_right = 0.5; vbox.anchor_top = 0.50
	vbox.offset_left = -90; vbox.offset_right = 90
	vbox.add_theme_constant_override("separation", 10)
	vbox.modulate = Color(1, 1, 1, 0)
	add_child(vbox)

	var play_btn = Button.new(); play_btn.text = "JOUER"
	play_btn.add_theme_font_size_override("font_size", 18)
	play_btn.pressed.connect(_on_play); vbox.add_child(play_btn)

	var quit_btn = Button.new(); quit_btn.text = "QUITTER"
	quit_btn.add_theme_font_size_override("font_size", 18)
	quit_btn.pressed.connect(_on_quit); vbox.add_child(quit_btn)

	# Controls reminder
	var controls = Label.new()
	controls.text = "ZQSD · Bouger   |   Clic G · Tirer   |   Clic D · Grenade   |   ESC · Pause\nF · Mine   |   Espace · Dash   |   B · Mode tir   |   R · Recharger\n1/2/3 · Armes   |   G · Echanger au sol   |   Molette · Cycler"
	controls.add_theme_font_size_override("font_size", 9)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.modulate = Color(1, 1, 1, 0.3)
	controls.anchor_left = 0.5; controls.anchor_right = 0.5; controls.anchor_top = 0.80
	controls.offset_left = -240; controls.offset_right = 240
	add_child(controls)

func _create_version() -> void:
	var ver = Label.new()
	ver.text = "v0.1 — alpha"
	ver.add_theme_font_size_override("font_size", 8)
	ver.modulate = Color(1, 1, 1, 0.18)
	ver.anchor_right = 1.0; ver.anchor_bottom = 1.0
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ver.offset_right = -6; ver.offset_bottom = -4
	add_child(ver)
	
	var credit = Label.new()
	credit.text = "Edited by Matthrault"
	credit.add_theme_font_size_override("font_size", 8)
	credit.modulate = Color(1, 1, 1, 0.25)
	credit.anchor_bottom = 1.0
	credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	credit.offset_left = 6; credit.offset_bottom = -4
	add_child(credit)

# ==================== FADE-IN ANIMATION ====================

func _animate_in() -> void:
	var sigma   = get_node("Sigma")
	var dead    = get_node("Deadrift")
	var menu    = get_node("Menu")

	# Staggered fade in
	var tw = create_tween()
	tw.set_parallel(false)
	tw.tween_interval(0.3)
	tw.tween_property(sigma, "modulate:a", 1.0, 0.6)
	tw.tween_interval(0.15)
	tw.tween_property(dead,  "modulate:a", 1.0, 0.5)
	tw.tween_interval(0.2)
	tw.tween_property(menu,  "modulate:a", 1.0, 0.5)

# ==================== ACTIONS ====================

func _on_play() -> void:
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): get_tree().change_scene_to_file("res://Scenes/main.tscn"))

func _on_quit() -> void:
	get_tree().quit()
