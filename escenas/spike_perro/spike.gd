extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_vision: Area2D
@export var area_daño: Area2D
@export var area_escucha: Area2D

const SPEED = 90.0

var jugador_max: CharacterBody2D = null
var objetivo_sonido: Vector2
var investigando_sonido := false

func _ready():
	area_vision.body_entered.connect(_on_area_vision_body_entered)
	area_vision.body_exited.connect(_on_area_vision_body_exited)
	area_daño.body_entered.connect(_on_area_daño_body_entered)
	area_escucha.body_entered.connect(_on_area_escucha_body_entered)
	
	SeñalesGlobales.sonido_generado.connect(_on_sonido_escuchado)
	

func _physics_process(delta: float) -> void:
	#Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	#Movimiento
	#Ir a jugador
	if jugador_max:
		var direction = sign(jugador_max.global_position.x - global_position.x)
		velocity.x = direction * SPEED
		investigando_sonido = false
	
	# Ir a sonido
	elif investigando_sonido:
		var direction = sign(objetivo_sonido.x - global_position.x)
		velocity.x = direction * SPEED

		if abs(global_position.x - objetivo_sonido.x) < 10:
			investigando_sonido = false
			velocity.x = 0
		
		if is_on_wall():
			investigando_sonido = false
	
	# Sin objetivos
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	#animaciones
	if velocity.x != 0:
		animacion.flip_h = velocity.x < 0
		animacion.play("correr")
	else:
		animacion.play("idle")

#Cuando max entra en el campo de vision de spike
func _on_area_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("max"):
		jugador_max = body
		print("¡Max detectado!")

#Cuando max sale del campo de vision de spike
func _on_area_vision_body_exited(body: Node2D) -> void:
	if body.is_in_group("max"):
		jugador_max = null
		print("Max salió del rango")


#Cuando spike choca con max
func _on_area_daño_body_entered(body: Node2D) -> void:
	#if body.is_in_group("max"):
		#print("game over")
		#Por poner "game over"
	pass

#Cuando entra al area de escucha?
func _on_area_escucha_body_entered(body: Node2D) -> void:
	pass
	
func _on_sonido_escuchado(posicion_sonido: Vector2):
	var shape = area_escucha.get_node("CollisionShape2D").shape
	var largo = shape.size
	
	# Distancia entre Spike y el sonido
	var local_pos = area_escucha.to_local(posicion_sonido)
	var half_size = shape.size * 0.5
	
	if abs(local_pos.x) <= half_size.x and abs(local_pos.y) <= half_size.y:
		# Solo investiga si no está viendo a Max actualmente
		if jugador_max == null:
			objetivo_sonido = posicion_sonido
			investigando_sonido = true
			print("¡Spike escuchó algo en: ", posicion_sonido, "!")
