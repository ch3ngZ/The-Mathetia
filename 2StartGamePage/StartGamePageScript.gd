extends Node

var scene_path = ""
var color_rect_node = null
var go_back_button = null
var prologue_button = null

func _ready():
	color_rect_node = $Transition
	color_rect_node.get_node("AnimationPlayer").play("FadeOut")
	color_rect_node.get_node("AnimationPlayer").connect("animation_finished", self, "_on_FadeIn_animation_finished")

	go_back_button = $GoBackButton
	go_back_button.connect("pressed", self, "_on_Button_pressed", ["res://1HomePage/HomePage.tscn", go_back_button])
	
	prologue_button = $HBoxContainer/PrologueButton
	prologue_button.connect("pressed", self, "_on_Button_pressed", ["res://5Prologue/PrologueScene.tscn", prologue_button])
	
func _on_Button_pressed(path, button):
	scene_path = path
	button.get_node("AnimationPlayer").play("Flash")  # Play flash animation
	color_rect_node.get_node("AnimationPlayer").play("FadeIn")


func _on_FadeIn_animation_finished(animation_name):
	if animation_name != "FadeIn":
		return

	var new_scene = load(scene_path).instance()
	var current_scene = get_tree().current_scene

	if current_scene:
		current_scene.queue_free()
	get_tree().root.add_child(new_scene)  # Add new scene to Scene Tree
	color_rect_node.get_node("AnimationPlayer").play("FadeOut")
	get_tree().current_scene = new_scene  # Set the new scene as the current scene

