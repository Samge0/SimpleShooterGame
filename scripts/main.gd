extends Node2D

@export var player_scene: PackedScene
@export var bullet_scene: PackedScene
@export var enemy_scenes: Array[PackedScene]
@export var item_scenes: Array[PackedScene]

func _ready():
	# 创建玩家
	var player = player_scene.instantiate()
	player.global_position = Vector2(640, 360)  # 屏幕中心位置
	player.bullet_scene = bullet_scene
	player.add_to_group("player")
	add_child(player)
	
	# 设置游戏管理器
	var game_manager = $GameManager
	game_manager.enemy_scenes = enemy_scenes
	game_manager.item_scenes = item_scenes

func _process(delta):
	# 退出游戏
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
