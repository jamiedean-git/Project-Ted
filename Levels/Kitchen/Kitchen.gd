extends Node2D

var final_score = 0
var bone_score = 0
var stop_animation = false

const NUM_BONES = 15
const TIME_LIMIT = 90

onready var BoneCountLabel = get_node("CanvasLayer/Interface/BoneCounter/Node/Label")
onready var ClockLabel = get_node("CanvasLayer/Interface/Clock/ClockLabel")
onready var EndText = get_node("CanvasLayer/Interface/EndText")
onready var FinalScore = get_node("CanvasLayer/Interface/FinalScore")
onready var FinalScoreLabel = get_node("CanvasLayer/Interface/FinalScore/FinalScoreLabel")
onready var PauseScreen = get_node("CanvasLayer/Interface/PauseScreen")

func _ready():
	BoneCountLabel.set_num_bones(NUM_BONES)
	ClockLabel.set_clock_time(TIME_LIMIT)

func _on_Bone_bone_collected() -> void:
	bone_score += 1
	# make setter
	BoneCountLabel.text = ' '+str(bone_score)+"/"+str(NUM_BONES)
	if bone_score == NUM_BONES:
		var time_remaining = ClockLabel.get_clock_time()
		game_over(bone_score, time_remaining)

func _on_Ted_pause_game() -> void:
	get_tree().paused = true
	PauseScreen.handle_pause()

func _on_Interface_unpause_external() -> void:
	get_tree().paused = false
	PauseScreen.set_visible(false)
	#get_tree().reload_current_scene() #debug. take out

func _on_Interface_time_out_external() -> void:
	game_over(bone_score, 0) #hm

func game_over(bone, time):
	get_tree().paused = true
	var end_text = "STAGE CLEAR" if (time > 0) else "TIME OUT"
	EndText.set_text(end_text)
	EndText.set_visible(true)
	FinalScoreLabel.update_text(bone, time)
	FinalScore.set_visible(true)
