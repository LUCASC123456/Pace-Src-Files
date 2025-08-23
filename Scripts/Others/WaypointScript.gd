extends Control

# Margin to keep the marker away from the screen's corners.
const MARGIN := 8

# The waypoint's text.
@export var text: String = "Waypoint" : set = set_text

# If `true`, the waypoint sticks to the viewport's edges when moving off-screen.
@export var sticky: bool = true

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var parent: Node = get_parent()
@onready var label: Label = $Label
@onready var marker: TextureRect = $Marker


func _ready() -> void:
	self.text = text

	if not parent is Node3D:
		push_error("The waypoint's parent node must inherit from Node3D.")


func _process(_delta: float) -> void:
	if not camera or not camera.current:
		# Refresh camera if current one changes
		camera = get_viewport().get_camera_3d()
		if not camera:
			return

	var parent_translation: Vector3 = parent.global_transform.origin
	var camera_transform: Transform3D = camera.global_transform
	var camera_translation: Vector3 = camera_transform.origin

	# Behind camera check
	var is_behind := camera_transform.basis.z.dot(parent_translation - camera_translation) > 0

	# Fade the waypoint when the camera gets close.
	var distance := camera_translation.distance_to(parent_translation)
	modulate.a = clamp(remap(distance, 0.0, 2.0, 0.0, 1.0), 0.0, 1.0)

	# Convert world position to screen position
	var unprojected_position: Vector2 = camera.unproject_position(parent_translation)

	var viewport_base_size: Vector2 = get_viewport().get_visible_rect().size

	if not sticky:
		# Simple non-sticky marker
		position = unprojected_position
		visible = not is_behind
		return

	# Handle X axis
	if is_behind:
		if unprojected_position.x < viewport_base_size.x / 2.0:
			unprojected_position.x = viewport_base_size.x - MARGIN
		else:
			unprojected_position.x = MARGIN

	# Handle Y axis
	if is_behind or unprojected_position.x < MARGIN or \
			unprojected_position.x > viewport_base_size.x - MARGIN:
		var look: Transform3D = camera_transform.looking_at(parent_translation, Vector3.UP)
		var diff: float = angle_diff(
			look.basis.get_euler().x,
			camera_transform.basis.get_euler().x
		)
		unprojected_position.y = viewport_base_size.y * (0.5 + (diff / deg_to_rad(camera.fov)))

	# Clamp final position
	position = Vector2(
		clamp(unprojected_position.x, MARGIN, viewport_base_size.x - MARGIN),
		clamp(unprojected_position.y, MARGIN, viewport_base_size.y - MARGIN)
	)

	label.visible = true
	rotation = 0.0
	var overflow := 0.0

	# Overflow handling for corner arrows
	if position.x <= MARGIN:
		overflow = -45.0
		label.visible = false
		rotation = 90.0
	elif position.x >= viewport_base_size.x - MARGIN:
		overflow = 45.0
		label.visible = false
		rotation = 270.0

	if position.y <= MARGIN:
		label.visible = false
		rotation = 180.0 + overflow
	elif position.y >= viewport_base_size.y - MARGIN:
		label.visible = false
		rotation = -overflow


func set_text(p_text: String) -> void:
	text = p_text
	if is_inside_tree():
		label.text = p_text


static func angle_diff(from_angle: float, to_angle: float) -> float:
	var diff := fmod(to_angle - from_angle, TAU)
	return fmod(2.0 * diff, TAU) - diff
