extends CharacterBody2D

@onready var CoyoteTimer: Timer = $Timers/CoyoteTimer
@onready var JumpBufferTimer: Timer = $Timers/JumpBufferTimer
@onready var MiningTimer: Timer = $Timers/MiningCooldown
@onready var GetUpTimer: Timer = $Timers/GetUpTimer

@onready var LightSource: PointLight2D = $AnimatedSprite2D/PointLight2D

var coyote_time_activated: bool = false

const JUMP_HEIGHT: float = -200.0
var gravity: float = 12.0
const MIN_GRAVITY: float = 6.0
const MAX_GRAVITY: float = 22.5

const MAX_SPEED: float = 80.0
const ACCELERATION: float = 8.0
const FRICTION: float = 10.0

signal update_money(value: int)
signal update_camera(size: int)

var value: int = 0
var in_shop: bool = false
var dead: bool = false

#Animation stuff
var falling:bool = false
var large_falling:bool = false
var landed = false

#Pickaxe Upgradable Stats
var mining_speed: float = 0.9
var mining_range: int = 15
var mining_fortune: float = 1.0

#Light Stats
var max_lamp_size: float = 0.15
var lamp_decrease_speed: float = 0.0005

#Camera Stats
var max_camera_size: float = 7

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	Update_Pickaxe_Stats()
	LightSource.scale.x = max_lamp_size
	LightSource.scale.y = max_lamp_size
	
	large_falling = false
	falling = false
	landed = true
	
	dead = false
	
	update_camera.emit(max_camera_size)
	
	GetUpTimer.start(5)


func _process(delta: float) -> void:
	
	if !LightSource.scale.x < 0.000001 && !LightSource.scale.y < 0.000001 && !in_shop && !dead:
		LightSource.scale.x -= lamp_decrease_speed * delta
		LightSource.scale.y -= lamp_decrease_speed * delta
	else:
		if dead:
			get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")
		if !dead && !in_shop:
			$"../AnimationPlayer".play("Fade_To_Black")
			dead = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		LightSource.scale.x = max_lamp_size
		LightSource.scale.y = max_lamp_size
	
	if Input.is_action_just_pressed("Player_Interact"):
		if in_shop:
			in_shop = false
		else:
			in_shop = true
	
		#Pickaxe
	if Input.is_action_pressed("Player_Pickaxe_Left") && MiningTimer.is_stopped():
		Check_Pickaxe($RayCasts/Pickaxe/Pickaxe_Left, -mining_range,0)
		
		MiningTimer.start()
		
	else: if Input.is_action_pressed("Player_Pickaxe_Right")&& MiningTimer.is_stopped():
		Check_Pickaxe($RayCasts/Pickaxe/Pickaxe_Right, mining_range, 0)
		
		MiningTimer.start()
		
	else: if Input.is_action_pressed("Player_Pickaxe_Up")&& MiningTimer.is_stopped():
		Check_Pickaxe($RayCasts/Pickaxe/Pickaxe_Up, 0, -mining_range)
		
		MiningTimer.start()
		
	else: if Input.is_action_pressed("Player_Pickaxe_Down")&& MiningTimer.is_stopped():
		Check_Pickaxe($RayCasts/Pickaxe/Pickaxe_Down, 0, mining_range)
		
		MiningTimer.start()

func _physics_process(delta: float) -> void:
	if !dead && !in_shop:
		Movement(delta)

func Movement(delta: float) -> void:
	var x_input: float = Input.get_action_strength("Player_Right") - Input.get_action_strength("Player_Left")
	var velocity_weight: float = delta * (ACCELERATION if x_input else FRICTION)
	if is_on_floor() && !landed:
		velocity.x = lerp(velocity.x, x_input * MAX_SPEED, velocity_weight)
		
		if x_input > 0:
			$AnimatedSprite2D.scale.x = 1
			if !falling:
				$AnimatedSprite2D.play("Move") 
			
		else: if x_input < 0:
			$AnimatedSprite2D.scale.x = -1
			if !falling:
				$AnimatedSprite2D.play("Move") 
			
		else:
			$AnimatedSprite2D.play("Idle")
	
	if is_on_floor():
		if large_falling == false:
			velocity.x = 0
			$AnimatedSprite2D.play("Land")
			large_falling = false
			falling = false
			landed = true
			GetUpTimer.start(5)
		
		if falling:
			velocity.x = 0
			$AnimatedSprite2D.play("Land")
			falling = false
			landed = true
			GetUpTimer.start(1)
		
		coyote_time_activated = false
		gravity = lerp(gravity, MIN_GRAVITY, MIN_GRAVITY * delta)
	else:
		if CoyoteTimer.is_stopped() and !coyote_time_activated:
			CoyoteTimer.start()
			coyote_time_activated = true
	
		if Input.is_action_just_released("Player_Jump") or is_on_ceiling():
			velocity.y *= 0.5
		gravity = lerp(gravity, MAX_GRAVITY, MIN_GRAVITY * delta)
		#print(gravity)
		if gravity >= 22 && falling:
			$AnimatedSprite2D.play("Large_Fall")
			large_falling = true
		else: if gravity > 17 && !falling:
			falling = true
		else: if !falling:
			$AnimatedSprite2D.play("Fall")
	
	if Input.is_action_just_pressed("Player_Jump") && !landed:
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

func Check_Pickaxe(dir: RayCast2D, x: int, y: int):
	
	dir.target_position = Vector2(x,y)
	
	if dir.is_colliding():
		var block = dir.get_collider()
		if block.get_script() && block.is_class("StaticBody2D"):
			if block.mineable:
				value += round(block.value * mining_fortune)
				update_money.emit(value)
				block.Mined()

func Update_Pickaxe_Stats():
	MiningTimer.wait_time = mining_speed


func _on_get_up_timer_timeout() -> void:
	landed = false
