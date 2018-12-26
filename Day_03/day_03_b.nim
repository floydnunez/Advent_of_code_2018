import strutils, rdstdin, strscans, sets
 
let
  width = 1000
  height = 1000
let file_name = "d3_input.txt"

var s = newSeq[seq[int]](height)
for ii in 0 .. height - 1:
  s[ii].newSeq(width)
  for jj in 0 .. width - 1:
    s[ii][jj] = 0

var ids = newSeq[seq[int]](height)
 
for ii in 0 .. height - 1:
   ids[ii].newSeq(width)
   for jj in 0 .. width - 1:
      ids[ii][jj] = 0

var ids_uniqs = initSet[int]()    
var overlapped = initSet[int]()    

var id_uniq = 0

for line in lines file_name:
    #    echo line
        var id, x, y, w, h: int
        if scanf(line, "#$i @ $i,$i: $ix$i", id, x, y, w, h) :
            ids_uniqs.incl(id)

echo "ids: ", ids_uniqs

for line in lines file_name:
#    echo line
    var id, x, y, w, h: int
    if scanf(line, "#$i @ $i,$i: $ix$i", id, x, y, w, h) :
        discard
        #echo "match!:", " id: ", id, " x: ", x, " y: ", y, " w: ", w, " h: ", h
    var never_overlapped = true
    for ii in 0..h-1:
        for jj in 0..w-1:
            s[ii+y][jj+x] += 1
            if ids[ii+y][jj+x] > 0:
                overlapped.incl(ids[ii+y][jj+x])
                overlapped.incl(id)
            ids[ii+y][jj+x] = id
            if s[ii+y][jj+x] > 1:
                never_overlapped = false
    if never_overlapped:
        id_uniq = id


var total_overlap = 0
for ii in 0 .. height - 1:
    var line = ""
    for jj in 0 .. width - 1:
        line.add(s[ii][jj])
        if s[ii][jj] > 1:
            total_overlap += 1
    echo line

echo "total overlap: ", total_overlap

echo "id_uniq: ", id_uniq

echo "ids_uniqs:  ", ids_uniqs
echo "overlapped: ", overlapped

let result = ids_uniqs.difference(overlapped)
echo "uniq: ", result