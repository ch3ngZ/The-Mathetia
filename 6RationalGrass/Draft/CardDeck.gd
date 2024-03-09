class_name CardDeck extends Node2D

"""
Window size 1600x800，
000(800, 500), 0L1(500, 500), 0L2 (200, 500) ...
0R1(1100, 500), 0R2(1400, 500)...
111(800, 430), 1L1(520, 430), 1L2(240, 430), 1R1(1080, 430), 1R2(1360, 430)...
"""

var config = []

func _ready():
	for row_holder in get_children():
		row_holder.connect("card_clicked", self, "_on_card_clicked")

	config = load_config("res://6RationalGrass/.cardConfig.txt")
	layout_cards()


func load_config(filename):
	var file = File.new()
	if file.file_exists(filename):
		file.open(filename, File.READ)
		var data = []
		while !file.eof_reached():
			var line = file.get_line().split(",")
			data.append(line)
		file.close()
		return data
	else:
		print("Config file not found!")
		return null
		

func layout_cards():
	for i in range(config.size()):
		var row_holder = get_child(i)
		row_holder.layout_row(config[i])
		

func _on_card_clicked(card, card_type):
	if card_type == "middle_card":
		$middleAnimationPlayer.play("middle_animation")
	elif card_type == "left_card":
		$leftAnimationPlayer.play("left_animation")
	elif card_type == "right_card":
		$rightAnimationPlayer.play("right_animation")

	# Shuffle logic
	config.remove(0)
	# Call layout_cards() to refresh the display after shuffling
	layout_cards()
