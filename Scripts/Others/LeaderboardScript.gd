extends CanvasLayer

@onready var entriesContainer : VBoxContainer = $Control/Panel/MarginContainer/VBoxContainer/ScrollContainer/EntriesContainer
@onready var headerRow = $Control/Panel/MarginContainer/VBoxContainer/HeaderRow
@onready var nameHeader = $Control/Panel/MarginContainer/VBoxContainer/HeaderRow/NameHeader
@onready var timeHeader = $Control/Panel/MarginContainer/VBoxContainer/HeaderRow/TimeHeader
@onready var distanceHeader = $Control/Panel/MarginContainer/VBoxContainer/HeaderRow/DistanceHeader
@onready var damageHeader = $Control/Panel/MarginContainer/VBoxContainer/HeaderRow/DamageHeader
@onready var levelHeader = $Control/Panel/MarginContainer/VBoxContainer/HeaderRow/LevelHeader

@export var mainMenu: CanvasLayer

var leaderboardEnabled: bool = false

func _ready():
	setLeaderboard(false)

func setLeaderboard(value: bool):
	visible = value
	leaderboardEnabled = value
	
	if value:
		# Ensure leaderboard data is fetched fresh when opening
		GlobalLeaderboard.fetchLeaderboard()
		await displayWhenDataReady()
	else:
		pass

# -------------------------------
# Wait for leaderboard data before displaying
func displayWhenDataReady():
	var maxWaitFrames := 300  # ~5 seconds at 60fps
	var waited := 0
	while GlobalLeaderboard.leaderboard.size() == 0 and waited < maxWaitFrames:
		await get_tree().process_frame
		waited += 1

	displayLeaderboard()

# -------------------------------
func displayLeaderboard():
	# Clear previous
	for child in entriesContainer.get_children():
		child.queue_free()
	
	for i in GlobalLeaderboard.leaderboard.size():
		var entry = GlobalLeaderboard.leaderboard[i]
		var row := HBoxContainer.new()
		row.custom_minimum_size.x = headerRow.size.x
		row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_theme_constant_override("separation", 8)
		
		var nameLabel := Label.new()
		var customFont := FontFile.new()
		customFont.font_data = load("res://Arts/Fonts/Ranga-Bold.ttf")
		nameLabel.text = str(entry.get("player_id", "Unknown"))
		nameLabel.custom_minimum_size.x = nameHeader.size.x
		nameLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nameLabel.add_theme_color_override("font_color", Color(1, 0.831, 0.231))
		nameLabel.add_theme_font_override("font", customFont)
		nameLabel.add_theme_font_size_override("font_size", 20)
		row.add_child(nameLabel)
		
		for key in ["best_time", "lowest_distance", "least_damage", "level"]:
			var label := Label.new()
			var vSeperator := VSeparator.new()
			
			if key == "best_time":
				label.text = str(entry.get(key, "-")) + "s"
				label.custom_minimum_size.x = timeHeader.size.x
			elif key == "lowest_distance":
				label.text = str(entry.get(key, "-")) + "m"
				label.custom_minimum_size.x = distanceHeader.size.x
			elif key == "least_damage":
				label.text = str(entry.get(key, "-")) + "hp"
				label.custom_minimum_size.x = damageHeader.size.x
			else:
				label.text = str(entry.get(key, "-"))
				label.custom_minimum_size.x = levelHeader.size.x
			
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.clip_text = true
			label.add_theme_color_override("font_color", Color(1, 0.831, 0.231))
			label.add_theme_font_override("font", customFont)
			label.add_theme_font_size_override("font_size", 25)
			row.add_child(vSeperator)
			row.add_child(label)
		
		var panel := Panel.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if i % 2 == 0:
			panel.add_theme_color_override("panel", Color(0.95, 0.95, 0.95))
		else:
			pass
			
		panel.add_child(row)
		entriesContainer.add_child(panel)

# -------------------------------
func _on_back_button_pressed() -> void:
	setLeaderboard(false)
	mainMenu.setMainMenu(true, true)
