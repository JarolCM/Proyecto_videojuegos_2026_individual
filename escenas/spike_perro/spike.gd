extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_vision: Area2D
@export var area_escucha: Area2D

@onready var signo_interrogacion = $SignoInterrogacion

const SPEED = 120.0

var jugador_max: CharacterBody2D = null
var objetivo_sonido: Vector2
var investigando_sonido := false

func _ready():
	area_vision.body_entered.connect(_on_area_vision_body_entered)
	area_vision.body_exited.connect(_on_area_vision_body_exited)
	signo_interrogacion.visible = false
	
	SeñalesGlobales.sonido_generado.connect(_on_sonido_escuchado)
	

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movimiento
	# Ir a jugador
	if jugador_max:
		signo_interrogacion.visible = false
		var direction = sign(jugador_max.global_position.x - global_position.x)
		velocity.x = direction * SPEED
		investigando_sonido = false
	
	# Ir a sonido
	elif investigando_sonido:
		signo_interrogacion.visible = true
		var direction = sign(objetivo_sonido.x - global_position.x)
		velocity.x = direction * SPEED

		if abs(global_position.x - objetivo_sonido.x) < 3:
			investigando_sonido = false
			velocity.x = 0
		
		if is_on_wall():
			investigando_sonido = false
	
	# Sin objetivos
	else:
		signo_interrogacion.visible = false
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Persigue si no se escondio
	if jugador_max and !jugador_max.escondido: 
		var direction = sign(jugador_max.global_position.x - global_position.x)
		velocity.x = direction * SPEED
		investigando_sonido = false
	else:
		if jugador_max and jugador_max.escondido:
			jugador_max = null
	
	# Animaciones
	if velocity.x != 0:
		animacion.flip_h = velocity.x < 0
		animacion.play("correr")
	else:
		animacion.play("idle")

# Cuando max entra en el campo de vision de spike
func _on_area_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("max"):
		jugador_max = body

# Cuando max sale del campo de vision de spike
func _on_area_vision_body_exited(body: Node2D) -> void:
	if body.is_in_group("max"):
		jugador_max = null


func _on_sonido_escuchado(posicion_sonido: Vector2):
	var shape = area_escucha.get_node("CollisionShape2D").shape
	
	# Distancia entre Spike y el sonido
	var local_pos = area_escucha.to_local(posicion_sonido)
	var half_size = shape.size * 0.5
	
	if abs(local_pos.x) <= half_size.x and abs(local_pos.y) <= half_size.y:
		# Solo investiga si no está viendo a Max actualmente
		if jugador_max == null:
			objetivo_sonido = posicion_sonido
			investigando_sonido = true
