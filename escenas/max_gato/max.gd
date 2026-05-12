extends CharacterBody2D

signal max_muerto


@export var animacion: AnimatedSprite2D
@export var area_enemigo: Area2D
@export var area_victoria: Area2D
@export var reproductor: AudioStreamPlayer2D

# Constantes de movimiento
const _SPEED = 85.0
const _JUMP_VELOCITY = -300.0

# Condicionales
var _muerto: bool
var _victoria: bool


func _ready():
	area_enemigo.body_entered.connect(_on_area_enemigo_body_entered)
	area_victoria.body_entered.connect(_on_area_victoria_body_entered)


func _physics_process(delta: float) -> void:
	if _muerto:
		return
	
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Bloqueo de acciones
	var bloqueado := (
		(animacion.animation == "maullido" or animacion.animation == "tirar_objeto" or _victoria == true)
		and animacion.is_playing()
	)
	
	# Movimiento
	if not bloqueado:
		var direction := Input.get_axis("izquierda", "derecha")
		
		if Input.is_action_just_pressed("saltar") and is_on_floor():
			velocity.y = _JUMP_VELOCITY
		
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
	
	# Animaciones y acciones
	# Para que no se interrumpa las animaciones
	if (animacion.animation == "maullido" or animacion.animation == "tirar_objeto") and animacion.is_playing():
		return

	# Accion maullido
	if Input.is_action_just_pressed("maullido"):
		animacion.play("maullido")
		SeñalesGlobales.sonido_generado.emit(global_position)
		SeñalesGlobales.sumar_maullido()
		
		reproductor.play()
		# Sound Effect by Yomecerlm3 from Pixabay
		# Solo pongo creditos porque me parece genial incluirlo
		return
	
	# Accion interaccion
	if Input.is_action_just_pressed("interactuar"):
		# Por poner interacciones como la de esconderse
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


# Funcion colision de daño (Game Over)
func _on_area_enemigo_body_entered(_body: Node2D) -> void:
	print("game over")
	_muerto = true
	animacion.stop()
	
	# Tiempo de espera antes de reiniciar nivel
	await get_tree().create_timer(0.5).timeout
	max_muerto.emit()
	
	SeñalesGlobales.sumar_muerte()

# Funcion al llegar meta (WIN)
func _on_area_victoria_body_entered(_body: Node2D) -> void:
	print("win")
	_victoria = true
	animacion.play("victoria")
	
	# Tiempo de espera antes de pasar al siguiente nivel
	await get_tree().create_timer(1.0).timeout
	get_parent().get_parent().siguiente_nivel()
