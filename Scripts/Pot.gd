extends RigidBody2D

# var implements = INTERFACE.PlantableArea
var screen_size
var on_area : bool
var held : bool = false
var mouse_pressed = false
var mouse_offset
var has_seed : bool = false
var plant
#const SPRING_CONSTANT := 100.0
#func _physics_process(delta):
	#if Input.is_action_pressed("mouse"):
		#apply_central_impulse(SPRING_CONSTANT * get_local_mouse_position() * delta)

func _ready():
	$pot_picked.visible = false
	screen_size= get_viewport_rect().size

var previous_velocity = 0
var previous_wiggle = 0.0


func _process(delta):
	var velocity = Input.get_last_mouse_velocity()
	var wiggle = deg_to_rad(velocity.y - previous_velocity/800)*delta
	previous_velocity = velocity.y
	
	if held:
		var new_position = get_global_mouse_position() + mouse_offset
		new_position = new_position.clamp(Vector2.ZERO, screen_size)
		move_and_collide(new_position - global_transform.origin)

		rotation = lerp(0.0,wiggle,.5)
		previous_wiggle = wiggle
		
		if Input.is_action_just_pressed("mouse_left") or\
			Input.is_action_just_pressed("mouse_right"):
			held = false
			velocity = 0
			$CollisionShape2D.disabled=false
			$pot_picked.visible = false
			$pot_onfloor.visible = true
		
	elif on_area && Input.is_action_just_pressed("mouse_left"):
			held = true
			mouse_offset = global_transform.origin - get_global_mouse_position()
			$CollisionShape2D.disabled=false #we use move and collide kasi
			$pot_picked.visible = true #tmp
			$pot_onfloor.visible = false #temp
			$pot_picked2.play()
	
	if held:
		Global.pot_held = true
	else:
		Global.pot_held = false


	
func drop():
	if held: return
	$pot_dropped.play()
	

func _on_mouse_entered():
	on_area = true
	$pot_onfloor.set_modulate("#cdcdcd")

func _on_mouse_exited():
	$pot_onfloor.set_modulate("#ffffff")
	on_area = false

func _on_body_entered(body):
	if body is Seed && !body.held:
		if has_seed:
			print("🪴Pot already has seed")
			#return 
		catch_seed(body.plant_seed,body.position.x-position.x)
		$absorb_particles.global_position.x = body.position.x
		body.absorb()

	
func catch_seed(plant_seed:Plant,x:int):
	print("Picked up " + plant_seed.plant_name)
	print(plant_seed)
	has_seed = true
	$absorb_particles.emitting = true
	var seed_instance = PlantScene.new()
	seed_instance.global_position=Vector2(x,$PlantPosition.position.y+randf_range(-5,5))
	seed_instance.plant_seed = plant_seed
	add_child(seed_instance)
	seed_instance.show_seed()
	seed_instance.on_ground()
	


func _on_screen_exited() -> void:
	queue_free()
