extends CharacterBody2D

#signal max_muerto

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D


const _SPEED = 100.0
const _JUMP_VELOCITY = -350.0
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

	# Input direccional
	var direction := Input.get_axis("izquierda", "derecha")

	#Movimiento
	if direction < 0:
		velocity.x = direction * _SPEED
		animacion.flip_h = true
	elif direction > 0:
		velocity.x = direction * _SPEED
		animacion.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, _SPEED)
		
	move_and_slide()
	
	#animaciones
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
