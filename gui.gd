extends Node

func update_score_label(HUD) -> void:
	HUD.get_node("ScoreLabel").text = str(global.score)
	
func update_progress_bar(HUD) -> void:
	HUD.get_node("ProgressBar").value = global.progress_bar_value	
	
func update_bombs_label(HUD) -> void:
	HUD.get_node("BombsInStorage").text = "BOMBS:" + str(global.bombs_in_storage)	

# NOTE
# when the progress bar reaches its max value reset to 0 and add a 
# bomb to the storage.
func handle_progress_bar_completion(HUD) -> void:
	if global.progress_bar_value == HUD.get_node("ProgressBar").max_value: 
		global.progress_bar_value = 0
		update_progress_bar(HUD)
		global.bombs_in_storage += 1
		update_bombs_label(HUD)
