extends Node2D

var sequence_times = [4,6,8]
var right_sequences = []
var light_up_anim_done = false

# Called when the node enters the scene tree for the first time.
func _ready():
	await create_first_sequence()
	light_up_sequence()

func create_first_sequence():
	for i in range(sequence_times[0]):
		var rng = randi_range(1,12)
		if not right_sequences.has(rng):
			right_sequences.append(rng)
		else:
			var new_rng = reroll_till_different(rng)
			right_sequences.append(new_rng)

func create_second_sequence():
	for i in range(sequence_times[1]):
		var rng = randi_range(1,12)
		if not right_sequences.has(rng):
			right_sequences.append(rng)
		else:
			var new_rng = reroll_till_different(rng)
			right_sequences.append(new_rng)
	light_up_sequence()

func create_third_sequence():
	for i in range(sequence_times[2]):
		var rng = randi_range(1,12)
		if not right_sequences.has(rng):
			right_sequences.append(rng)
		else:
			var new_rng = reroll_till_different(rng)
			right_sequences.append(new_rng)
	light_up_sequence()

func reroll_till_different(rng):
	var new_rng = randi_range(1,12)
	if new_rng == rng:
		reroll_till_different(rng)
	else:
		return new_rng

func light_up_sequence():
	light_up_anim_done = false
	reset_to_green()
	var tween = get_tree().create_tween()
	for i in right_sequences:
		tween.tween_property(get_node("%B"+str(i)).get_child(0),"energy",16,0.5)
		tween.chain().tween_property(get_node("%B"+str(i)).get_child(0),"energy",0,0.5)
	await tween.finished
	light_up_anim_done = true

func reset_to_green():
	for i in $ButtonGroup.get_children():
		i.get_child(0).color = Color(0,255,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var sequence_round = 1
var sequence_index = 0
func _on_button_puzzle_down(button_id):
	if light_up_anim_done:
		if right_sequences[sequence_index] == button_id:
			print("right: ",button_id)
			await correct_light_green(button_id)
			if sequence_round == 1 && sequence_index == 4:
				sequence_index = 0
				right_sequences = []
				sequence_round += 1
				await sequence_done_light_up_all()
				create_second_sequence()
			if sequence_round == 2 && sequence_index == 6:
				sequence_index = 0
				right_sequences = []
				sequence_round += 1
				await sequence_done_light_up_all()
				create_third_sequence()
			if sequence_round == 3 && sequence_index == 8:
				await sequence_done_light_up_all()
				%Panel.visible = true
		else:
			print("wrong!, resetting: ",button_id)
			await wrong_light_red(button_id)
			sequence_index = 0
			light_up_sequence()

func correct_light_green(button_id):
	var btn_light = get_node("%B"+str(button_id)).get_child(0)
	btn_light.color = Color(0,255,0)
	var tween = get_tree().create_tween()
	light_up_anim_done = false
	tween.tween_property(btn_light,"energy",16,0.5)
	tween.chain().tween_property(btn_light,"energy",0,0.5)
	sequence_index += 1
	await tween.finished
	light_up_anim_done = true
	return

func wrong_light_red(button_id):
	var btn_light = get_node("%B"+str(button_id)).get_child(0)
	btn_light.color = Color(255,0,0)
	var tween = get_tree().create_tween()
	light_up_anim_done = false
	tween.tween_property(btn_light,"energy",16,0.5)
	tween.chain().tween_property(btn_light,"energy",0,0.5)
	await tween.finished
	light_up_anim_done = true
	return

func sequence_done_light_up_all():
	for i in $ButtonGroup.get_children():
		i.get_child(0).color = Color(0,255,0)
		var tween = get_tree().create_tween().parallel()
		tween.tween_property(i.get_child(0),"energy",16,0.5)
		tween.chain().tween_property(i.get_child(0),"energy",0,0.5)
	return
