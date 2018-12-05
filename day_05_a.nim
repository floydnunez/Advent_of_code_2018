import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times, nimprof
 
let file_name = "d5_input.txt"
let debug = false 

var polymer: string

for line in lines file_name:
    polymer = line

var poly_seq = toSeq(polymer.items)

var can_reduce = true

func equal_but_case(x, y: char): bool = 
    if abs(ord(x) - ord(y)) == 32:
        return true
    return false

func reduce(poly: seq[char]): seq[char] =
    if debug:  
        echo poly
    var indexes = newSeq[int]()
    var last_char = ' '
    for index, elem in poly:
        if equal_but_case(last_char, elem):
            indexes.add(index)
            if debug: echo "eliminating ", poly[index], "-", poly[index-1], " at ", index
            break
        last_char = elem
    var reverse_indexes = indexes
    reverse(reverse_indexes)
#    echo reverse_indexes
    var poly_result = poly
    for elem in reverse_indexes:
        poly_result.delete(elem)
        poly_result.delete(elem-1)
    return poly_result

func can_we_still_reduce_more(poly: seq[char]): bool =
    var last_char = ' '
    for index, elem in poly:
        if equal_but_case(last_char, elem):
            return true
        last_char = elem
    return false

let ini_time = cpuTime()
while can_reduce:
#    echo "can reduce? ", can_reduce, " poly len: ", poly_seq.len
    poly_seq = reduce(poly_seq)
    can_reduce = can_we_still_reduce_more(poly_seq)
#    echo "can reduce again? ", can_reduce

echo "poly len: ", poly_seq.len
echo cast[string](poly_seq)

echo "ini: ", ini_time, " - ", cpuTime()
