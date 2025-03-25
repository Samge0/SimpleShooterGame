extends CharacterBody2D

@export var speed = 200.0
@export var max_health = 100
@export var current_health = 100
@export var bullet_scene: PackedScene

var weapon_type = "basic"
var damage = 10
var fire_rate = 0.3
var can_fire = true

signal health_changed(current_health, max_health)
signal weapon_changed(type)

func _ready():
	emit_signal("health_changed", current_health, max_health)
	emit_signal("weapon_changed", weapon_type)

func _physics_process(delta):
	# 获取移动输入
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	
	# 正规化向量以防止对角线移动过快
	if direction.length() > 0:
		direction = direction.normalized()
	
	# 设置速度
	velocity = direction * speed
	
	# 移动并滑动
	move_and_slide()
	
	# 旋转玩家面向鼠标方向
	look_at(get_global_mouse_position())
	
	# 射击
	if Input.is_action_pressed("shoot") and can_fire:
		shoot()

func shoot():
	if not can_fire or not bullet_scene:
		return
	
	# 创建子弹实例
	var bullet = bullet_scene.instantiate()
	bullet.global_position = $BulletSpawn.global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	bullet.damage = damage
	
	# 添加子弹到场景
	get_tree().current_scene.add_child(bullet)
	
	# 冷却时间
	can_fire = false
	$FireRateTimer.start(fire_rate)

func take_damage(amount):
	current_health -= amount
	emit_signal("health_changed", current_health, max_health)
	
	if current_health <= 0:
		die()

func die():
	# 游戏结束逻辑
	queue_free()

func pickup_item(item_type, value):
	match item_type:
		"health":
			current_health = min(current_health + value, max_health)
			emit_signal("health_changed", current_health, max_health)
		"weapon_pistol":
			weapon_type = "pistol"
			damage = 15
			fire_rate = 0.25
			emit_signal("weapon_changed", weapon_type)
		"weapon_shotgun":
			weapon_type = "shotgun"
			damage = 8
			fire_rate = 0.8
			emit_signal("weapon_changed", weapon_type)
		"weapon_machinegun":
			weapon_type = "machinegun"
			damage = 5
			fire_rate = 0.1
			emit_signal("weapon_changed", weapon_type)

func _on_fire_rate_timer_timeout():
	can_fire = true