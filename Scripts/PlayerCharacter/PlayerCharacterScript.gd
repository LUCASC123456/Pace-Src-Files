extends CharacterBody3D

#class name
class_name PlayerCharacter

#states variables
enum states
{
	IDLE, WALK, RUN, CROUCH, SLIDE, JUMP, INAIR, ONWALL, DASH, GRAPPLE
}
var currentState 

#move variables
@export_group("move variables")
var moveSpeed : float
var velocityFinal
var velocityInitial
var desiredMoveSpeed : float
@export var desiredMoveSpeedCurve : Curve
@export var maxSpeed : float 
@export var walkSpeed : float
@export var runSpeed : float
@export var crouchSpeed : float
var slideSpeed : float
@export var slideSpeedAddon : float 
@export var dashSpeed : float 
var moveAcceleration : float
@export var walkAcceleration : float
@export var runAcceleration : float 
@export var crouchAcceleration : float 
var moveDecceleration : float
@export var walkDecceleration : float
@export var runDecceleration : float 
@export var crouchDecceleration : float 
@export var inAirMoveSpeedCurve : Curve

#movement variables
@export_group("movement variables")
var inputDirection : Vector2 
var moveDirection : Vector3 
@export var hitGroundCooldown : float #amount of time the character keep his accumulated speed before losing it (while being on ground)
var hitGroundCooldownRef : float 
var lastFramePosition : Vector3 
var floorAngle #angle of the floor the character is on 
var slopeAngle #angle of the slope the character is on
var canInput : bool 
var collisionInfo
var wasOnFloor : bool

#jump variables
@export_group("jump variables")
@export var jumpHeight : float
@export var jumpTimeToPeak : float
@export var jumpTimeToFall : float
@onready var jumpVelocity : float = (2.0 * jumpHeight) / jumpTimeToPeak
@export var jumpCooldown : float
var jumpCooldownRef : float 
@export var nbJumpsInAirAllowed : int 
var nbJumpsInAirAllowedRef : int 
var canCoyoteJump : bool = true
@export var coyoteJumpCooldown : float
var coyoteJumpCooldownRef : float
var coyoteJumpOn : bool = false
var jumpBuffOn : bool = false

#slide variables
@export_group("slide variables")
@export var slideTime : float
@export var slideTimeRef : float 
var slideVector : Vector2 = Vector2.ZERO #slide direction
var startSlideInAir : bool
@export var timeBeforeCanSlideAgain : float
var timeBeforeCanSlideAgainRef : float 
@export var maxSlopeAngle : float #max angle value where the side time duration is applied

#wall run variables
@export_group("wall run variables")
@export var wallJumpVelocity : float 
var canWallRun : bool

#dash variables
@export_group("dash variables")
@export var dashTime : float
var dashTimeRef : float
@export var nbDashAllowed : int
var nbDashAllowedRef : int
@export var timeBeforeCanDashAgain : float = 0.2
var timeBeforeCanDashAgainRef : float = 0.2
@export var timeBefReloadDash : float
var timeBefReloadDashRef : float
var velocityPreDash : Vector3 

#grapple hook variables
@export_group("grapple hook variables")
var grapHookType : Array[String] = ["Pull", "Swing"]
@export var grapHookMaxDist : float
@export var grapHookSpeed : float
@export var grapHookAccel : float
var anchorPoint : Vector3
@export var distToStopGrappleOnFloor : float
@export var distToStopGrappleIAir : float
@export var timeBeforeCanGrappleAgain : float
var timeBeforeCanGrappleAgainRef : float
@export var grappleLaunchJumpVelocity : float
@export var downDirJump : bool #enable if the character can jump while grappling downhill

#gravity variables
@export_group("gravity variables")
@onready var jumpGravity : float = (-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)
@onready var fallGravity : float = (-2.0 * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)
@export var wallGravityMultiplier : float

#collision variables
@export_group("collision variables")
@export var health : int
@onready var remainingHealth : int = health
@onready var canWallDamage : bool = true
@onready var canFloorDamage : bool = true
@onready var canCeilingDamage : bool = true
@export var mass : int
var momentum : Vector3
var force : Vector3
var collisionRadius : Vector3
var torque : Vector3
const damageThresholdMomentum = 4000

#references variables
@onready var cameraHolder = $CameraHolder
@onready var standHitbox = $standingHitbox
@onready var crouchHitbox = $crouchingHitbox
@onready var ceilingCheck = $Raycasts/CeilingCheck
@onready var floorCheck = $Raycasts/FloorCheck
@onready var grappleHookCheck = $CameraHolder/Camera3D/GrappleHookCheck
@onready var grapHookRope = $CameraHolder/Camera3D/GrappleHookRope
@onready var mesh = $MeshInstance3D
@onready var hud = $HUD
@onready var pauseMenu = $PauseMenu
@onready var winMenu = $"../../Camera/Camera3D/WinMenuScreen"

func _ready():
	#set the start move speed
	moveSpeed = walkSpeed
	moveAcceleration = walkAcceleration
	moveDecceleration = walkDecceleration
	
	#set the values refenrencials for the needed variables
	desiredMoveSpeed = moveSpeed 
	jumpCooldownRef = jumpCooldown
	nbJumpsInAirAllowedRef = nbJumpsInAirAllowed
	hitGroundCooldownRef = hitGroundCooldown
	coyoteJumpCooldownRef = coyoteJumpCooldown
	slideTimeRef = slideTime
	dashTimeRef = dashTime
	nbDashAllowedRef = nbDashAllowed
	timeBeforeCanSlideAgainRef = timeBeforeCanSlideAgain
	timeBeforeCanDashAgainRef = timeBeforeCanDashAgain
	timeBefReloadDashRef = timeBefReloadDash
	timeBeforeCanGrappleAgainRef = timeBeforeCanGrappleAgain
	canWallRun = false
	canInput = true
	
	#disable the crouch hitbox, enable is standing one
	if !crouchHitbox.disabled: 
		crouchHitbox.disabled = true 
	else:
		pass
		
	if standHitbox.disabled: 
		standHitbox.disabled = false
	else:
		pass
	
	#set the raycasts
	if !ceilingCheck.enabled: 
		ceilingCheck.enabled = true
	else:
		pass
		
	if !floorCheck.enabled: 
		floorCheck.enabled = true
	else:
		pass
		
	if !grappleHookCheck.enabled: 
		grappleHookCheck.enabled = true
	else:
		pass
	
	grappleHookCheck.target_position = Vector3(-grapHookMaxDist, 0.0, 0.0) #grapHookMaxDist
	if grapHookRope.visible: 
		grapHookRope.visible = false
	else:
		pass
	
	#set the mesh scale of the character
	mesh.scale = Vector3(1.0, 1.0, 1.0)

func _process(_delta):
	#the behaviours that is preferable to check every "visual" frame
	
	if !pauseMenu.pauseMenuEnabled:
		inputManagement()
		
		displayStats()
	else:
		pass
	
func _physics_process(delta):
	#the behaviours that is preferable to check every "physics" frame
	
	applies(delta)
	
	move(delta)
	
	grappleHookManagement(delta)
	
	collisionHandling(delta)
	
	move_and_slide()

func inputManagement():
	#for each state, check the possibles actions available
	#This allow to have a good control of the controller behaviour, because you can easely check the actions possibls, 
	#add or remove some, and it prevent certain actions from being played when they shouldn't be
	
	if canInput:
		match currentState:
			states.IDLE:
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
				else:
					pass
				
				if Input.is_action_just_pressed("crouch | slide"):
					crouchStateChanges()
				else:
					pass
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
				else:
					pass
					
			states.WALK:
				if Input.is_action_just_pressed("run"):
					runStateChanges()
				else:
					pass
					
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
				else:
					pass
				
				if Input.is_action_just_pressed("crouch | slide"):
					crouchStateChanges()
				else:
					pass
				
				if Input.is_action_just_pressed("dash"):
					dashStateChanges()
				else:
					pass
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
				else:
					pass
					
			states.RUN:
				if Input.is_action_just_pressed("run"):
					walkStateChanges()
				else:
					pass
				
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
				else:
					pass
					
				if Input.is_action_just_pressed("crouch | slide"):
					slideStateChanges()
				else:
					pass
				
				if Input.is_action_just_pressed("dash"):
					dashStateChanges()
				else:
					pass
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
				else:
					pass
					
			states.CROUCH: 
				if Input.is_action_just_pressed("run") and !ceilingCheck.is_colliding():
					walkStateChanges()
				else:
					pass
				
				if Input.is_action_just_pressed("crouch | slide") and !ceilingCheck.is_colliding(): 
					walkStateChanges()
				else:
					pass
					
			states.SLIDE: 
				if Input.is_action_just_pressed("run"):
					slideStateChanges()
				else:
					pass
				
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
				else:
					pass
				
				if Input.is_action_just_pressed("crouch | slide"):
					slideStateChanges()
				else:
					pass
					
			states.JUMP:
				if Input.is_action_just_pressed("crouch | slide"):
					slideStateChanges()
				else:
					pass
					
				if Input.is_action_just_pressed("dash"):
					dashStateChanges()
				else:
					pass
					
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
				else:
					pass
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
				else:
					pass
					
			states.INAIR: 
				if Input.is_action_just_pressed("crouch | slide"):
					slideStateChanges()
				else:
					pass
					
				if Input.is_action_just_pressed("dash"):
					dashStateChanges()
				else:
					pass
					
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
					jumpBuffering()
				else:
					pass
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
				else:
					pass
					
			states.ONWALL:
				if Input.is_action_just_pressed("jump"):
					jump(0.0, false)
				else:
					pass
					
			states.DASH:
				pass 
				
			states.GRAPPLE:
				if Input.is_action_just_pressed("jump"):
					jump(grapHookSpeed/3, true)
				else:
					pass
					
				if Input.is_action_just_pressed("grappleHook"):
					grappleStateChanges()
				else:
					pass
					
func displayStats():
	#call the functions in charge of displaying the controller properties
	hud.displayVelocity(velocity.length())
	
	#not a property, but a visual
	if currentState == states.DASH: 
		hud.displaySpeedLines(dashTime)
	else:
		pass
	
func applies(delta):
	#general appliements
	
	floorAngle = get_floor_normal() #get the angle of the floor
	
	if !is_on_floor():
		#modify the type of gravity to apply to the character, depending of his velocity (when jumping jump gravity, otherwise fall gravity)
		if velocity.y >= 0.0:
			if currentState != states.GRAPPLE: 
				velocity.y += jumpGravity * delta
			else:
				pass
				
			if currentState != states.SLIDE and currentState != states.DASH and currentState != states.GRAPPLE: 
				currentState = states.JUMP
			else:
				pass
		else: 
			if currentState != states.GRAPPLE: 
				velocity.y += fallGravity * delta
			else:
				pass
				
			if currentState != states.SLIDE and currentState != states.DASH and currentState != states.GRAPPLE: 
				currentState = states.INAIR 
			else:
				pass
			
		if currentState == states.SLIDE:
			if !startSlideInAir: 
				slideTime = -1 #if the character start slide on the grund, and the jump, the slide is canceled
			else:
				pass
		else:
			pass
				
		if currentState == states.DASH: 
			velocity.y = 0.0 #set the y axis velocity to 0, to allow the character to not be affected by gravity while dashing
		else:
			pass
		
		if hitGroundCooldown != hitGroundCooldownRef: 
			hitGroundCooldown = hitGroundCooldownRef #reset the before bunny hopping value
		else:
			pass
		
		if coyoteJumpCooldown > 0.0: 
			coyoteJumpCooldown -= delta
		else:
			pass
	else:
		pass
		
	if is_on_floor():
		slopeAngle = rad_to_deg(acos(floorAngle.dot(Vector3.UP))) #get the angle of the slope 
		
		if currentState == states.SLIDE and startSlideInAir: 
			startSlideInAir = false
		else:
			pass
		
		if jumpBuffOn: 
			jumpBuffOn = false
			jump(0.0, false)
		else:
			pass
			
		if hitGroundCooldown >= 0: 
			hitGroundCooldown -= delta #disincremente the value each frame, when it's <= 0, the player lose the speed he accumulated while being in the air 
		else:
			pass
		
		if nbJumpsInAirAllowed != nbJumpsInAirAllowedRef: 
			nbJumpsInAirAllowed = nbJumpsInAirAllowedRef #set the number of jumps possible
		else:
			pass
		
		if coyoteJumpCooldown != coyoteJumpCooldownRef: 
			coyoteJumpCooldown = coyoteJumpCooldownRef
		else:
			pass
		
		#set the move state depending on the move speed, only when the character is moving
		
		#not the best piece of code i made, but i didn't really saw a more efficient way
		if inputDirection != Vector2.ZERO and moveDirection != Vector3.ZERO:
			match moveSpeed:
				crouchSpeed: currentState = states.CROUCH 
				walkSpeed: currentState = states.WALK
				runSpeed: currentState = states.RUN 
				slideSpeed: currentState = states.SLIDE 
				dashSpeed: currentState = states.DASH 
				grapHookSpeed: moveSpeed = runSpeed
		else:
			#set the state to idle
			if currentState == states.JUMP or currentState == states.INAIR or currentState == states.WALK or currentState == states.RUN: 
				if velocity.length() < 1.0: 
					currentState = states.IDLE
				else:
					pass
			else:
				pass
	else:
		pass
					
	if is_on_wall(): #if the character is on a wall
		#set the state on onwall
		wallrunStateChanges()
	else:
		pass
		
	if is_on_floor() or !is_on_floor():
		#manage the slide behaviour
		if currentState == states.SLIDE:
			#if character slide on an uphill, cancel slide
			
			#there is a bug here related to the uphill/downhill slide 
			#(simply said, i have to adjust manually the lastFramePosition value in order to make the character slide indefinitely downhill bot not uphill)
			#if you know how to resolve that issue, don't hesitate to make a post about it on the discussions tab of the project's Github repository
			
			if !startSlideInAir and lastFramePosition.y+0.1 < position.y: #don't know why i need to add a +0.1 to lastFramePosition.y, otherwise it breaks the mechanic some times
				slideTime = -1 
			else:
				pass
				
			if !startSlideInAir and slopeAngle < maxSlopeAngle:
				if slideTime > 0: 
					slideTime -= delta
				else:
					pass
			else:
				pass
				
			if slideTime <= 0: 
				timeBeforeCanSlideAgain = timeBeforeCanSlideAgainRef
				#go to crouch state if the ceiling is too low, otherwise go to run state 
				if ceilingCheck.is_colliding(): 
					crouchStateChanges()
				else: 
					runStateChanges()
			else:
				pass
		else:
			pass
				
		#manage the dash behaviour
		if currentState == states.DASH:
			if canInput: 
				canInput = false #the character cannot change direction while dashing 
			else:
				pass
			
			if dashTime > 0: 
				dashTime -= delta
			else:
				pass
			
			#the character cannot dash anymore, change to corresponding variables, and go back to run state
			if dashTime <= 0: 
				velocity = velocityPreDash #go back to pre dash velocity
				canInput = true 
				timeBeforeCanDashAgain = timeBeforeCanDashAgainRef
				runStateChanges()
			else:
				pass
				
		if timeBeforeCanSlideAgain > 0.0: 
			timeBeforeCanSlideAgain -= delta 
		else:
			pass
		
		if timeBeforeCanDashAgain > 0.0: 
			timeBeforeCanDashAgain -= delta
		else:
			pass
		
		#manage the dash reloading
		if timeBefReloadDash > 0.0 and nbDashAllowed != nbDashAllowedRef: 
			timeBefReloadDash -= delta
		else:
			pass
			
		if timeBefReloadDash <= 0.0 and nbDashAllowed != nbDashAllowedRef:
			timeBefReloadDash = timeBefReloadDashRef
			nbDashAllowed += 1
		else:
			pass
			
		if timeBeforeCanGrappleAgain > 0.0: 
			timeBeforeCanGrappleAgain -= delta
		else:
			pass
		
		if currentState == states.JUMP: 
			floor_snap_length = 0.0 #the character cannot stick to structures while jumping
		else:
			pass
			
		if currentState == states.INAIR: 
			floor_snap_length = 2.5 #but he can if he stopped jumping, but he's still in the air
		else:
			pass
		
		if jumpCooldown > 0.0: 
			jumpCooldown -= delta
		else:
			pass
	else:
		pass
	
	winMenu.timeTaken += delta
		
func move(delta):
	#direction input
	inputDirection = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	
	#get direction input when sliding
	if currentState == states.SLIDE:
		if moveDirection == Vector3.ZERO: #if the character is moving
			moveDirection = (cameraHolder.basis * Vector3(slideVector.x, 0.0, slideVector.y)).normalized() #get move direction at the start of the slide, and stick to it
		else:
			pass
	
	#get direction input when wall running
	elif currentState == states.ONWALL:
		moveDirection = velocity.normalized() #get character current velocity and apply it as the current move direction, and stick to it
		
	#dash
	elif currentState == states.DASH:
		if moveDirection == Vector3.ZERO: #if the character is moving
			moveDirection = (cameraHolder.basis * Vector3(inputDirection.x, 0.0, inputDirection.y)).normalized() #get move direction at the start of the dash, and stick to it
		else:
			pass
			
	#all others 
	else:
		#get the move direction depending on the input
		moveDirection = (cameraHolder.basis * Vector3(inputDirection.x, 0.0, inputDirection.y)).normalized()
		
	#move applies when the character is on the floor
	if is_on_floor():
		#if the character is moving
		if moveDirection:
			#apply slide move
			if currentState == states.SLIDE:
				if slopeAngle > maxSlopeAngle: 
					desiredMoveSpeed += 3.0 * delta #increase more significantly desired move speed if the slope is steep enough
				else: 
					desiredMoveSpeed += 2.0 * delta
				
				velocity.x = moveDirection.x * desiredMoveSpeed
				velocity.z = moveDirection.z * desiredMoveSpeed
				
			#apply dash move
			elif currentState == states.DASH:
				velocity.x = moveDirection.x * dashSpeed
				velocity.z = moveDirection.z * dashSpeed 
				
			#apply grapple hook desired move speed incrementation
			elif currentState == states.GRAPPLE:
				if desiredMoveSpeed < maxSpeed: 
					desiredMoveSpeed += grapHookSpeed * delta
				else:
					pass
					
			#apply smooth move when walking, crouching, running
			else:
				velocity.x = lerp(velocity.x, moveDirection.x * moveSpeed, moveAcceleration * delta)
				velocity.z = lerp(velocity.z, moveDirection.z * moveSpeed, moveAcceleration * delta)
				
				#cancel desired move speed accumulation if the timer is out
				if hitGroundCooldown <= 0: 
					desiredMoveSpeed = velocity.length()
				else:
					pass
					
		#if the character is not moving
		else:
			#apply smooth stop 
			velocity.x = lerp(velocity.x, 0.0, moveDecceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, moveDecceleration * delta)
			
			#cancel desired move speed accumulation
			desiredMoveSpeed = velocity.length()
	else:
		pass
			
	#move applies when the character is not on the floor (so if he's in the air)
	if !is_on_floor():
		if moveDirection:
			#apply dash move
			if currentState == states.DASH: 
				velocity.x = moveDirection.x * dashSpeed
				velocity.z = moveDirection.z * dashSpeed 
				
			#apply slide move
			elif currentState == states.SLIDE:
				desiredMoveSpeed += 2.5 * delta
				
				velocity.x = moveDirection.x * desiredMoveSpeed
				velocity.z = moveDirection.z * desiredMoveSpeed
				
			#apply grapple hook desired move speed incrementation
			elif currentState == states.GRAPPLE:
					if desiredMoveSpeed < maxSpeed: 
						desiredMoveSpeed += grapHookSpeed * delta
					else:
						pass
					
			#apply smooth move when in the air (air control)
			else:
				if desiredMoveSpeed < maxSpeed: 
					desiredMoveSpeed += 1.5 * delta
				else:
					pass
				
				#here, set the air control amount depending on a custom curve, to select it with precision, depending on the desired move speed
				var contrdDesMoveSpeed : float = desiredMoveSpeedCurve.sample(desiredMoveSpeed/100)
				var contrdInAirMoveSpeed : float = inAirMoveSpeedCurve.sample(desiredMoveSpeed)
			
				velocity.x = lerp(velocity.x, moveDirection.x * contrdDesMoveSpeed, contrdInAirMoveSpeed * delta)
				velocity.z = lerp(velocity.z, moveDirection.z * contrdDesMoveSpeed, contrdInAirMoveSpeed * delta)
				
		else:
			#accumulate desired speed for bunny hopping
			desiredMoveSpeed = velocity.length()
	else:
		pass
			
	#move applies when the character is on the wall
	if is_on_wall():
		#apply on wall move
		if currentState == states.ONWALL:
			if moveDirection:
				desiredMoveSpeed += 1.0 * delta 
				
				velocity.x = moveDirection.x * desiredMoveSpeed
				velocity.z = moveDirection.z * desiredMoveSpeed
			else:
				pass
		else:
			pass
	else:
		pass
				
	if desiredMoveSpeed >= maxSpeed: 
		desiredMoveSpeed = maxSpeed #set to ensure the character don't exceed the max speed authorized
	else:
		pass
	
	lastFramePosition = position
	wasOnFloor = !is_on_floor()
	
	if !velocityInitial:
		velocityInitial = abs(velocity.length())
	else:
		velocityFinal = abs(velocity.length())
		winMenu.distanceTravelled += delta*(velocityFinal+velocityInitial)/2
		velocityInitial = velocityFinal
			
func jump(jumpBoostValue : float, isJumpBoost : bool): 
	#this function manage the jump behaviour, depending of the different variables and states the character is
	
	var canJump : bool = false #jump condition
	
	#the jump can only be applied if the player character is pulled up
	if currentState == states.GRAPPLE and lastFramePosition.y > position.y and !downDirJump:
		if jumpBoostValue != 0.0: 
			jumpBoostValue = 0.0
		else:
			pass
			
		if isJumpBoost: 
			isJumpBoost = false
		else:
			pass
			
		grappleStateChanges()
		return 
	else:
		pass
		
	#on wall jump 
	if is_on_wall() and canWallRun: 
		currentState = states.JUMP
		velocity = get_wall_normal() * wallJumpVelocity #add some knockback in the opposite direction of the wall
		velocity.y = jumpVelocity
		jumpCooldown = jumpCooldownRef
	else:
		#in air jump
		if !is_on_floor():
			if jumpCooldown <= 0:
				#determine if the character are in the conditions for enable coyote jump
				if wasOnFloor and coyoteJumpCooldown > 0.0 and lastFramePosition.y > position.y: 
					coyoteJumpOn = true
				else:
					pass
				
				#if the character jump from a jumppad, the jump isn't taken into account in the max numbers of jumps allowed, allowing the character to continusly jump as long as it lands on a jumppad
				if (nbJumpsInAirAllowed > 0) or (nbJumpsInAirAllowed <= 0 and isJumpBoost) or (coyoteJumpOn): #also, take into account if the character is coyote jumping
					if !isJumpBoost and !coyoteJumpOn: 
						nbJumpsInAirAllowed -= 1
					else:
						pass
						
					jumpCooldown = jumpCooldownRef
					coyoteJumpOn = false
					canJump = true 
				else:
					pass
			else:
				pass
				
		#on floor jump
		else:
			jumpCooldown = jumpCooldownRef
			canJump = true 
			
	#apply jump
	if canJump:
		if isJumpBoost: 
			nbJumpsInAirAllowed = nbJumpsInAirAllowedRef
		else:
			pass
			
		currentState = states.JUMP
		velocity.y = jumpVelocity + jumpBoostValue #apply directly jump velocity to y axis velocity, to give the character instant vertical forcez
		canJump = false 
	else:
		pass
		
func jumpBuffering():
	#if the character is falling, and the floor check raycast is colliding and the jump properties are good, enable jump buffering
	if floorCheck.is_colliding() and lastFramePosition.y > position.y and nbJumpsInAirAllowed <= 0 and jumpCooldown <= 0.0: 
		jumpBuffOn = true
	else:
		pass
	
func grappleHookManagement(delta : float):
	var distToAnchorPoint : float #distance entre le personnae et le point d'ancrage du grappin
	
	grappleHookMove(delta, distToAnchorPoint)
	
	grappleHookRopeManagement(distToAnchorPoint)
	
func grappleHookMove(delta : float, distToAnchorPoint : float):
	if currentState == states.GRAPPLE:
		moveDirection = global_position.direction_to(anchorPoint) #direction to move on
		distToAnchorPoint = global_position.distance_to(anchorPoint) #distance from anchor point to character
		if moveDirection:
			#apply grapple hook move
			if is_on_floor():
				if distToAnchorPoint > distToStopGrappleIAir: 
					velocity = lerp(velocity, moveDirection * grapHookSpeed, grapHookAccel * delta)
				else: 
					grappleStateChanges()
			else:
				pass
			if !is_on_floor():
				if distToAnchorPoint > distToStopGrappleOnFloor: 
					velocity = lerp(velocity, moveDirection * grapHookSpeed, grapHookAccel * delta)
				else: 
					grappleStateChanges()
			else:
				pass
		else:
			pass
	else:
		pass
		
func grappleHookRopeManagement(distToAnchorPoint : float):
	#hide the rope
	if currentState != states.GRAPPLE:
		if grapHookRope.visible: 
			grapHookRope.visible = false
		else:
			pass
			
		return
		
	else:
		#show the rope at the corresponding point and direction
		if !grapHookRope.visible: 
			grapHookRope.visible = true
		else:
			pass
			
		grapHookRope.look_at(anchorPoint)
		distToAnchorPoint = global_position.distance_to(anchorPoint)
		grapHookRope.scale = Vector3(0.07, 0.18, distToAnchorPoint) #change the scale to make the rope take all the direction width
		
		
#theses functions manages the differents changes and appliments the character will go trought when changing his current state
func crouchStateChanges():
	currentState = states.CROUCH
	moveSpeed = crouchSpeed
	moveAcceleration = crouchAcceleration 
	moveDecceleration = crouchDecceleration
	
	standHitbox.disabled = true
	crouchHitbox.disabled = false 
	
	if mesh.scale.y != 0.7:
		mesh.scale.y = 0.7
		mesh.position.y = -0.5
	else:
		pass
		
func walkStateChanges():
	currentState = states.WALK
	moveSpeed = walkSpeed
	moveAcceleration = walkAcceleration
	moveDecceleration = walkDecceleration
	
	standHitbox.disabled = false 
	crouchHitbox.disabled = true
	
	if mesh.scale.y != 1.0:
		mesh.scale.y = 1.0
		mesh.position.y = 0.0
	else:
		pass
	
func runStateChanges():
	currentState = states.RUN
	moveSpeed = runSpeed
	moveAcceleration = runAcceleration
	moveDecceleration = runDecceleration
	
	standHitbox.disabled = false 
	crouchHitbox.disabled = true 
	
	if mesh.scale.y != 1.0:
		mesh.scale.y = 1.0
		mesh.position.y = 0.0
	else:
		pass
	
func slideStateChanges():
	#condition here, the state is changed only if the character is moving (so has an input direction)
	if timeBeforeCanSlideAgain <= 0 and currentState != states.SLIDE:
		currentState = states.SLIDE 
		
		#change the start slide in air variable depending zon where the slide begun
		if !is_on_floor() and slideTime <= 0: 
			startSlideInAir = true
		elif is_on_floor() and lastFramePosition.y >= position.y: #character can slide only on flat or downhill surfaces: 
			desiredMoveSpeed += slideSpeedAddon #slide speed boost when on ground (for balance purpose)
			startSlideInAir = false 
		else:
			pass
			
		slideTime = slideTimeRef
		moveSpeed = slideSpeed
		if inputDirection != Vector2.ZERO: 
			slideVector = inputDirection 
		else: 
			slideVector = Vector2(0, -1)
		
		standHitbox.disabled = true
		crouchHitbox.disabled = false 
		
		if mesh.scale.y != 0.7:
			mesh.scale.y = 0.7
			mesh.position.y = -0.5
		else:
			pass
	elif currentState == states.SLIDE:
		slideTime = -1.0
		timeBeforeCanSlideAgain = timeBeforeCanSlideAgainRef
		if ceilingCheck.is_colliding(): 
			crouchStateChanges()
		else: 
			runStateChanges()
	else:
		pass
		
func dashStateChanges():
	#condition here, the state is changed only if the character is moving (so has an input direction)
	if inputDirection != Vector2.ZERO and timeBeforeCanDashAgain <= 0.0 and nbDashAllowed > 0:
		currentState = states.DASH
		nbDashAllowed -= 1
		moveSpeed = dashSpeed 
		dashTime = dashTimeRef
		velocityPreDash = velocity #save the pre dash velocity, to apply it when the dash is finished (to get back to a normal velocity)
		
		if mesh.scale.y != 1.0:
			mesh.scale.y = 1.0
			mesh.position.y = 0.0
		else:
			pass
	else:
		pass
			
func wallrunStateChanges():
	#condition here, the state is changed only if the character speed is greater than the walk speed
	if velocity.length() > walkSpeed and currentState != states.DASH and currentState != states.CROUCH and canWallRun: 
		currentState = states.ONWALL
		velocity.y *= wallGravityMultiplier #gravity value became onwall one
		
		if nbJumpsInAirAllowed != nbJumpsInAirAllowedRef: 
			nbJumpsInAirAllowed = nbJumpsInAirAllowedRef
		else:
			pass
		
		standHitbox.disabled = false
		crouchHitbox.disabled = true
		
		if mesh.scale.y != 1.0:
			mesh.scale.y = 1.0
			mesh.position.y = 0.0
		else:
			pass
	else:
		pass
			
func grappleStateChanges():
	#condition here, the state is changed only if the character isn't already grappling, and the grapple check is colliding
	if grappleHookCheck.is_colliding() and timeBeforeCanGrappleAgain <= 0.0 and currentState != states.GRAPPLE:
		var hit_normal = grappleHookCheck.get_collision_normal()
		
		#check if the hit normal is too close to UP (i.e., pointing upward with a value of 1) with 0.7 meaning it's mostly horizontal and facing upwards
		if hit_normal.dot(Vector3.UP) > 0.7:
			#surface is too horizontal — do not grapple
			return
		
		currentState = states.GRAPPLE
		
		if is_on_floor(): 
			velocity.y = grappleLaunchJumpVelocity
		else:
			pass
		
		timeBeforeCanGrappleAgain = timeBeforeCanGrappleAgainRef
		if nbJumpsInAirAllowed < nbJumpsInAirAllowedRef: 
			nbJumpsInAirAllowed = nbJumpsInAirAllowedRef
		else:
			pass
		moveSpeed = grapHookSpeed
		
		#get the collision point of the grapple hook raycast check
		anchorPoint = grappleHookCheck.get_collision_point()
		
		
		standHitbox.disabled = false
		crouchHitbox.disabled = true
		
		if mesh.scale.y != 1.0:
			mesh.scale.y = 1.0
			mesh.position.y = 0.0
		else:
			pass
			
	#the character is already grappling, so cut grapple state, and change to the one corresponding to his velocity
	elif currentState == states.GRAPPLE:
		if !is_on_floor():
			if velocity.y >= 0.0: 
				currentState = states.JUMP
			else: 
				currentState = states.INAIR
		else:
			pass
	else:
		pass

func collisionHandling(delta):
	#this function handle the collisions, whether that be collisions with a wall, ground or ceiling, to detect if the character can wallrun, jump upwards or simply collide
	if is_on_wall():
		var lastCollision = get_last_slide_collision()
		canFloorDamage = true
		canCeilingDamage = true
		
		if lastCollision:
			var collidedBody = lastCollision.get_collider()
			var layer = collidedBody.collision_layer
			
			#here, we check the layer of the collider, then we check if the layer 3 (walkableWall) is enabled, with 1 << 3-1. If theses two points are valid, the character can wallrun, if not, the player cannot and will instead collide, potentially losing health
			if layer & (1 << 3-1) != 0: 
				canWallRun = true 
			else:
				canWallRun = false
				
				if canWallDamage:
					if sqrt(momentum.x**2 + momentum.z**2) >= damageThresholdMomentum: #use pythagoras's theorem (a^2+b^2=c^2) of the x and z components of the momentum vector on the player to calculate the overall horziontal momentum and check if it's enough to cause damage to the player
						force = -momentum/delta
						collisionRadius = abs(global_position - lastCollision.get_position())
						remainingHealth -= (sqrt(force.x**2 + force.z**2)) #use pythagoras's theorem (a^2+b^2=c^2) of the x and z components of the force vector to calculate the overall horziontal force on the player when they collide, minusing this from their health
						winMenu.damageDealt += (sqrt(force.x**2 + force.z**2))
						canWallDamage = false
						
						if remainingHealth <= 0:
							torque = Vector3(-force.z*collisionRadius.y, force.y*collisionRadius.x*collisionRadius.z, -force.x*collisionRadius.y) #create a torque (rotational force) to later apply on the players dead body as they collide to simulate realistic physics
							remainingHealth = 0
							die()
						else:
							hud.displayBlood(0.5*(remainingHealth)/health) #display blood splatter vfx on the screen when the player takes damage by mulitpling the raidus (0.5) of the visible area by the proportion of remaining health and maximum health so more blood appears as the player loses more health
					else:
						pass
				else:
					pass
		else:
			pass
			
	elif is_on_floor():
		var lastCollision = get_last_slide_collision()
		canWallDamage = true
		canCeilingDamage = true
		
		if lastCollision:
			var collidedBody = lastCollision.get_collider()
			var layer = collidedBody.collision_layer
			
			#here, we check the layer of the collider, then we check if the layer 4 (jumpingPad) is enabled, with 1 << 4-1. If theses two points are valid, the character will jump upwards
			if layer & (1 << 4-1) != 0:
				pass
			else:
				if canFloorDamage:
					if abs(momentum.y) >= damageThresholdMomentum: #check if the y/vertical component of the momentum vector on the player is enough to cause damage to the player
						force = -momentum/delta
						collisionRadius = abs(global_position - lastCollision.get_position())
						remainingHealth -= abs(force.y)  #use if the y/vertical component of the force vector on the player as the force they experience when hitting the ground, minising this from their health
						winMenu.damageDealt += abs(force.y)
						canFloorDamage = false
						
						if remainingHealth <= 0:
							torque = Vector3(-force.z*collisionRadius.y, 0, force.x*collisionRadius.y) #create a torque (rotational force) to later apply on the players dead body as they collide to simulate realistic physics
							remainingHealth = 0
							die()
						else:
							hud.displayBlood(0.5*(remainingHealth)/health) #display blood splatter vfx on the screen when the player takes damage by mulitpling the raidus (0.5) of the visible area by the proportion of remaining health and maximum health so more blood appears as the player loses more health
					else:
						pass
				else:
					pass
		else:
			pass
			
	elif is_on_ceiling():
		var lastCollision = get_last_slide_collision()
		canWallDamage = true
		canFloorDamage = true
		
		if lastCollision:
			if canCeilingDamage:
				if abs(momentum.y) >= damageThresholdMomentum: #check if the y/vertical component of the momentum vector on the player is enough to cause damage to the player
					force = -momentum/delta
					collisionRadius = abs(global_position - lastCollision.get_position())
					remainingHealth -= abs(force.y) #use if the y/vertical component of the force vector on the player as the force they experience when hitting the ground, minising this from their health
					winMenu.damageDealt += abs(force.y)
					canCeilingDamage = false
					
					if remainingHealth <= 0:
						torque = Vector3(-force.z*collisionRadius.y, 0, force.x*collisionRadius.y) #create a torque (rotational force) to later apply on the players dead body as they collide to simulate realistic physics
						remainingHealth = 0
						die()
					else:
						hud.displayBlood(0.5*(remainingHealth)/health) #display blood splatter vfx on the screen when the player takes damage by mulitpling the raidus (0.5) of the visible area by the proportion of remaining health and maximum health so more blood appears as the player loses more health
				else:
					pass
			else:
				pass
		else:
			pass
	else:
		canWallDamage = true
		canFloorDamage = true
		canCeilingDamage = true
	
	momentum = mass*velocity

func die():
	#this function is responsible for turning the player into a deadbody when they die by switching from characterbody3d to rigidbody3d whilst setting up the appropriate properties and calling the appropriate functions
	var deadBody = preload("res://Scenes/DeadBodyScene.tscn").instantiate()
	get_parent().add_child(deadBody)
	deadBody.transform = get_global_transform()
	deadBody.global_position = global_position
	deadBody.global_rotation = cameraHolder.camera.global_rotation
	deadBody.linear_velocity = velocity
	deadBody.apply_torque(torque)
	queue_free()
