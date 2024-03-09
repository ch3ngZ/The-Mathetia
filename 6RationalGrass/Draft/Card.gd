class_name Card extends Area2D

var card_type

func _ready():
	connect("mouse_entered", self, "_on_card_mouse_enter")
	connect("mouse_exited", self, "_on_card_mouse_exit")
	connect("input_event", self, "_on_card_clicked")

func _on_card_mouse_enter():
	get_node("Sprite").modulate = Color(1, 0, 0, 1) # Example: change to red

func _on_card_mouse_exit():
	get_node("Sprite").modulate = Color(1, 1, 1, 1) # Example: change back to white

func _on_card_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		# 通知上层节点卡牌被点击
		get_parent().emit_signal("card_clicked", self, card_type)
