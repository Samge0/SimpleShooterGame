extends CanvasLayer

func _ready():
	# 创建一个定时器来等待玩家节点准备就绪
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.timeout.connect(_connect_signals)
	add_child(timer)
	timer.start()
	
	# 隐藏游戏结束菜单
	$GameOverPanel.visible = false

func _connect_signals():
	# 连接玩家信号
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player[0].connect("health_changed", _on_player_health_changed)
		player[0].connect("weapon_changed", _on_player_weapon_changed)
		
		# 连接游戏管理器信号
		var game_manager = get_node_or_null("/root/Main/GameManager")
		if game_manager:
			game_manager.connect("score_changed", _on_score_changed)
			game_manager.connect("wave_changed", _on_wave_changed)
			game_manager.connect("game_over_signal", _on_game_over)
		else:
			print("Warning: GameManager not found, retrying...")
			# 如果还没有找到GameManager，重试
			var timer = Timer.new()
			timer.wait_time = 0.1
			timer.one_shot = true
			timer.timeout.connect(_connect_signals)
			add_child(timer)
			timer.start()
	else:
		# 如果还没有找到玩家，重试
		var timer = Timer.new()
		timer.wait_time = 0.1
		timer.one_shot = true
		timer.timeout.connect(_connect_signals)
		add_child(timer)
		timer.start()

func _on_player_health_changed(current_health, max_health):
	# 更新血条
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health
	$HealthLabel.text = str(current_health) + "/" + str(max_health)

func _on_player_weapon_changed(weapon_type):
	# 更新武器图标和名称
	match weapon_type:
		"basic":
			$WeaponIcon.texture = preload("res://assets/weapons/weapon_basic.svg")
			$WeaponLabel.text = "基础枪"
		"pistol":
			$WeaponIcon.texture = preload("res://assets/weapons/weapon_pistol.svg")
			$WeaponLabel.text = "手枪"
		"shotgun":
			$WeaponIcon.texture = preload("res://assets/weapons/weapon_shotgun.svg")
			$WeaponLabel.text = "霰弹枪"
		"machinegun":
			$WeaponIcon.texture = preload("res://assets/weapons/weapon_machinegun.svg")
			$WeaponLabel.text = "机关枪"

func _on_score_changed(new_score):
	$ScoreLabel.text = "分数: " + str(new_score)

func _on_wave_changed(new_wave):
	$WaveLabel.text = "波次: " + str(new_wave)
	
	# 显示波次过渡动画
	$WaveTransition.text = "第 " + str(new_wave) + " 波"
	$WaveTransition.visible = true
	$WaveTransitionTimer.start()

func _on_wave_transition_timer_timeout():
	$WaveTransition.visible = false

func _on_game_over():
	$GameOverPanel.visible = true
	
	# 获取最高分
	var game_manager = get_node("/root/GameManager")
	var highscore = game_manager.load_highscore()
	var current_score = int($ScoreLabel.text.split(": ")[1])
	
	# 如果当前分数高于最高分，更新最高分
	if current_score > highscore:
		highscore = current_score
		game_manager.save_highscore()
	
	$GameOverPanel/ScoreValue.text = str(current_score)
	$GameOverPanel/HighscoreValue.text = str(highscore)

func _on_restart_button_pressed():
	# 重新开始游戏
	var game_manager = get_node("/root/GameManager")
	game_manager.restart_game()

func _on_quit_button_pressed():
	# 退出游戏
	get_tree().quit()
