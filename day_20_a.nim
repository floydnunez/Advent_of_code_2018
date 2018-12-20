import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times, typetraits#, nimprof
 
let file_name = "d20_input_test1.txt"
let debug = "d20_input.txt" != file_name

let regexp = readFile(file_name)

echo regexp
