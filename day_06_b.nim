import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times
 
let file_name = "d6_input.txt"

let max_distance = 10000

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

var s = newSeq[seq[int]](height)
 
for ii in 0 .. height - 1:
  s[ii].newSeq(width)
  for jj in 0 .. width - 1:
    s[ii][jj] = 0

for ii in 0 .. height - 1:
  for jj in 0 .. width - 1:
    var total = 0
    for id, point in points.pairs:
        let manhattan = abs(ii - point.y - mid_extra) + abs(jj - point.x - mid_extra)
        total += manhattan
    s[ii][jj] = total

var area = 0
for ii in 0 .. height - 1:
  for jj in 0 .. width - 1:
    if s[ii][jj] < max_distance:
        area += 1
    
echo "area: ", area