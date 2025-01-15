extends Entity

func _ready() -> void:
	$HitBox.connect("on_damage", onDamage)

func onDamage(damage: int):
	self.damage(damage)
	$AnimationPlayer.play("hit")

func _process(delta: float) -> void:
	pass
