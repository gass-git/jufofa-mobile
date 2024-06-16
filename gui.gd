extends Node

func update_score_label(HUD) -> void:
	HUD.get_node("ScoreLabel").text = str(global.score)
	
func update_progress_bar(HUD) -> void:
	HUD.get_node("ProgressBar").value = global.progress_bar_value	
	
func update_bombs_label(HUD) -> void:
	HUD.get_node("BombsInStorage").text = "BOMBS:" + str(global.bombs_in_storage)	
