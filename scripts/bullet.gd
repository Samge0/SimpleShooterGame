extends Area2D

@export var speed = 600
@export var damage = 10
@export var lifetime = 2.0

var direction = Vector2.RIGHT

func _ready():
	# 设置子弹的旋转
	rotation = direction.angle()
	
	# 设置生存时间
	$LifetimeTimer.wait_time = lifetime
	$LifetimeTimer.start()

func _physics_process(delta):
	# 移动子弹
	position += direction * speed * delta

func _on_body_entered(body):
	# 检查是否击中敌人
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
	# 检查是否击中墙壁或其他障碍物
	elif body.is_in_group("obstacles"):
		queue_free()

func _on_lifetime_timer_timeout():
	queue_free()