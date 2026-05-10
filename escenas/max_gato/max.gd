extends CharacterBody2D

#signal max_muerto


@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D


const _SPEED = 85.0
const _JUMP_VELOCITY = -300.0
var _muerto: bool

func _ready():
	area_2d.body_entered.connect(_on_area_2d_body_entered)


func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Input salto
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = _JUMP_VELOCITY
	
	
	# Bloqueo de acciones
	var bloqueado := (
		(animacion.animation == "maullido" or animacion.animation == "tirar_objeto")
		and animacion.is_playing()
	)
	
	# Movimiento
	if not bloqueado:
		var direction := Input.get_axis("izquierda", "derecha")

		if direction < 0:
			velocity.x = direction * _SPEED
			animacion.flip_h = true

		elif direction > 0:
			velocity.x = direction * _SPEED
			animacion.flip_h = false

		else:
			velocity.x = move_toward(velocity.x, 0, _SPEED)
	
	else:
		# Frenar mientras hace acciones
		velocity.x = 0
	move_and_slide()
	
	# No interrumpir animaciones especiales
	if bloqueado:
		return
	
	#animaciones y acciones
	#para que no se interrumpa las animaciones
	if (animacion.animation == "maullido" or animacion.animation == "tirar_objeto") and animacion.is_playing():
		return

	if Input.is_action_just_pressed("maullido"):
		animacion.play("maullido")
		SeñalesGlobales.sonido_generado.emit(global_position)
		print("¡Miau!")
		return
	
	if Input.is_action_just_pressed("interactuar"):
		animacion.play("tirar_objeto")
		print("Interactuando...")
		return
	
	# Animaciones de movimiento
	if !is_on_floor():
		animacion.play("saltar")
	elif velocity.x != 0:
		animacion.play("correr")
	else:
		animacion.play("idle")
	


#Funcion colision de daño (quitar 1 de los 2)
func _on_area_2d_body_entered(body: Node2D) -> void:
	print("game over")
	# _muerto = true
	# max_muerto.emit()
	# Game Over
