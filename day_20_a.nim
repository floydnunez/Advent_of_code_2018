import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times, typetraits#, nimprof
 
let file_name = "d20_input_test4.txt"
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
    echo "parse_room: ", sequence, " at ", pos
    var index = pos
    while true:
        let elem = sequence[index]
        echo "loop: ", index, " elem: ", elem
        if elem in directions:
            current.straight &= elem
        elif elem == '|':
            current_list.add(current)
            current = RoomDesc(straight: "", options: @[], cost: 0)
        elif elem == '(':
            let (subindex, subrooms) = parse_room(sequence, index + 1)
            echo "subindex: ", subindex, " subrooms: ", subrooms
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
