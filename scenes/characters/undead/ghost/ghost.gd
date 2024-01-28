extends CharacterBody3D


const SPEED = 1.0  # quite slow

var target = null
var vel = Vector3()
var path = null
var health = 200

#onready var fog = $Fog as GPUParticles3D
@onready var hitbox = $HitboxArea
@onready var game_world = GameManager.game
@onready var player = game_world.player


func _ready():
	self.set_physics_process(false)
	
#	fog.emitting = true
	
	hitbox.connect("body_entered", Callable(self, "on_hit_player"))
	
	var timer = Timer.new()
	timer.wait_time = 0.1
	add_child(timer)
	timer.connect("timeout", Callable(self, "find_path_timer"))
	timer.start()


func _process(delta):
	if health <= 0:
		queue_free()


func _physics_process(delta):
	self.look_at(target.global_transform.origin, Vector3.UP)
	
	if path.size() > 0:
		move_along_path(path)


func move_along_path(path):
	if global_transform.origin.distance_to(path[0]) < 0.1:
		path.remove_at(0)
		if path.size() == 0:
			return
	
	vel = (path[0] - global_transform.origin).normalized() * SPEED
	set_velocity(vel)
	move_and_slide()
	vel = velocity


func set_target(target):
	self.target = target
	self.set_physics_process(true)
#	find_path_timer()


#func on_hit_player(body):
#	if body.name == "Player":
#		body.die()
#		$Whisper.stop()
#		$Growl.play()


func find_path_timer():
	self.set_target(player)
	var nav_map = get_world_3d().navigation_map
	path = NavigationServer3D.map_get_path(nav_map, global_transform.origin, target.global_transform.origin, true)
	path.remove_at(0)
#	path = path_finder.find_path(global_transform.origin, target.global_transform.origin)
