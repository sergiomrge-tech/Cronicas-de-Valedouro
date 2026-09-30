class_name ValedouroCartoonDraw
extends RefCounted
## Utilitários de desenho vetorial estilizado (contorno escuro, sombras suaves).

const OUTLINE := Color(0.12, 0.07, 0.1, 1.0)


static func ellipse_points(c: Vector2, rx: float, ry: float, seg: int = 18) -> PackedVector2Array:
    var pts := PackedVector2Array()
    for i in seg:
        var a := TAU * float(i) / float(seg)
        pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
    return pts


static func ellipse(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color, seg: int = 18) -> void:
    if rx < 0.5 or ry < 0.5:
        return
    ci.draw_colored_polygon(ellipse_points(c, rx, ry, seg), col)


static func ellipse_outlined(ci: CanvasItem, c: Vector2, rx: float, ry: float, fill: Color, outline: Color = OUTLINE, w: float = 3.0) -> void:
    ellipse(ci, c, rx + w, ry + w, outline)
    ellipse(ci, c, rx, ry, fill)


static func ellipse_line(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color, w: float = 2.0, seg: int = 24) -> void:
    var pts := ellipse_points(c, rx, ry, seg)
    pts.append(pts[0])
    ci.draw_polyline(pts, col, w, true)


static func shadow(ci: CanvasItem, c: Vector2, rx: float, alpha: float = 0.3) -> void:
    ellipse(ci, c, rx, rx * 0.38, Color(0, 0, 0, alpha))


static func circle_outlined(ci: CanvasItem, c: Vector2, r: float, fill: Color, outline: Color = OUTLINE, w: float = 3.0) -> void:
    ci.draw_circle(c, r + w, outline)
    ci.draw_circle(c, r, fill)


static func capsule(ci: CanvasItem, a: Vector2, b: Vector2, width: float, col: Color) -> void:
    ci.draw_line(a, b, col, width)
    ci.draw_circle(a, width * 0.5, col)
    ci.draw_circle(b, width * 0.5, col)


static func capsule_outlined(ci: CanvasItem, a: Vector2, b: Vector2, width: float, fill: Color, outline: Color = OUTLINE, w: float = 3.0) -> void:
    capsule(ci, a, b, width + w * 2.0, outline)
    capsule(ci, a, b, width, fill)


static func poly_outlined(ci: CanvasItem, pts: PackedVector2Array, fill: Color, outline: Color = OUTLINE, w: float = 3.0) -> void:
    ci.draw_colored_polygon(pts, fill)
    var closed := pts.duplicate()
    closed.append(pts[0])
    ci.draw_polyline(closed, outline, w, true)


static func rect_outlined(ci: CanvasItem, r: Rect2, fill: Color, outline: Color = OUTLINE, w: float = 3.0) -> void:
    ci.draw_rect(r.grow(w), outline)
    ci.draw_rect(r, fill)


static func bar(ci: CanvasItem, pos: Vector2, size: Vector2, ratio: float, fg: Color, bg: Color = Color(0.1, 0.08, 0.1, 0.85)) -> void:
    ci.draw_rect(Rect2(pos - Vector2(3, 3), size + Vector2(6, 6)), OUTLINE)
    ci.draw_rect(Rect2(pos, size), bg)
    var r := clampf(ratio, 0.0, 1.0)
    if r > 0.0:
        ci.draw_rect(Rect2(pos, Vector2(size.x * r, size.y)), fg)
        ci.draw_rect(Rect2(pos, Vector2(size.x * r, size.y * 0.35)), fg.lightened(0.35))


## Chama estilizada (usada por tochas, queimadura, cajado de fogo).
static func flame(ci: CanvasItem, base: Vector2, h: float, w: float, t: float, alpha: float = 1.0) -> void:
    var f := sin(t * 17.0) * 0.12 + sin(t * 29.0) * 0.08
    var outer := PackedVector2Array([base + Vector2(-w, 0), base + Vector2(-w * 0.7, -h * 0.45), base + Vector2(w * f * 3.0, -h * (1.0 + f)), base + Vector2(w * 0.7, -h * 0.45), base + Vector2(w, 0), base + Vector2(0, h * 0.25)])
    ci.draw_colored_polygon(outer, Color(1.0, 0.42, 0.1, alpha))
    var inner := PackedVector2Array([base + Vector2(-w * 0.55, 0), base + Vector2(w * f * 2.0, -h * 0.7), base + Vector2(w * 0.55, 0), base + Vector2(0, h * 0.15)])
    ci.draw_colored_polygon(inner, Color(1.0, 0.85, 0.3, alpha))
