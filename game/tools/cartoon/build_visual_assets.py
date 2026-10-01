"""Original SVG artwork for the active Cartoon branch. No legacy pixel assets.

Run from any directory. Deterministic output; SVGs are imported once by Godot,
then shared as textures. New artwork remains MODELED_PENDING_GATE.
"""
from pathlib import Path
import hashlib
import json
import math
import random

OUT = Path(__file__).resolve().parents[2] / "assets/cartoon/v020"
INK = "#29312f"


class Art:
    def __init__(self, w, h):
        self.w, self.h, self.parts = w, h, []
        self.parts.append('''<defs>
<linearGradient id="stone" x2=".3" y2="1"><stop stop-color="#f3dfaa"/><stop offset="1" stop-color="#bca47a"/></linearGradient>
<linearGradient id="roof" x2=".6" y2="1"><stop stop-color="#5493a4"/><stop offset="1" stop-color="#27475b"/></linearGradient>
<linearGradient id="leaf" x2=".6" y2="1"><stop stop-color="#afc36b"/><stop offset=".45" stop-color="#608c4c"/><stop offset="1" stop-color="#2d5741"/></linearGradient>
<linearGradient id="water" x2="0" y2="1"><stop stop-color="#84d5ca"/><stop offset="1" stop-color="#367c8a"/></linearGradient>
</defs>''')

    def path(self, d, fill, stroke=INK, width=1.5, extra=""):
        if len(stroke) == 9 and stroke.startswith('#'):
            extra += f' stroke-opacity="{int(stroke[7:],16)/255:.3f}"'
            stroke = stroke[:7]
        self.parts.append(f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" stroke-linejoin="round" stroke-linecap="round" {extra}/>')

    def rect(self, x, y, w, h, fill, stroke=INK, width=1.5, rx=0):
        self.parts.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" stroke="{stroke}" stroke-width="{width}"/>')

    def ellipse(self, x, y, rx, ry, fill, stroke="none", width=1):
        opacity = 1.0
        if len(fill) == 9 and fill.startswith('#'):
            opacity = int(fill[7:], 16)/255
            fill = fill[:7]
        self.parts.append(f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" fill-opacity="{opacity:.3f}" stroke="{stroke}" stroke-width="{width}"/>')

    def line(self, x, y, x2, y2, color, w=1):
        self.path(f'M{x},{y} L{x2},{y2}', "none", color, w)

    def save(self, name):
        OUT.mkdir(parents=True, exist_ok=True)
        (OUT / f"{name}.svg").write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.w}" height="{self.h}" viewBox="0 0 {self.w} {self.h}">' + "".join(self.parts) + '</svg>\n')


def shadow(a, x, y, rx):
    a.ellipse(x + 9, y, rx, rx * .24, "#233d3030")
    a.ellipse(x, y, rx * .65, rx * .13, "#24322940")


def foliage(a, cx, cy, rx, ry, seed, autumn=False):
    rng = random.Random(seed)
    colors = ["#355943", "#4c7548", "#709951", "#9aaf60"]
    if autumn:
        colors = ["#675536", "#97833e", "#bdac55", "#ded184"]
    # Each crown has scalloped asymmetric edges, with layered leaf clusters.
    for i in range(30):
        angle = i * 2.39996
        r = math.sqrt((i + .5) / 30)
        x, y = cx + math.cos(angle) * rx * r, cy + math.sin(angle) * ry * r
        size = rng.uniform(9, 17)
        c = colors[min(3, max(0, int(2 - (y - cy) / ry * 1.6)))]
        a.path(f'M{x-size:.1f},{y:.1f} C{x-size-5:.1f},{y-size:.1f} {x-2:.1f},{y-size-7:.1f} {x+4:.1f},{y-size:.1f} C{x+size+8:.1f},{y-size:.1f} {x+size+4:.1f},{y+4:.1f} {x+size-2:.1f},{y+7:.1f} Q{x:.1f},{y+size:.1f} {x-size:.1f},{y:.1f}', c, "#31523d", .7)
        if i % 3 == 0:
            a.path(f'M{x-4:.1f},{y-3:.1f} q4,-5 8,-1 m-2,-4 q4,-3 7,0', 'none', colors[3], 1.6)


def tree(seed):
    a = Art(160, 210)
    shadow(a, 79, 193, 57)
    a.path('M68,188 Q72,151 66,117 L90,105 Q86,151 94,185 L113,193 L87,191 L79,181 L61,195 L48,194 Z', '#785039', '#353c30', 2.5)
    a.path('M78,180 Q83,137 77,115 M68,152 L53,133 M85,140 L105,117', 'none', '#aa7b49', 3)
    foliage(a, 76, 91, 46, 41, seed, seed == 2)
    foliage(a, 59, 65, 27, 24, seed + 17, seed == 2)
    foliage(a, 99, 80, 26, 29, seed + 29, seed == 2)
    for x in [48, 56, 100, 107]:
        a.path(f'M{x},195 l-3,-8 l5,5 l4,-9 l1,11', '#668449', 'none')
    a.save(f'tree_{seed}')


def pine():
    a = Art(130, 215)
    shadow(a, 65, 197, 43)
    a.path('M59,195 L57,131 L72,131 L73,195 L84,201 L68,199 L54,201 Z', '#795a3c', INK, 2)
    for i in range(4):
        y = 164 - i * 34
        w = 52 - i * 10
        a.path(f'M65,{y-69} Q{65-w/3},{y-31} {65-w},{y} L{65-w+10},{y-2} L{65-w+4},{y+6} Q65,{y+24} {65+w},{y+5} L{65+w-11},{y-2} L{65+w},{y} Q{65+w/3},{y-32} 65,{y-69}', ['#315643', '#3c6850', '#4d7c55', '#719562'][i], '#294f40', 2)
        a.path(f'M65,{y-48} Q{65-w/4},{y-23} {65-w+16},{y-1} M63,{y-23} l-10,19 m17,-24 l-8,23', 'none', '#9db373', 1.4)
    a.save('pine')


def bush():
    a = Art(100, 70)
    shadow(a, 48, 58, 39)
    foliage(a, 48, 37, 29, 12, 45)
    for x, y in [(25, 36), (60, 29), (69, 43), (42, 40)]:
        a.ellipse(x, y, 2.5, 2.5, '#cf9266', '#7f4742')
    a.save('bush')


def rock():
    a = Art(96, 76)
    shadow(a, 45, 65, 36)
    a.path('M10,49 L24,21 L54,12 L77,26 L85,56 L63,67 L26,63 Z', '#707c76', '#364742', 2)
    a.path('M10,49 L26,37 L54,12 L77,26 L60,45 L36,48 Z', '#b9bfb0', '#53665b', 1)
    a.path('M36,48 L60,45 L63,67 L26,63 Z', '#89978a', '#56675f', 1)
    a.path('M27,31 l16,-8 l-7,12 m22,13 l6,6 l-1,9', 'none', '#465b52', 1.5)
    a.path('M14,55 l13,-4 l8,7 l-5,6 l-12,-3 M64,24 l10,3 l-6,7 l-12,-3', '#687f4c', 'none')
    a.save('rock')


def barrel(a, x, y, s=1):
    a.parts.append(f'<g transform="translate({x} {y}) scale({s})">')
    a.path('M-10,-22 Q-15,-10 -10,0 Q0,6 10,0 Q15,-10 10,-22 Z', '#aa7545', INK)
    a.ellipse(0, -22, 10, 4, '#c99559', INK)
    for xx in [-6, 0, 6]:
        a.line(xx, -19, xx, 0, '#684b35', .8)
    for yy in [-16, -5]:
        a.path(f'M-12,{yy} Q0,{yy+6} 12,{yy}', 'none', '#49534c', 3)
    a.parts.append('</g>')


def window(a, x, y, gold=False):
    a.rect(x-2, y-2, 23, 29, '#76563c', rx=2)
    a.rect(x, y, 19, 23, '#e6be71' if gold else '#7cb5b6', width=1)
    a.line(x+9.5, y, x+9.5, y+23, '#e5d0a0', 2)
    a.line(x, y+10, x+19, y+10, '#e5d0a0', 2)
    a.rect(x-5, y+24, 29, 4, '#b59263', width=1)
    a.path(f'M{x-4},{y+28} l4,7 l21,0 l4,-7 Z', '#607d45', 'none')
    for xx in range(int(x), int(x)+22, 6):
        a.ellipse(xx, y+28, 2, 2, '#d99578')


def building(kind, variant=0):
    a = Art(210, 225)
    shadow(a, 105, 205, 87)
    roof = ['#b97049', '#416b83', '#788358'][variant % 3]
    if kind in ['guild', 'archive']: roof = '#416b83'
    if kind == 'alchemist': roof = '#756888'
    # Closed building: side wall and front share foundation, eaves and ridge.
    a.path('M132,87 L187,115 L187,185 L132,208 Z', '#9c916d', INK, 2)
    a.path('M30,88 L132,87 L132,208 L30,185 Z', 'url(#stone)', INK, 2)
    a.path('M30,171 L132,190 L187,170 L187,186 L132,208 L30,187 Z', '#8b8975', INK)
    for yy in [174, 184, 195]:
        a.line(33, yy-2, 130, yy+15, '#b4b297', 1)
    for xx in [40, 66, 95, 122]: a.line(xx, 178, xx, 187+(xx-30)*.15, '#666d5b')
    a.path('M30,92 L81,36 L132,91 Z', '#dfcda0', INK, 2)
    a.path('M18,92 L80,29 L146,89 L132,100 L79,48 L32,99 Z', roof, INK, 2.5)
    a.path('M80,29 L141,49 L199,108 L146,90 Z', roof, INK, 2)
    for i in range(1, 7):
        t = i / 7
        a.line(80+62*t, 30+20*t, 146+53*t, 91+17*t, '#253f474c', 1)
    for i in range(1, 6):
        t = i / 6
        a.line(80+66*t, 30+61*t, 142+57*t, 50+58*t, '#eedcb54a', 1.4)
        a.line(80-50*t, 49+50*t, 80+52*t, 49+50*t, '#f0c29266', 1.2)
    a.line(81, 30, 141, 49, '#ead1a0', 3)
    for x in [34, 128]: a.line(x, 97, x, 187 if x == 34 else 201, '#755437', 5)
    a.line(34, 141, 128, 159, '#755437', 4)
    a.line(34, 105, 61, 143, '#906544', 3)
    a.line(127, 105, 101, 150, '#906544', 3)
    window(a, 45, 108, kind == 'tavern')
    window(a, 98, 118, kind == 'tavern')
    a.path('M70,186 L70,158 Q84,140 98,161 L98,191 Z', '#604937', INK, 2)
    for x in [76, 82, 88, 94]: a.line(x, 160, x, 188, '#946a43', 1)
    a.ellipse(91, 176, 2, 2, '#e7ba58')
    a.path('M66,184 L102,192 L105,198 L65,191 Z', '#c8b58e', INK)
    a.path('M153,126 L171,135 L171,155 L153,147 Z', '#558486', '#5e5a43', 2)
    a.line(163, 132, 163, 152, '#c9bf96', 2)
    a.path('M154,64 L154,35 L167,39 L167,74 L162,77 Z', '#b09c80', INK)
    a.path('M151,34 L160,30 L172,35 L168,41 L154,38 Z', '#d7c4a0', INK)
    for yy in [45, 54, 63]: a.line(155, yy, 165, yy+3, '#736d5b')
    # Hanging sign and materials tell the building's purpose at play scale.
    if kind != 'house':
        a.path('M126,121 L153,121 L153,138', 'none', '#533f31', 3)
        a.rect(136, 138, 35, 27, '#674b38', '#d2a955', 2, 3)
        if kind == 'forge':
            a.path('M141,146 L165,146 L159,151 L158,156 L146,156 L148,151 Z', '#c4d0c4', 'none')
            a.path('M39,178 L39,155 Q49,146 59,158 L59,182 Z', '#412e2b', INK)
            a.path('M44,176 L47,163 L51,167 L54,160 L56,177 Z', '#edaf5d', 'none')
        elif kind == 'alchemist':
            a.path('M149,142 L157,142 L156,148 Q168,161 151,160 Q140,158 150,148 Z', '#8cd3be', 'none')
        elif kind in ['guild', 'archive']:
            a.path('M145,142 L162,159 M162,142 L145,159', 'none', '#f1dfae', 2.5)
            a.path('M45,78 L64,78 L64,100 L55,109 L45,100 Z', '#355974', '#d9b86b')
            a.path('M50,86 L59,96 M59,86 L50,96', 'none', '#e6c579', 2)
        else:
            a.path('M146,145 L159,145 L159,156 L146,156 Z M159,147 Q169,150 159,154', '#eac18b', 'none')
    barrel(a, 23, 191, .9)
    a.path('M170,193 l6,-13 l2,9 l8,-9 l-4,14', '#59794c', 'none')
    a.save(f'{kind}_{variant}' if kind == 'house' else kind)


def fountain():
    a = Art(170, 145)
    shadow(a, 82, 122, 73)
    a.ellipse(83, 114, 72, 25, '#757e70', INK, 2)
    a.ellipse(83, 107, 71, 23, '#d5cba9', INK, 2)
    a.ellipse(83, 104, 61, 17, 'url(#water)', '#879985', 2)
    for x in [30, 47, 67, 90, 113, 134]: a.line(x, 120, x+1, 132, '#9c9f89')
    a.path('M70,103 L75,48 L91,48 L99,103 Q84,111 70,103', 'url(#stone)', INK, 2)
    a.ellipse(84, 51, 31, 11, '#cec6a1', INK, 2)
    a.ellipse(84, 47, 29, 9, 'url(#water)', '#839a8c', 1)
    a.path('M79,48 L79,22 Q85,14 89,22 L89,48', '#adb7a0', INK, 2)
    a.path('M84,23 Q100,9 115,33 M84,23 Q68,7 53,34 M59,51 Q58,91 48,102 M106,51 Q107,91 115,104', 'none', '#a8e2d4', 3)
    a.path('M28,103 q15,5 29,0 m50,7 q18,5 28,-2', 'none', '#c7efe1', 1.5)
    a.save('fountain')


def market():
    a = Art(155, 135)
    shadow(a, 77, 119, 60)
    for x in [23, 128]: a.rect(x, 41, 5, 74, '#8b653f', width=1)
    a.path('M12,50 L29,20 L124,20 L143,52 Z', '#dabb83', INK, 2)
    for x in range(31, 130, 24):
        a.path(f'M{x},20 L{x+11},20 L{x+16},51 L{x-4},51 Z', '#a05d4e', 'none')
    a.path('M12,51 L143,51 L143,59 Q136,65 128,59 Q120,65 112,59 Q104,65 96,59 Q88,65 80,59 Q72,65 64,59 Q56,65 48,59 Q40,65 32,59 Q24,65 12,59 Z', '#d9b886', INK)
    a.path('M18,90 L119,90 L136,104 L35,104 Z', '#d1a66a', INK)
    a.path('M35,104 L136,104 L136,120 L35,124 Z', '#91633e', INK)
    for x in range(41, 136, 18): a.line(x, 105, x, 119, '#604831')
    for x, col in [(40, '#cb8554'), (68, '#c4b86a'), (98, '#6a9a65')]:
        a.rect(x-8, 82, 22, 10, '#84603d', width=1)
        for j in range(5): a.ellipse(x-4+j*4, 82-j%2*3, 3, 3, col, '#796547', .6)
    barrel(a, 21, 121, .7)
    a.save('market')


def ruin():
    a = Art(250, 200)
    shadow(a, 126, 171, 103)
    a.path('M24,158 L135,127 L225,158 L133,189 Z', '#a4ad8c', '#647761', 1)
    for x, y, h in [(42, 158, 80), (180, 157, 117), (103, 171, 62)]:
        a.path(f'M{x-13},{y} L{x-13},{y-h} L{x-3},{y-h-9} L{x+1},{y-h+2} L{x+14},{y-h-4} L{x+14},{y} Z', '#a2ae98', INK, 2)
        a.path(f'M{x+3},{y-h} L{x+14},{y-h-4} L{x+14},{y} L{x+3},{y+4} Z', '#738c7b', 'none')
        for yy in range(y-h+15, y, 18): a.line(x-12, yy, x+2, yy+2, '#617467')
        a.path(f'M{x-13},{y-9} q10,-17 5,-32 m0,14 l12,-5', 'none', '#52774c', 4)
    a.path('M31,75 L155,45 L193,49 L192,70 L38,98 Z', '#b6bca3', INK, 2)
    a.path('M41,76 L154,50 M49,89 L155,61', 'none', '#d5d6b4', 2)
    a.path('M74,75 l4,11 l-9,7 M144,49 l-5,8 l5,14', 'none', '#566d61', 2)
    a.ellipse(131, 150, 25, 12, '#556f68', INK, 1)
    a.path('M117,141 L131,118 L146,142 L133,155 Z', '#7ba8a1', '#31565d', 2)
    a.path('M131,127 l-5,12 l9,0 l-5,10', 'none', '#bce9d1', 2)
    for x, y in [(28, 168), (65, 180), (180, 184), (211, 164)]:
        a.path(f'M{x},{y} l9,-10 l17,4 l-4,12 Z', '#8c9c89', '#5c7262')
    a.save('ruin')


def mine():
    a = Art(250, 210)
    shadow(a, 127, 186, 109)
    a.path('M10,177 L26,113 L50,90 L80,39 L116,20 L153,35 L173,60 L214,82 L239,173 L190,193 L45,190 Z', '#6c8078', INK, 2)
    a.path('M26,113 L80,39 L116,20 L127,66 L102,99 L51,130 Z', '#a0af97', '#556f62', 1)
    a.path('M153,35 L173,60 L214,82 L172,108 L146,80 Z', '#889c89', '#556f62', 1)
    a.path('M72,184 L73,125 Q118,66 171,124 L176,184 Z', '#263c3e', '#405751', 4)
    a.path('M70,185 L70,124 L90,102 L100,111 L87,132 L88,184 M155,111 L173,123 L177,184 L161,185 L158,130 Z', '#ad8c5f', INK, 2)
    a.path('M79,112 L96,95 L163,100 L175,115 Z', '#bb9c6c', INK, 2)
    for xx in [83, 165]: a.ellipse(xx, 115, 2, 2, '#d1c89a', INK)
    for x in [105, 139]: a.path(f'M{x},155 L{x-10},195', 'none', '#b6b79b', 3)
    for y in [161, 174, 188]: a.line(99, y, 149, y+2, '#87694c', 4)
    for x in [47, 201]:
        a.line(x, 150, x, 180, '#584937', 4)
        a.path(f'M{x-5},150 L{x},133 L{x+7},152 Z', '#e8b169', '#c7824e', 1)
    for x, y in [(29, 171), (191, 174)]: a.path(f'M{x},{y} l4,-18 l9,6 l5,14 Z', '#86c4b3', '#4c847c', 1)
    a.save('mine')


def castle():
    a = Art(360, 300)
    shadow(a, 177, 273, 157)
    a.path('M82,137 L251,135 L285,163 L285,256 L178,277 L82,254 Z', '#b7b596', INK, 2)
    a.path('M87,133 L170,66 L256,137 Z', 'url(#roof)', INK, 2)
    for i in range(1, 7): a.line(170-i*11, 66+i*10, 170+i*13, 66+i*10, '#91b5b0', 1)
    for x, top in [(39, 118), (261, 109)]:
        a.path(f'M{x},{top} L{x+61},{top} L{x+67},253 Q{x+28},275 {x-5},252 Z', 'url(#stone)', INK, 2)
        a.path(f'M{x+47},{top} L{x+61},{top} L{x+67},253 L{x+49},260 Z', '#969f87', 'none')
        a.path(f'M{x-12},{top} L{x+28},{top-76} L{x+74},{top} Z', 'url(#roof)', INK, 2.5)
        for i in range(1, 6): a.line(x+28-i*6, top-76+i*12, x+28+i*7, top-76+i*12, '#789da3', 1)
        for yy in range(top+10, 252, 15):
            a.path(f'M{x+1},{yy} q31,10 60,0', 'none', '#9e9d7e', 1)
        for yy in [top+23, top+78]:
            a.path(f'M{x+23},{yy+18} L{x+23},{yy} Q{x+29},{yy-9} {x+35},{yy} L{x+35},{yy+18} Z', '#3a5c60', '#827e60', 2)
        a.line(x+28, top-76, x+28, top-97, '#826b41', 2)
        a.path(f'M{x+28},{top-95} l26,6 l-7,10 l-19,-4 Z', '#386f87', '#dec079', 1)
    for yy in range(160, 250, 17): a.line(104, yy, 255, yy+2, '#8c9a83', 1)
    a.path('M147,265 L147,214 Q175,175 202,213 L202,268 Z', '#394b46', '#d9ce9e', 5)
    for x in range(153, 201, 8): a.line(x, 215, x, 266, '#958767', 2)
    for x in [114, 225]:
        a.path(f'M{x},160 l20,0 l0,58 l-10,12 l-10,-12 Z', '#325d7c', '#d9be79', 2)
        a.path(f'M{x+5},173 l5,-6 l5,6 l-5,9 Z', '#e2c37d', 'none')
    a.path('M140,266 L204,271 L214,280 L130,276 Z', '#cac6a4', INK)
    a.save('castle')


def hero(direction, stride=0):
    a = Art(80, 104)
    side = direction in ['left', 'right']
    back = direction == 'back'
    sign = -1 if direction == 'left' else 1
    a.path('M24,57 Q19,75 17,87 L38,90 L59,84 L53,53 Z', '#544c65', '#2e3540', 1.5)
    a.path(f'M25,66 L{24-stride},{91+stride} L{34-stride},{93+stride} L38,72 M43,71 L{46+stride},{93-stride} L{56+stride},{91-stride} L53,66', '#4c554f', INK, 1.5)
    for x, y in [(23-stride,84+stride), (46+stride,84-stride)]:
        a.path(f'M{x},{y} l10,0 l2,12 l-15,0 l0,-6 Z', '#725640', INK, 1.5)
    a.path('M26,41 L48,41 L56,71 L40,80 L22,71 Z', '#466f82', '#283e46', 1.5)
    a.path('M28,45 L42,45 L42,67 L25,68 Z', '#729ba2', 'none')
    a.path('M23,69 L54,69 L54,74 L22,74 Z', '#805d40', INK)
    a.rect(36, 68, 7, 7, '#d1b369', width=1)
    a.path('M21,43 Q15,47 16,59 L21,70 L27,68 L24,56 L29,45 M51,44 Q60,46 61,56 L58,68 L52,68 L53,56 L46,45', '#aaa889', INK, 1.5)
    a.path('M18,60 l8,0 l-1,8 l-5,3 l-3,-4 M53,60 l8,0 l-2,9 l-6,1', '#826044', INK)
    a.path('M27,40 Q18,23 25,13 Q40,3 53,15 L56,27 L50,43 L39,47 Z', '#d5aa7d', '#453d31', 1.5)
    a.path('M23,26 L20,17 L27,7 L37,10 L44,5 L57,15 L56,29 L49,21 L43,18 L33,23 L28,20 Z', '#5a4937', '#30392e', 1.5)
    a.path('M27,13 l8,-1 l-5,6 m10,-7 l9,7', 'none', '#96794c', 2)
    if back:
        a.path('M22,34 Q38,46 56,32 L55,72 L40,84 L20,76 Z', '#4d566d', INK, 1.5)
        a.path('M30,42 L26,72 M45,43 L49,72', 'none', '#818193', 1.5)
        a.path('M23,23 Q39,34 56,23 L54,35 Q39,42 25,34 Z', '#5a4937', INK)
    elif side:
        x = 41 + sign * 8
        a.path(f'M{x},{27} l{sign*5},5 l{-sign*5},2', '#c69a70', '#8e6b4d', .7)
        a.ellipse(x, 26, 1.5, 2, '#283733')
        a.line(x-3*sign, 38, x+2*sign, 37, '#895e4c', 1)
    else:
        for x in [32, 46]:
            a.line(x-2, 26, x+2, 25, '#644e36', 1.5)
            a.ellipse(x, 29, 1.6, 2, '#283733')
        a.path('M38,30 l-1,5 l4,0 M35,39 q4,2 8,-1', 'none', '#9e7154', .9)
    a.path('M25,42 L32,46 L39,42', 'none', '#d8bd7a', 2)
    a.save(f'hero_{direction}' + (f'_walk_{0 if stride < 0 else 1}' if stride else ''))


def ground():
    a = Art(256, 256)
    a.rect(0, 0, 256, 256, '#7d905c', 'none')
    rng = random.Random(20620)
    for i in range(40):
        x, y = rng.uniform(12, 244), rng.uniform(12, 244)
        col = ['#798b59', '#829460', '#849462', '#7a8e59'][i % 4]
        a.path(f'M{x:.1f},{y:.1f} q-8,-8 -14,1 q-3,7 12,7 q16,-1 2,-8', col, 'none')
        if i % 3 == 0:
            a.path(f'M{x:.1f},{y:.1f} l-2,-5 m3,6 l3,-4', 'none', '#93a06b', .8)
    a.save('grass')


def wolf():
    a = Art(140, 112)
    a.path('M40,69 Q16,65 9,43 Q29,45 51,58 Z', '#697b7a', INK, 2)
    for x in [45, 81]:
        a.path(f'M{x},66 l8,0 l6,30 l-18,0 l1,-5 l6,-3 Z', '#536564', INK, 1.5)
    a.path('M31,64 Q34,38 64,40 Q93,37 100,65 L91,83 L57,85 L31,74 Z', '#83948a', INK, 2)
    a.path('M31,63 L41,49 L52,52 L58,43 L67,51 L77,43 L84,57 L77,68 L49,72 Z', '#a4aea0', 'none')
    a.path('M84,59 L86,30 L79,15 L96,23 L108,11 L113,35 L116,48 L133,54 L127,64 L109,69 L101,81 Z', '#8fa098', INK, 2)
    a.path('M92,24 L87,19 L90,32 M105,24 L109,18 L110,31', 'none', '#c6b8a0', 2)
    a.path('M105,44 L117,49 L128,55 L116,63 L105,57 Z', '#c4c6b1', 'none')
    a.ellipse(128, 54, 4, 3, '#293937')
    a.path('M101,40 l9,1 l-4,4 l-6,-1 Z', '#d2b46a', '#465149', 1)
    a.ellipse(105, 41, 1, 2, '#293937')
    for x in [49, 91]:
        a.path(f'M{x},73 l8,0 l-1,23 l-3,7 l-13,0 l0,-5 l7,-3 Z', '#96a298', INK, 1.5)
    a.path('M41,52 l6,7 m9,-12 l7,9 m11,-9 l6,8 M96,54 l2,11 l7,-2', 'none', '#c2c8ae', 1.5)
    a.save('wolf')


def guardian():
    a = Art(150, 165)
    for x in [44, 89]:
        a.path(f'M{x},117 l19,0 l6,34 l-30,0 l0,-10 Z', '#6d8782', INK, 2)
        a.path(f'M{x-4},142 l27,0 l0,9 l-30,0 Z', '#a2b4a4', INK)
    a.path('M44,55 L94,49 L119,88 L105,119 L43,120 L29,88 Z', '#6e8d89', INK, 2)
    a.path('M44,55 L67,64 L65,109 L43,120 L29,88 Z', '#a4b7a4', '#536e68', 1)
    for x, d in [(13, 0), (105, 6)]:
        a.path(f'M{x},{63+d} l27,-7 l6,23 l-7,8 l7,30 l-30,5 l-4,-28 l8,-7 Z', '#849f91', INK, 2)
        a.path(f'M{x},{96+d} l20,-4 l5,22 l-24,4 Z', '#59796f', INK)
    a.path('M45,21 L87,14 L103,30 L98,55 L82,65 L49,57 L39,40 Z', '#a2b4a1', INK, 2)
    a.path('M87,14 L103,30 L98,55 L82,65 L80,29 Z', '#698982', 'none')
    a.path('M48,35 L77,36 M48,49 l24,2', 'none', '#395853', 3)
    a.path('M52,36 l7,0 M69,36 l7,0', 'none', '#a2e1ce', 2)
    a.path('M69,72 L87,85 L75,101 L62,87 Z', '#345c59', '#b6c3a4', 2)
    a.path('M72,78 L80,86 L73,95 L68,87 Z', '#a9e2c7', 'none')
    a.path('M45,70 l8,8 l-5,10 M92,98 l-7,8 l5,7 M65,20 l-5,10 l6,8', 'none', '#425e57', 1.5)
    for x, y in [(35, 62), (88, 21), (113, 71)]:
        a.path(f'M{x},{y} q-7,-9 0,-15 q10,-3 12,2 q-3,10 -12,13', '#6f8b51', 'none')
    a.save('guardian')


def civic_props():
    a = Art(92, 140); shadow(a, 44, 126, 25)
    a.path('M35,125 L39,46 L48,46 L52,125 Z', '#49564c', INK, 2)
    a.path('M30,126 L58,126 L53,118 L36,118 Z', '#a4ac87', INK)
    a.path('M30,42 L57,42 L54,68 L34,68 Z', '#e7c276', '#505443', 2)
    a.path('M25,43 L44,26 L63,43 Z', '#52716c', INK, 2)
    a.line(44, 43, 44, 69, '#66715a', 2)
    a.path('M34,68 L54,68 L57,73 L31,73 Z', '#657864', INK)
    a.ellipse(44, 53, 8, 10, '#ffdf9840')
    a.save('lamp')
    a = Art(150, 86); shadow(a, 75, 72, 61)
    for x in [27, 121]:
        a.path(f'M{x},38 l5,34 l-6,0 l-7,-34 Z', '#455647', INK)
    for y in [22, 33]: a.path(f'M13,{y} L137,{y+2} L137,{y+10} L13,{y+8} Z', '#ae8555', INK)
    a.path('M10,55 L125,56 L141,65 L26,65 Z', '#ca9c64', INK)
    a.path('M26,65 L141,65 L141,70 L26,70 Z', '#785b3e', INK)
    for x in [23, 129]: a.line(x, 23, x, 54, '#59604a', 4)
    a.save('bench')
    a = Art(142, 148); shadow(a, 71, 131, 59)
    a.ellipse(70, 114, 48, 21, '#8b927a', INK, 2)
    a.rect(22, 96, 96, 18, '#a9b193', 'none')
    a.ellipse(70, 95, 48, 20, '#d5ceaa', INK, 2)
    a.ellipse(70, 93, 35, 13, '#385e5a', '#8e9a80', 1.5)
    for x in [27, 109]: a.rect(x, 37, 6, 61, '#926e43', width=1)
    a.path('M11,41 L68,12 L128,41 L117,48 L68,24 L22,48 Z', '#718581', INK, 2)
    for i in range(1, 4): a.line(68-i*11, 24+i*6, 68+i*12, 24+i*6, '#a5b5a1', 1)
    a.line(33, 64, 113, 64, '#765b3c', 5)
    a.line(73, 65, 73, 89, '#cfba89', 1.5)
    a.path('M65,86 L82,86 L80,101 L67,101 Z', '#a57c4d', INK)
    a.path('M27,111 Q69,128 115,111', 'none', '#697b65', 1.5)
    for x in [36, 61, 88, 109]: a.line(x, 114, x, 130, '#647761')
    a.save('well')
    a = Art(240, 110); shadow(a, 118, 92, 98)
    a.path('M12,53 L203,31 L228,59 L35,85 Z', '#be9969', INK, 2)
    for x in range(24, 213, 17): a.line(x, 52-(x-12)*.115, x+20, 84-(x-12)*.14, '#70573c', 1)
    a.path('M35,85 L228,59 L228,68 L35,95 Z', '#8b6946', INK)
    for x, y in [(18, 52), (208, 31), (38, 83), (224, 58)]: a.rect(x, y-30, 7, 34, '#94724e', width=1)
    a.line(22, 28, 212, 7, '#bb955e', 5)
    a.line(42, 57, 228, 32, '#bb955e', 5)
    a.save('bridge')
    a = Art(125, 130); shadow(a, 62, 118, 53)
    a.path('M17,117 L17,37 Q62,-9 106,37 L106,117 L89,117 L89,46 Q62,13 35,46 L35,117 Z', 'url(#stone)', INK, 2)
    a.path('M33,39 Q62,4 91,39', 'none', '#827f65', 3)
    for y in [58, 77, 95]:
        a.line(18, y, 33, y, '#8d9375')
        a.line(91, y, 105, y, '#8d9375')
    a.path('M40,107 L62,72 L82,107 L64,121 Z', '#91b7ab', '#597b75', 2)
    a.path('M62,83 L55,104 L68,101 L62,114', 'none', '#d0e6bf', 2)
    a.path('M17,102 q14,-10 5,-31 m1,14 l12,-8', 'none', '#6a8b50', 3)
    a.save('shrine')
    a = Art(100, 76); shadow(a, 49, 66, 43)
    a.path('M13,28 L71,17 L88,31 L87,60 L31,70 L12,56 Z', '#bc9c56', INK, 1.5)
    a.path('M13,28 L31,40 L87,31 L71,17 Z', '#dbc37f', INK, 1)
    a.path('M31,40 L87,31 L87,60 L31,70 Z', '#c8aa61', INK, 1)
    for y in [39, 47, 55, 62]:
        a.line(35, y+4, 83, y-5, '#a88945', .8)
        a.line(14, y-8, 27, y, '#9f8344', .8)
    for x in [44, 71]: a.path(f'M{x},24 l6,5 l0,34', 'none', '#796b43', 3)
    a.save('hay')
    a = Art(115, 85); shadow(a, 55, 74, 47)
    a.path('M14,45 L80,35 L98,48 L98,70 L31,80 L14,66 Z', '#9b713f', INK, 2)
    a.path('M14,45 Q14,21 34,19 L79,16 Q98,22 98,48 L31,57 Z', '#c09859', INK, 2)
    a.path('M31,57 L98,48 L98,70 L31,80 Z', '#a98149', INK)
    for y in [61, 70]: a.line(34, y, 96, y-8, '#715935', 1)
    for x in [39, 81]: a.path(f'M{x},20 l4,2 l6,26 l-2,24', 'none', '#e0bf77', 4)
    a.rect(60, 54, 9, 13, '#d5b366', width=1, rx=1)
    a.ellipse(65, 60, 1, 2, '#535b45')
    a.save('chest')
    a = Art(150, 73); shadow(a, 75, 63, 65)
    for y in [29, 44]: a.path(f'M4,{y} L142,{y+4} L142,{y+11} L4,{y+6} Z', '#a27c50', INK, 1)
    for x in [12, 77, 132]:
        a.path(f'M{x},65 L{x},14 L{x+5},6 L{x+10},14 L{x+10},65 Z', '#b99562', INK, 1.3)
        a.line(x+3, 20, x+3, 59, '#d4b782', 1)
        for y in [33, 48]: a.ellipse(x+5, y, 1.5, 1.5, '#5d6148')
    a.save('fence')


def windmill():
    a = Art(250, 265); shadow(a, 130, 244, 91)
    a.path('M79,237 L100,91 L156,91 L182,238 Z', 'url(#stone)', INK, 2)
    a.path('M137,91 L156,91 L182,238 L145,242 Z', '#929578', 'none')
    for y in range(135, 238, 16): a.line(96-(y-135)*.10, y, 160+(y-135)*.13, y, '#a09e7c', 1)
    a.path('M88,95 L126,43 L169,95 Z', 'url(#roof)', INK, 2)
    for i in range(1, 5): a.line(126-i*7, 43+i*10, 126+i*8, 43+i*10, '#95ae9f', 1)
    a.path('M113,239 L113,206 Q128,184 142,206 L142,240 Z', '#765a3e', INK, 2)
    for x in [120, 129, 137]: a.line(x, 209, x, 238, '#b18a51', 1)
    window(a, 112, 143)
    for angle in [25, 115, 205, 295]:
        a.parts.append(f'<g transform="translate(127 107) rotate({angle})">')
        a.path('M0,0 L0,-97', 'none', '#745c3f', 5)
        a.path('M3,-29 L3,-91 L25,-91 L25,-29 Z', '#d5cba0', '#695e43', 1.5)
        for y in range(-84, -28, 10): a.line(3, y, 25, y, '#a6966d', 1)
        a.line(14, -90, 14, -30, '#a6966d')
        a.parts.append('</g>')
    a.ellipse(127, 107, 9, 9, '#b49b64', INK, 2)
    barrel(a, 80, 242, 1)
    a.save('windmill')


def main():
    for i in range(3): tree(i)
    pine(); bush(); rock(); fountain(); market(); ruin(); mine(); castle()
    ground(); wolf(); guardian()
    civic_props(); windmill()
    for i in range(3): building('house', i)
    for kind in ['forge', 'tavern', 'guild', 'alchemist', 'archive']: building(kind)
    for direction in ['front', 'back', 'left', 'right']:
        hero(direction)
        hero(direction,-3)
        hero(direction,3)
    a = Art(60, 55); shadow(a, 27, 46, 23); barrel(a, 27, 43, 1.5); a.save('barrel')
    entries = [{"file":p.name,"status":"MODELED_PENDING_GATE","sha256":hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(OUT.glob('*.svg'))]
    (OUT / 'manifest.json').write_text(json.dumps({"style":"2D Cartoon","generator":"game/tools/cartoon/build_visual_assets.py","assets":entries},ensure_ascii=False,indent=2)+'\n')
    print(f'Generated {len(list(OUT.glob("*.svg")))} original Cartoon sprites: {OUT}')


if __name__ == '__main__':
    main()
