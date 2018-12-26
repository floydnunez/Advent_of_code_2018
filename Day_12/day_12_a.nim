import strutils, strscans, sets, sequtils, times, tables
 
let file_name = "d12_input.txt"
let max_iter = 300
let offset = max_iter

var rules = initSet[string]()

var initial_state = newSeq[string]()

proc set_initial_state(data_ini: string) =
    let chars = toSeq(data_ini.items)
    for elem in chars:
        initial_state.add( elem & "" )

for line in lines file_name:
    echo line
    var initial_data, rule: string
    if scanf(line, "initial state: $+", initial_data):
        echo initial_data
        set_initial_state(initial_data)
    if scanf(line, "$* => #", rule):
        rules.incl( rule )

var state = initial_state 

echo "rules: ", rules
echo "state: ", state

proc get_area(index: int, curr_pot: string, pot_row: seq[string]): string =
    result = ""
    for position in (index - 2)..(index + 2):
        if position < 0 or position >= pot_row.len:
            result &= "."
        else: 
            result &= pot_row[position]
    return result

proc sum_state(status: seq[string], offset_val: int): int =
    result = 0
    for index, elem in status:
        if elem == "#":
            result += index - offset_val
    return result


proc print_state(status: seq[string], offset_val: int): string =
    result = ""
    for index in offset_val..status.len - offset_val:
        result &= status[index]
    return result
    
var curr_state = newSeq[string](initial_state.len + 2 * offset)
var next_state = newSeq[string](initial_state.len + 2 * offset)
for index in 0..initial_state.len + 2 * offset - 1:
    curr_state[index] = "."
    if index >= offset and index < offset + initial_state.len:
        curr_state[index] = initial_state[index - offset]

let ini_time = cpuTime()

var last_sum = 0
let partial_sum_a = sum_state(curr_state, offset)
echo "firs_state: ", print_state(curr_state, offset), " = ", partial_sum_a, " diff: ", (partial_sum_a - last_sum)
last_sum = partial_sum_a

proc calc_ab(sum, iteration: int): (int, int) =
    let a = int(sum / 59)
    let b = int(sum %% 59)
    return (a,b)

for index in 1..max_iter:
    for index, elem in curr_state:
        let pot_and_surrounding = get_area(index, elem, curr_state)
        if rules.contains(pot_and_surrounding):
            next_state[index] = "#"
        else: 
            next_state[index] = "."
    curr_state = next_state
    let partial_sum = sum_state(curr_state, offset)
    let (a, b) = calc_ab(partial_sum, index)
    echo "next_state: ", print_state(curr_state, offset), " = ", partial_sum, " diff: ", (partial_sum - last_sum), " iter: ", index, " a = ", a, " b = ", b 
    last_sum = partial_sum

let fin_time = cpuTime()
echo "total time: ", (fin_time - ini_time)

echo "fin  state: ", print_state(next_state, offset)
echo "sum: ", sum_state(next_state, offset)

#first guess: 2950000000005
let fifty_billions = 50000000000
echo "total = ", fifty_billions * 59 + 1598

let three_hundo = 300
echo "total ", (three_hundo * 59 + 1598)