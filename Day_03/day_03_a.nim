import strutils, rdstdin, strscans
 
let
  width = 1000
  height = 1000
var s = newSeq[seq[int]](height)
 
for ii in 0 .. height - 1:
  s[ii].newSeq(width)
  for jj in 0 .. width - 1:
    s[ii][jj] = 0


for line in lines "d3_input.txt":
    echo line
    var id, x, y, w, h: int
    if scanf(line, "#$i @ $i,$i: $ix$i", id, x, y, w, h) :
        echo "match!:", " id: ", id, " x: ", x, " y: ", " w: ", w, " h: ", h
    for ii in 0..w-1:
        for jj in 0..h-1:
            s[ii+x][jj+y] += 1

var total_overlap = 0
for ii in 0 .. height - 1:
    var line = ""
    for jj in 0 .. width - 1:
        line.add(s[ii][jj])
        if s[ii][jj] > 1:
            total_overlap += 1
    echo line

echo "total overlap: ", total_overlap