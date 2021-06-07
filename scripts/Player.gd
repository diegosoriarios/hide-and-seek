extends KinematicBody2D

const speed = 300
var velocity = Vector2(0,0)
var can_hide = false

onready var tween = $Tween

puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_velocity = Vector2()

func _process(delta: float) -> void:
	if is_network_master():
		if visible:
			var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
			var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("top"))
		
			velocity = Vector2(x_input, y_input).normalized()
		
		move_and_slide(velocity * speed)
	else:
		if not tween.is_active():
			move_and_slide(puppet_velocity * speed)
	
	if Input.is_action_just_pressed("hide") and can_hide:
		self.visible = !self.visible

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func _on_NetworkTickRate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position) 
		rset_unreliable("puppet_velocity", velocity)
