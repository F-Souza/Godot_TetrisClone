extends Node2D

var score = 0

var game_Started = false

signal start
signal rotate
signal move(dir)
signal speedUP
signal speedDown

func _on_game_manager_lineDestroied(value):
	score += value
	if score <= 9999:
		$info/lb_score.text = str(score)
	else:
		$text.text = "YOU WIN"
		$text.show()
		$anim.play("out")
	pass

func _on_game_manager_next_piece(value):
	$info/piece_preview.frame = value
	pass

# Buttons
func _on_start_B_button_up():
	if !game_Started:
		$text.hide()
		emit_signal("start")
		game_Started = true
	else:
		get_tree().paused = !(get_tree().paused)
	pass
func _on_mute_B_button_up():
	pass
func _on_rotate_B_button_up():
	emit_signal("rotate")
	pass
func _on_right_B_button_up():
	emit_signal("move",1)
	pass
func _on_left_B_button_up():
	emit_signal("move",-1)
	pass
func _on_down_B_button_up():
	emit_signal("speedDown")
	pass
func _on_down_B_button_down():
	emit_signal("speedUP")
	pass


func _on_anim_animation_finished(anim_name):
	if anim_name == "out":
		var _e = get_tree().change_scene("res://scenes/game/game_splashScreen.tscn")
	pass

func _on_game_manager_gameOver():
	$text.text = "YOU LOSE"
	$text.show()
	$anim.play("out")
	pass
