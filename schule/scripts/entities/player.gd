extends Entity

class_name Player

@onready var animation_player := $AnimationPlayer
@onready var hurtbox := $Area2D

var itemUsing: Item

func _ready():
	$AnimatedSprite2D/Hand/Swing.visible = false
	
	_use_item(WoodSword.new())

func _use_item(item: Item):
	itemUsing = item
	$AnimatedSprite2D/Hand.texture = item.texture

func _physics_process(delta: float) -> void:
	var direction_x := Input.get_axis("move_left", "move_right")
	var direction_y := Input.get_axis("move_up", "move_down")
	
	velocity = Vector2(direction_x, direction_y).normalized() * speed * delta
	
	if direction_x == 0 && direction_y == 0:
		$AnimatedSprite2D.play("idle")
	else: 
		$AnimatedSprite2D.play("running")
	
	if $AnimationPlayer.is_playing() == false:
		if get_local_mouse_position().x > 0:
			$AnimatedSprite2D.scale.x = 1
		else:
			$AnimatedSprite2D.scale.x = -1
		
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event.is_action("1"):
		_use_item(WoodPickaxe.new())
	
	if event.is_action("2"):
		_use_item(WoodSword.new())
	
	if event.is_action("hit"):
		itemUsing.on_hit(self)
