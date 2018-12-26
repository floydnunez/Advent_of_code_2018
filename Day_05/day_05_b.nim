import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times
 
let file_name = "d5_input.txt"
let debug = false 

var polymer: string

for line in lines file_name:
    polymer = line

var poly_seq = toSeq(polymer.items)

func equal_but_case(x, y: char): bool = 
    if (toLowerAscii(x) == y or toLowerAscii(y) == x) and x != y:
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

func fully_reduce_poly(poly: seq[char]): seq[char] =
    var can_reduce = true
    var next_poly = poly
    while can_reduce:
    #    echo "can reduce? ", can_reduce, " poly len: ", next_poly.len
        next_poly = reduce(next_poly)
        can_reduce = can_we_still_reduce_more(next_poly)
    #    echo "can reduce again? ", can_reduce
    return next_poly

func eliminate_all(poly: seq[char], which: char): seq[char] =
    var new_poly = poly
    var to_eliminate = newSeq[int]()
    for index, elem in poly:
        if toLowerAscii(elem) == toLowerAscii(which):
            to_eliminate.add(index)
    reverse(to_eliminate)
    for elem in to_eliminate:
        new_poly.delete(elem)
    result = new_poly

let ini_time = cpuTime()

var min_poly: seq[char]
var min_len = 10000000
var min_letter: char

for char_index in ord('a')..ord('z'):
    let which_char = chr(char_index)
    var poly_without = eliminate_all(poly_seq, which_char) 
    let minimized_poly = fully_reduce_poly(poly_without)

    echo "without ", which_char, " = ", poly_without.len, " reacted len: ", minimized_poly.len

    if minimized_poly.len < min_len:
        min_len = minimized_poly.len
        min_letter = which_char
        min_poly = minimized_poly
    

echo "poly len: ", poly_seq.len
echo cast[string](poly_seq)

echo "min letter: ", min_letter, " min_len: ", min_len 

echo "ini: ", ini_time, " - ", cpuTime()
