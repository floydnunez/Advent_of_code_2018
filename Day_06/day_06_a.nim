import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times
 
let file_name = "d6_input.txt"

var width = 0
var height = 0
var id = ord('A')

let extra = 1
let mid_extra = 0

type Point = tuple[x: int, y: int]

var points = initTable[char, Point]()


for line in lines file_name:
    var w, h: int
    if scanf(line, "$i, $i", w,h):
        echo "line!: ", line, " \t x: ", w, " y: ", h
        while not isAlphaAscii chr(id):
            id += 1
        points[chr(id)] = (w,h)
        id += 1
    if w > width:
        width = w
    if h > height:
        height = h

echo points

echo "square = ", width, " x ", height

#hack, as to avoid out of range errors
width += extra
height += extra

var s = newSeq[seq[char]](height)
 
for ii in 0 .. height - 1:
  s[ii].newSeq(width)
  for jj in 0 .. width - 1:
    s[ii][jj] = '.'

proc print_square() =
    for ii in 0 .. height - 1:
        var line = ""
        for jj in 0 .. width - 1:
            line &= s[ii][jj]
        echo line
    echo "\n"

for id, point in points.pairs:
    s[point.y + mid_extra][point.x + mid_extra] = id

print_square()

#calc the manhattan distance now, for each square
var dual_distance = initSet[Point]()

for ii in 0 .. height - 1:
  for jj in 0 .. width - 1:
    var min_distance = 99999999
    var min_id = ' '
    for id, point in points.pairs:
        let low_id = id
        let manhattan = abs(ii - point.y - mid_extra) + abs(jj - point.x - mid_extra)
        if manhattan < min_distance and manhattan > 0:
            min_distance = manhattan
            min_id = low_id
        if manhattan == 0:
            min_distance = 0
            break
    if min_distance > 0:
        let this_point = (jj, ii)
        s[ii][jj] = min_id
    #let's check for dual distances
    for id, point in points.pairs:
        if id == min_id:
            continue
        if point.x == jj and point.y == ii:
            continue 
        let manhattan = abs(ii - point.y - mid_extra) + abs(jj - point.x - mid_extra)
        if manhattan == min_distance:
            s[ii][jj] = '.'
   
echo "dual distances: ", dual_distance, " len: ", dual_distance.len
print_square()

var to_ignore = initSet[char]()

#let's discount the points that have values on the borders
for ii in 0 .. height - 1:
    for jj in 0 .. width - 1:
        if (ii == 0 or ii == height - 1) or (jj == 0 or jj == width - 1):
            to_ignore.incl s[ii][jj]
echo to_ignore

#finally lets count the area that aren't in to_ignore
var areas = initTable[char, int]()

for ii in 0 .. height - 1:
    for jj in 0 .. width - 1:
        let id_point = s[ii][jj]
        if not to_ignore.contains id_point:
            let old_area = if areas.contains(id_point): areas[id_point]
                else: 0
            areas[id_point] = old_area + 1

echo areas

#find max
var max_area = 0
var max_id = ' '
for id, area in areas.pairs:
    if area > max_area:
        max_area = area
        max_id = id

echo "\n\n\n"

for ii in 0 .. height - 1:
    var line = ""
    for jj in 0 .. width - 1:
        if to_ignore.contains s[ii][jj]:
            line &= '.'
        else:
            line &= s[ii][jj]
    echo line


echo "max_id: ", max_id, " max area: ", max_area

echo points.len

echo points