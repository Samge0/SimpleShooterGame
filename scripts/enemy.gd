extends CharacterBody2D

@export var speed = 100.0
@export var health = 30
@export var damage = 10
@export var item_drop_chance = 0.3
@export var drop_scenes: Array[PackedScene]

var player = null
var active = false

func _ready():
	add_to_group("enemies")

func _physics_process(delta):
	if not active or not player:
		return
	
	# 向玩家移动
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# 始终面向玩家
	look_at(player.global_position)

func take_damage(amount):
	health -= amount
	
	# 受伤闪烁效果
	modulate = Color(1, 0.3, 0.3)
	$DamageFlashTimer.start()
	
	if health <= 0:
		die()

func _on_damage_flash_timer_timeout():
	modulate = Color(1, 1, 1)

func activate(player_ref):
	player = player_ref
	active = true

func die():
	# 随机掉落物品
	if randf() < item_drop_chance and drop_scenes.size() > 0:
		var random_item = drop_scenes[randi() % drop_scenes.size()]
		var item = random_item.instantiate()
		item.global_position = global_position
		get_tree().current_scene.add_child(item)
	
	# 销毁敌人
	queue_free()

func _on_hit_area_body_entered(body):
	if player == body:
		body.take_damage(damage)
		# 敌人攻击玩家后后退
		var knockback_direction = (global_position - player.global_position).normalized()
		global_position += knockback_direction * 20
