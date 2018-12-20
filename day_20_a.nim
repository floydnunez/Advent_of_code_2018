import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times, typetraits#, nimprof
 
let file_name = "d20_input.txt"
let debug = "d20_input.txt" != file_name

let regexp = readFile(file_name)

echo regexp

type RoomDesc = object
    straight: string
    cost: int
    options: seq[RoomDesc]

let regseq = toSeq( regexp.items )[1..regexp.len - 2]

let directions = @['N', 'E', 'W', 'S']

proc parse_room(sequence: seq[char], pos: int) : (int, seq[RoomDesc]) =
    var current_list = newSeq[RoomDesc]()
    var current = RoomDesc(straight: "", options: @[], cost: 0)
    if debug: echo "parse_room: ", sequence, " at ", pos
    var index = pos
    while true:
        let elem = sequence[index]
        if debug: echo "loop: ", index, " elem: ", elem
        if elem in directions:
            current.straight &= elem
        elif elem == '|':
            current_list.add(current)
            current = RoomDesc(straight: "", options: @[], cost: 0)
        elif elem == '(':
            let (subindex, subrooms) = parse_room(sequence, index + 1)
            if debug: echo "subindex: ", subindex, " subrooms: ", subrooms
            current.options.add( subrooms )
            index = subindex    
        elif elem == ')':
            current_list.add( current )
            return (index, current_list)
        index += 1
        if index >= sequence.len:
            break
    current_list.add( current )
    return (index, current_list)

let (superindex, rooms) = parse_room( regseq, 0 )
var root = rooms[0]

proc calc_cost(room: var RoomDesc, parent_total: int) =
    room.cost = room.straight.len + parent_total
    for index, elem in room.options:
        calc_cost( room.options[index], room.cost )

calc_cost(root, 0)

echo "\n", root

proc calc_max(room: RoomDesc) : int =
    var current_max = room.cost
    for elem in room.options:
        let submax = calc_max(elem)
        if  submax > current_max:
            current_max = submax

    return current_max

let max = calc_max(root)

echo "\n", max

#3995 (too high)

let max_val_theo = 99999999
proc min_max(room: RoomDesc) : int =
    result = room.straight.len
    var min_val = max_val_theo
    for elem in room.options:
        let curr_min_max = min_max(elem)
        if curr_min_max < min_val:
            min_val = curr_min_max
    if max_val != max_val_theo:
        result += max_val
    return result

echo "\nminmax: ", min_max(root)
#67 (too low)