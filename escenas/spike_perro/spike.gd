extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D
@export var area_daño: Area2D


const SPEED = 80.0

var jugador_max: CharacterBody2D = null

func _ready():
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)
	area_daño.body_entered.connect(_on_area_daño_body_entered)

func _physics_process(delta: float) -> void:
	#Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	#Movimiento
	if jugador_max:
		var direction = (jugador_max.global_position - global_position).normalized()

		velocity.x = direction.x * SPEED

		if velocity.x < 0:
			animacion.flip_h = true
		else:
			animacion.flip_h = false
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	#animaciones
	if velocity.x != 0:
		animacion.play("correr")
	else:
		animacion.play("idle")

#Cuando max entra en el campo de vision de spike
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("max"):
		jugador_max = body
		print("¡Max detectado!")

#Cuando max sale del campo de vision de spike
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("max"):
		jugador_max = null
		print("Max salió del rango")


#Cuando spike choca con max
func _on_area_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("max"):
		print("game over")
		#Por poner "game over"
