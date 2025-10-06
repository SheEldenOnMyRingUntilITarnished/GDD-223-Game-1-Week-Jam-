extends CharacterBody2D

@onready var CoyoteTimer: Timer = $Timers/CoyoteTimer
@onready var JumpBufferTimer: Timer = $Timers/JumpBufferTimer
@onready var MiningTimer: Timer = $Timers/MiningCooldown

var coyote_time_activated: bool = false

const JUMP_HEIGHT: float = -530.0
var gravity: float = 12.0
const MIN_GRAVITY: float = 12.0
const MAX_GRAVITY: float = 22.5

const MAX_SPEED: float = 80.0
const ACCELERATION: float = 8.0
const FRICTION: float = 10.0

signal update_money(value: int)
var value: int = 0

func _process(delta: float) -> void:
		#Pickaxe
	if Input.is_action_pressed("Player_Pickaxe_Left") && MiningTimer.is_stopped():
		Check_Pickaxe($RayCasts/Pickaxe/Pickaxe_Left)
		MiningTimer.start()
		
	else: if Input.is_action_pressed("Player_Pickaxe_Right")&& MiningTimer.is_stopped():
		Check_Pickaxe($RayCasts/Pickaxe/Pickaxe_Right)
		MiningTimer.start()
		
	else: if Input.is_action_pressed("Player_Pickaxe_Up")&& MiningTimer.is_stopped():
		Check_Pickaxe($RayCasts/Pickaxe/Pickaxe_Up)
		MiningTimer.start()
		
	else: if Input.is_action_pressed("Player_Pickaxe_Down")&& MiningTimer.is_stopped():
		Check_Pickaxe($RayCasts/Pickaxe/Pickaxe_Down)
		MiningTimer.start()

func _physics_process(delta: float) -> void:
	var x_input: float = Input.get_action_strength("Player_Right") - Input.get_action_strength("Player_Left")
	var velocity_weight: float = delta * (ACCELERATION if x_input else FRICTION)
	velocity.x = lerp(velocity.x, x_input * MAX_SPEED, velocity_weight)
	
	if is_on_floor():
		coyote_time_activated = false
		gravity = lerp(gravity, MIN_GRAVITY, MIN_GRAVITY * delta)
	else:
		if CoyoteTimer.is_stopped() and !coyote_time_activated:
			CoyoteTimer.start()
			coyote_time_activated = true
	
		if Input.is_action_just_released("Player_Jump") or is_on_ceiling():
			velocity.y *= 0.5
		
		gravity = lerp(gravity, MAX_GRAVITY, MIN_GRAVITY * delta)
	
	if Input.is_action_just_pressed("Player_Jump"):
		if JumpBufferTimer.is_stopped():
			JumpBufferTimer.start()
	
	if !JumpBufferTimer.is_stopped() and (!CoyoteTimer.is_stopped() or is_on_floor()):
		velocity.y = JUMP_HEIGHT
		JumpBufferTimer.stop()
		CoyoteTimer.stop()
		coyote_time_activated = true
	
	if velocity.y < JUMP_HEIGHT/2.0:
		var head_collision: Array = [$RayCasts/Movement/Left_HeadNudge.is_colliding(), $RayCasts/Movement/Left_HeadNudge2.is_colliding(), $RayCasts/Movement/Right_HeadNudge.is_colliding(), $RayCasts/Movement/Right_HeadNudge2.is_colliding()]
		if head_collision.count(true) == 1:
			if head_collision[0]:
				global_position.x += 1.75
			if head_collision[2]:
				global_position.x -= 1.75
	
	if velocity.y > -30 and velocity.y < -5 and abs(velocity.x) > 3:
		if $RayCasts/Movement/Left_LedgeHop.is_colliding() and !$RayCasts/Movement/Left_LedgeHop2.is_colliding() and velocity.x < 0:
			velocity.y += JUMP_HEIGHT/3.25
		if $RayCasts/Movement/Right_LedgeHop.is_colliding() and !$RayCasts/Movement/Right_LedgeHop2.is_colliding() and velocity.x > 0:
			velocity.y += JUMP_HEIGHT/3.25
	
	velocity.y += gravity
	
	move_and_slide()	

func Check_Pickaxe(dir: RayCast2D):
	if dir.is_colliding():
		var block = dir.get_collider()
		if !block.get_script(): return
		
		if block.mineable:
			value += block.value
			update_money.emit(value)
			block.Mined()
	else:
		MiningTimer.stop()
