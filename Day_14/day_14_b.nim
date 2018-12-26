import strutils, strscans, sets, sequtils, times, tables
 
#let input = 293801
let input = "293801"

proc to_num_seq(data: string): seq[int] =
    result = newSeq[int]()
    let data_str_seq = toSeq( data.items )
    for elem in data_str_seq:
        result.add(parseInt($elem) )
    echo "to num seq: ", result
    return result

let input_seq = to_num_seq(input)

var cups = @[3,7]
var current_a = 0
var current_b = 1

proc convert_to_string(data: seq[int]) : string =
    result = ""
    for elem in data:
        result &= $elem
    
var result_seq = newSeq[int]()
var total_recipes = 0

proc find_substring(data: seq[int]) : int =
    result = -1
    for index, elem in data:
        if index + input_seq.len < data.len:
            if elem == input_seq[0]:
                if data[index + 1] == input_seq[1]:
                    if data[index + 2] == input_seq[2]:
                        if data[index + 3] == input_seq[3]:
                            if data[index + 4] == input_seq[4]:
                                if data[index + 5] == input_seq[5]:
                                    echo "index: ", index
                                    return index
    return result

proc find_substring_from_last_few(data: seq[int]) : int =
    if data.len < 8:
        return -1

    let temp_cups = data[(data.len - 8)..(data.len-1)]
    let pos = find_substring(temp_cups)
    if pos > -1:
        return data.len - temp_cups.len + pos
    else:
        return -1

while true:
    #add element to cups
    let total = cups[current_a] + cups[current_b]
    let tens = total div 10
    let units = total %% 10
    if tens > 0:
        cups.add tens
    cups.add units
    total_recipes += 2
    #move both elves
    current_a = (current_a + 1 + cups[current_a]) %% cups.len
    current_b = (current_b + 1 + cups[current_b]) %% cups.len
    #checking if the input is in
    let pos = find_substring_from_last_few(cups)
    if pos > -1:
        echo cups
        echo "total recipes: ", pos
        break

#31475
#5286651
