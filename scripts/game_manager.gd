extends Node

@export var enemy_scenes: Array[PackedScene]
@export var item_scenes: Array[PackedScene]
@export var max_enemies = 10
@export var spawn_time_min = 1.0
@export var spawn_time_max = 3.0
@export var difficulty_increase_time = 30.0

var current_enemies = 0
var score = 0
var wave = 1
var game_over_status = false
var player = null

signal score_changed(new_score)
signal wave_changed(new_wave)
signal game_over_signal

func _ready():
	# Create a timer to wait for player initialization
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.timeout.connect(_initialize_game)
	add_child(timer)
	timer.start()

	emit_signal("score_changed", score)
	emit_signal("wave_changed", wave)

func _initialize_game():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		$SpawnTimer.wait_time = randf_range(spawn_time_min, spawn_time_max)
		$SpawnTimer.start()
		$DifficultyTimer.wait_time = difficulty_increase_time
		$DifficultyTimer.start()
	else:
		# If player is not ready yet, retry after a short delay
		var timer = Timer.new()
		timer.wait_time = 0.1
		timer.one_shot = true
		timer.timeout.connect(_initialize_game)
		add_child(timer)
		timer.start()

func _on_spawn_timer_timeout():
	if current_enemies < max_enemies and not game_over_status:
		spawn_enemy()
	
	$SpawnTimer.wait_time = randf_range(spawn_time_min, spawn_time_max)
	$SpawnTimer.start()

func spawn_enemy():
	if enemy_scenes.size() == 0:
		return
	
	# 随机选择一个敌人类型
	var enemy_index = randi() % enemy_scenes.size()
	var enemy_scene = enemy_scenes[enemy_index]
	var enemy = enemy_scene.instantiate()
	
	# 在屏幕边缘的随机位置生成敌人
	var viewport_rect = get_viewport().get_visible_rect()
	var spawn_position = Vector2.ZERO
	
	# 决定在哪条边生成
	var side = randi() % 4
	match side:
		0: # 上边
			spawn_position = Vector2(randf_range(0, viewport_rect.size.x), -50)
		1: # 右边
			spawn_position = Vector2(viewport_rect.size.x + 50, randf_range(0, viewport_rect.size.y))
		2: # 下边
			spawn_position = Vector2(randf_range(0, viewport_rect.size.x), viewport_rect.size.y + 50)
		3: # 左边
			spawn_position = Vector2(-50, randf_range(0, viewport_rect.size.y))
	
	# 设置敌人位置并添加到场景
	enemy.global_position = spawn_position
	add_child(enemy)
	
	# 设置玩家为目标
	enemy.activate(player)
	
	# 设置掉落物品
	enemy.drop_scenes = item_scenes
	
	current_enemies += 1
	
	# 连接敌人的tree_exiting信号
	enemy.tree_exiting.connect(_on_enemy_died)

func _on_enemy_died():
	current_enemies -= 1
	score += 10 * wave
	emit_signal("score_changed", score)

func _on_difficulty_timer_timeout():
	wave += 1
	emit_signal("wave_changed", wave)
	
	# 增加游戏难度
	max_enemies += 2
	spawn_time_min = max(0.5, spawn_time_min - 0.1)
	spawn_time_max = max(1.5, spawn_time_max - 0.2)
	
	# 为所有敌人增加属性
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.health += 10
		enemy.speed += 10

func game_over():
	game_over_status = true
	emit_signal("game_over_signal")
	
	# 停止所有计时器
	$SpawnTimer.stop()
	$DifficultyTimer.stop()
	
	# 显示游戏结束UI
	$GameOverUI.visible = true

func restart_game():
	# 重新加载当前场景
	get_tree().reload_current_scene()

func save_highscore():
	var save_data = {
		"highscore": score
	}
	
	var save_file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)
	save_file.close()

func load_highscore():
	if not FileAccess.file_exists("user://highscore.save"):
		return 0
	
	var save_file = FileAccess.open("user://highscore.save", FileAccess.READ)
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	var save_data = json.get_data()
	
	return save_data.highscore if "highscore" in save_data else 0
