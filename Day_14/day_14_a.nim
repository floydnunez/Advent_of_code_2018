import strutils, strscans, sets, sequtils, times, tables
 
let input = 293801
#let input = 2018

var cups = @[3,7]
var current_a = 0
var current_b = 1

while cups.len < input + 10:
    #add element to cups
    let total = cups[current_a] + cups[current_b]
    let tens = total div 10
    let units = total %% 10
    if tens > 0:
        cups.add tens
    cups.add units
    #move both elves
#    echo current_a, " cups[current_a] = ", cups[current_a], " , ", current_b, " cups[current_b] = ", cups[current_b]
    current_a = (current_a + 1 + cups[current_a]) %% cups.len
    current_b = (current_b + 1 + cups[current_b]) %% cups.len
#    echo current_a, " . ", current_b
#    echo cups[current_a], " - ", cups[current_b]
#    echo "a: ", cups
echo "cups final: ", cups
#printing the next 10 after <input> recipes
var result_seq = newSeq[int]()
for index, elem in cups:
    if index >= input and index < input + 10:
        result_seq.add elem
echo "result: ", result_seq