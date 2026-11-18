extends Node3D

const BUILD_NUMBER := "zaodworld-stop23-v1"
const MOVE_SPEED := 7.5
const SPRINT_SPEED := 12.0
const GRAVITY := 22.0

var player: CharacterBody3D
var camera_pivot: Node3D
var camera: Camera3D
var yaw := 0.0
var pitch := deg_to_rad(-24.0)
var joystick_touch := -1
var joystick_position := Vector2.ZERO
var joystick_value := Vector2.ZERO
var joystick_base: Control
var joystick_knob: Control
var camera_touch := -1
var camera_previous := Vector2.ZERO
var speed_label: Label
var status_label: Label


func _ready() -> void:
	_setup_world()
	_setup_player()
	_setup_ui()


func _setup_world() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.42, 0.66, 0.88)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_color = Color(0.74, 0.82, 0.92)
	environment.ambient_light_energy = 0.55
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.62, 0.74, 0.82)
	environment.fog_density = 0.004
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-38.0, -35.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

	_create_box("Ground", Vector3(0.0, -0.5, 0.0), Vector3(220.0, 1.0, 220.0),
		Color(0.22, 0.48, 0.22), true)

	# Two large roads and a central plaza form the first connected city area.
	_create_box("NorthRoad", Vector3(0.0, 0.02, 0.0), Vector3(220.0, 0.04, 18.0),
		Color(0.20, 0.22, 0.24), true)
	_create_box("WestRoad", Vector3(0.0, 0.025, 0.0), Vector3(18.0, 0.05, 220.0),
		Color(0.20, 0.22, 0.24), true)
	_create_box("Plaza", Vector3(0.0, 0.055, 0.0), Vector3(28.0, 0.08, 28.0),
		Color(0.62, 0.59, 0.50), true)

	var building_positions := [
		Vector3(-30.0, 0.0, -30.0), Vector3(30.0, 0.0, -30.0),
		Vector3(-32.0, 0.0, 32.0), Vector3(34.0, 0.0, 34.0),
		Vector3(-62.0, 0.0, 0.0), Vector3(62.0, 0.0, 0.0)
	]
	var building_colors := [
		Color(0.72, 0.38, 0.28), Color(0.30, 0.48, 0.68),
		Color(0.82, 0.70, 0.42), Color(0.55, 0.38, 0.62),
		Color(0.44, 0.62, 0.50), Color(0.74, 0.52, 0.34)
	]
	for i in range(building_positions.size()):
		var pos: Vector3 = building_positions[i]
		var width := 16.0 if i < 4 else 20.0
		var height := 10.0 + float(i % 3) * 5.0
		_create_box("Building%d" % i, pos + Vector3(0.0, height * 0.5, 0.0),
			Vector3(width, height, width), building_colors[i], true)

	var random := RandomNumberGenerator.new()
	random.seed = 20261118
	for i in range(54):
		var x := random.randf_range(-92.0, 92.0)
		var z := random.randf_range(-92.0, 92.0)
		if abs(x) < 18.0 or abs(z) < 18.0:
			continue
		_create_tree(Vector3(x, 0.0, z), random.randf_range(0.75, 1.35))


func _create_box(box_name: String, position: Vector3, size: Vector3, color: Color,
		collision: bool) -> Node3D:
	var body: Node3D
	if collision:
		var static_body := StaticBody3D.new()
		body = static_body
	else:
		body = Node3D.new()
	body.name = box_name
	body.position = position

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	mesh.material = material
	mesh_instance.mesh = mesh
	body.add_child(mesh_instance)

	if collision:
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		body.add_child(shape)
	add_child(body)
	return body


func _create_tree(position: Vector3, tree_scale: float) -> void:
	var trunk := StaticBody3D.new()
	trunk.name = "Tree"
	trunk.position = position
	var trunk_mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.28 * tree_scale
	cylinder.bottom_radius = 0.38 * tree_scale
	cylinder.height = 3.2 * tree_scale
	var trunk_material := StandardMaterial3D.new()
	trunk_material.albedo_color = Color(0.36, 0.24, 0.13)
	cylinder.material = trunk_material
	trunk_mesh.mesh = cylinder
	trunk_mesh.position.y = 1.6 * tree_scale
	trunk.add_child(trunk_mesh)

	var crown := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.8 * tree_scale
	sphere.height = 3.6 * tree_scale
	var crown_material := StandardMaterial3D.new()
	crown_material.albedo_color = Color(0.12, 0.38, 0.16)
	sphere.material = crown_material
	crown.mesh = sphere
	crown.position.y = 4.2 * tree_scale
	trunk.add_child(crown)

	var collision := CollisionShape3D.new()
	var cylinder_shape := CylinderShape3D.new()
	cylinder_shape.radius = 0.38 * tree_scale
	cylinder_shape.height = 3.2 * tree_scale
	collision.shape = cylinder_shape
	collision.position.y = 1.6 * tree_scale
	trunk.add_child(collision)
	add_child(trunk)


func _setup_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0.0, 1.0, 12.0)
	add_child(player)

	var body_mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.52
	capsule.height = 1.8
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color(0.95, 0.68, 0.20)
	capsule.material = body_material
	body_mesh.mesh = capsule
	body_mesh.position.y = 0.9
	player.add_child(body_mesh)

	var collision := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.52
	capsule_shape.height = 1.8
	collision.shape = capsule_shape
	collision.position.y = 0.9
	player.add_child(collision)

	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0.0, 1.6, 0.0)
	player.add_child(camera_pivot)

	camera = Camera3D.new()
	camera.name = "Camera"
	camera.current = true
	camera_pivot.add_child(camera)


func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var title := Label.new()
	title.text = "ZAOD WORLD"
	title.position = Vector2(24.0, 18.0)
	title.add_theme_font_size_override("font_size", 24)
	title.modulate = Color(1.0, 1.0, 1.0)
	canvas.add_child(title)

	status_label = Label.new()
	status_label.text = "3D world loaded"
	status_label.position = Vector2(24.0, 48.0)
	status_label.add_theme_font_size_override("font_size", 16)
	canvas.add_child(status_label)

	speed_label = Label.new()
	speed_label.text = "BUILD: " + BUILD_NUMBER
	speed_label.position = Vector2(24.0, 72.0)
	speed_label.add_theme_font_size_override("font_size", 14)
	canvas.add_child(speed_label)

	joystick_base = Control.new()
	joystick_base.position = Vector2(42.0, 520.0)
	joystick_base.size = Vector2(160.0, 160.0)
	canvas.add_child(joystick_base)
	joystick_base.draw.connect(_draw_joystick)
	joystick_position = joystick_base.position + joystick_base.size * 0.5

	joystick_knob = Control.new()
	joystick_knob.position = joystick_position - Vector2(24.0, 24.0)
	joystick_knob.size = Vector2(48.0, 48.0)
	joystick_knob.draw.connect(_draw_knob)
	canvas.add_child(joystick_knob)


func _draw_joystick() -> void:
	var center := joystick_base.size * 0.5
	joystick_base.draw_circle(center, 72.0, Color(0.0, 0.0, 0.0, 0.25))
	joystick_base.draw_circle(center, 68.0, Color(1.0, 1.0, 1.0, 0.12))


func _draw_knob() -> void:
	joystick_knob.draw_circle(Vector2(24.0, 24.0), 24.0, Color(0.95, 0.68, 0.20, 0.88))


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		var viewport_size := get_viewport().get_visible_rect().size
		if touch.pressed:
			if touch.position.x < viewport_size.x * 0.48:
				joystick_touch = touch.index
				_update_joystick(touch.position)
			else:
				camera_touch = touch.index
				camera_previous = touch.position
		else:
			if touch.index == joystick_touch:
				joystick_touch = -1
				joystick_value = Vector2.ZERO
				_update_joystick(joystick_position)
			if touch.index == camera_touch:
				camera_touch = -1
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == joystick_touch:
			_update_joystick(drag.position)
		elif drag.index == camera_touch:
			yaw -= drag.relative.x * 0.006
			pitch = clamp(pitch - drag.relative.y * 0.005, deg_to_rad(-65.0), deg_to_rad(25.0))
			camera_previous = drag.position


func _update_joystick(position: Vector2) -> void:
	var center := joystick_position
	var relative := position - center
	if relative.length() > 68.0:
		relative = relative.normalized() * 68.0
	joystick_value = relative / 68.0
	joystick_knob.position = center + relative - Vector2(24.0, 24.0)
	joystick_base.queue_redraw()
	joystick_knob.queue_redraw()


func _physics_process(delta: float) -> void:
	var move_input := Vector2.ZERO
	move_input.x = Input.get_axis("ui_left", "ui_right")
	move_input.y = Input.get_axis("ui_up", "ui_down")
	move_input += Vector2(joystick_value.x, -joystick_value.y)
	move_input = move_input.limit_length(1.0)

	var camera_forward := -camera_pivot.global_transform.basis.z
	camera_forward.y = 0.0
	camera_forward = camera_forward.normalized()
	var camera_right := camera_pivot.global_transform.basis.x
	camera_right.y = 0.0
	camera_right = camera_right.normalized()
	var direction := (camera_right * move_input.x + camera_forward * (-move_input.y)).normalized()

	var keyboard_sprint := Input.is_physical_key_pressed(KEY_SHIFT)
	var speed := SPRINT_SPEED if keyboard_sprint else MOVE_SPEED
	if move_input.length() > 0.1:
		player.velocity.x = direction.x * speed
		player.velocity.z = direction.z * speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, 12.0 * delta)
		player.velocity.z = move_toward(player.velocity.z, 0.0, 12.0 * delta)

	if not player.is_on_floor():
		player.velocity.y -= GRAVITY * delta
	else:
		player.velocity.y = -1.0
	if Input.is_physical_key_pressed(KEY_SPACE) and player.is_on_floor():
		player.velocity.y = 8.5

	player.move_and_slide()
	player.rotation.y = yaw
	camera_pivot.rotation = Vector3(pitch, yaw, 0.0)
	camera.position = Vector3(0.0, 0.0, 8.5)
	camera.look_at(player.global_position + Vector3(0.0, 1.2, 0.0))

	speed_label.text = "BUILD: %s  |  SPEED: %d" % [BUILD_NUMBER, int(speed)]
