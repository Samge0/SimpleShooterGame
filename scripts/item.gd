extends Area2D

@export_enum("health", "weapon_pistol", "weapon_shotgun", "weapon_machinegun") var item_type = "health"
@export var value = 20
@export var animation_speed = 2.0
@export var bob_height = 5.0

var initial_y = 0
var time_passed = 0

func _ready():
	initial_y = position.y

func _process(delta):
	# 使物品上下浮动效果
	time_passed += delta * animation_speed
	position.y = initial_y + sin(time_passed) * bob_height
	
	# 旋转效果
	rotation += delta * 0.5

func _on_body_entered(body):
	if body.has_method("pickup_item"):
		body.pickup_item(item_type, value)
		$AnimationPlayer.play("collect")

func _on_animation_finished():
	if $AnimationPlayer.current_animation == "collect":
		queue_free()