extends RefCounted
# Sombra projetada de TODOS os sprites do mundo. Luz de cima-esquerda: a sombra cai para baixo-direita.
# Sprites: a própria silhueta (textura preta) cisalhada pela altura acima do pé. Caixas (casas, muralhas) e personagens: polígono varrido.
# Desenhada numa passada própria, antes dos objetos, para ficar sempre sob qualquer sprite (sem empilhar dentro do mesmo objeto).

const SHEAR_X: float = 0.55      # deslocamento horizontal por px de altura
const SHEAR_Y: float = 0.28      # deslocamento vertical (para baixo) por px de altura
const MIN_HEIGHT: float = 20.0   # abaixo disso o objeto é "rasteiro" (canteiro, decalque, pedrinha) e só tem sombra de contato
const ALPHA_DEFAULT: float = 0.42
const ALPHA_TREE: float = 0.36

static var quad: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
static var uvq: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])

static func sprite(canvas: CanvasItem, tex: Texture2D, dst: Rect2, uv_px: Rect2, foot: Vector2, flip: bool, alpha: float, shear: float = 1.0) -> void:
	# dst: retângulo já desenhado no mundo (position = canto superior esquerdo, size positivo); foot: ponto de apoio no mundo.
	var height: float = foot.y - dst.position.y
	if height < MIN_HEIGHT:
		return
	var ts: Vector2 = tex.get_size()
	var u0: float = uv_px.position.x / ts.x
	var u1: float = (uv_px.position.x + uv_px.size.x) / ts.x
	var v0: float = uv_px.position.y / ts.y
	var v1: float = (uv_px.position.y + uv_px.size.y) / ts.y
	if flip:
		var swap: float = u0
		u0 = u1
		u1 = swap
	var x0: float = dst.position.x
	var x1: float = dst.position.x + dst.size.x
	var top: float = dst.position.y
	var bottom: float = dst.position.y + dst.size.y
	var ht: float = foot.y - top
	var hb: float = foot.y - bottom
	# canto = (x + SHEAR_X*h, foot.y + SHEAR_Y*h): projeção do ponto à altura h acima do pé
	quad[0] = Vector2(x0 + SHEAR_X * shear * ht, foot.y + SHEAR_Y * shear * ht)
	quad[1] = Vector2(x1 + SHEAR_X * shear * ht, foot.y + SHEAR_Y * shear * ht)
	quad[2] = Vector2(x1 + SHEAR_X * shear * hb, foot.y + SHEAR_Y * shear * hb)
	quad[3] = Vector2(x0 + SHEAR_X * shear * hb, foot.y + SHEAR_Y * shear * hb)
	uvq[0] = Vector2(u0, v0)
	uvq[1] = Vector2(u1, v0)
	uvq[2] = Vector2(u1, v1)
	uvq[3] = Vector2(u0, v1)
	canvas.draw_colored_polygon(quad, Color(0, 0, 0, alpha), uvq, tex)

static func box(canvas: CanvasItem, foot: Vector2, half_width: float, height: float, alpha: float = ALPHA_DEFAULT) -> void:
	# Sombra de uma parede/casa de largura 2*half_width e altura `height` apoiada em foot.
	var dx: float = SHEAR_X * height
	var dy: float = SHEAR_Y * height
	var pts: PackedVector2Array = PackedVector2Array([
		foot + Vector2(-half_width, 0.0), foot + Vector2(half_width, 0.0),
		foot + Vector2(half_width + dx, dy), foot + Vector2(-half_width + dx, dy)])
	canvas.draw_colored_polygon(pts, Color(0, 0, 0, alpha))

static func figure(canvas: CanvasItem, foot: Vector2, half_width: float, height: float, alpha: float = 0.3) -> void:
	# Personagens, animais e inimigos: elipse de contato + elipse afinada projetada na direção da luz (hull de duas elipses).
	var dx: float = SHEAR_X * height * 0.8
	var dy: float = SHEAR_Y * height * 0.8
	var pts: PackedVector2Array = PackedVector2Array()
	var n: int = 10
	# metade "de trás" da elipse de contato (lado esquerdo/superior), depois a elipse projetada (lado direito/inferior)
	for i in range(n + 1):
		var a: float = PI * 0.5 + PI * float(i) / float(n)          # esquerda: 90°..270°
		pts.append(foot + Vector2(cos(a) * half_width, sin(a) * half_width * 0.36))
	for i in range(n + 1):
		var a2: float = -PI * 0.5 + PI * float(i) / float(n)        # direita: -90°..90° da elipse projetada
		pts.append(foot + Vector2(dx, dy) + Vector2(cos(a2) * half_width * 0.55, sin(a2) * half_width * 0.2))
	canvas.draw_colored_polygon(pts, Color(0, 0, 0, alpha))
