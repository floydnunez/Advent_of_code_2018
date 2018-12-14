import strutils, strscans, sets, sequtils, times, tables
 
let file_name = "d13_input.txt"

#first, let's figure out the width/height
var w_ini = 0 
var h_ini = 0
for line in lines file_name:
    echo line
    if line.len > w_ini:
        w_ini = line.len
    h_ini += 1

let width = w_ini
let height = h_ini

echo "( ", width, " , ", height, " )"

type Cell = object
    track : char
    vehicle : char
    vehicle_index: int

type Pos = object
    x: int
    y: int
    v: char

var map = newSeq[seq[Cell]](height)

for ii in 0 .. height - 1:
    map[ii].newSeq(width)
    for jj in 0 .. width - 1:
        map[ii][jj] = Cell(track: ' ', vehicle: ' ', vehicle_index: -1)

let vehicle_chars = @['<', '^', '>', 'v']

var iii = 0

var vehicle_pos = newSeq[Pos]()
var vehicle_memory = newSeq[int]() #0 = left, 1 = ahead, 2 = right

var global_vehicle_index = 0

for line in lines file_name:
    let chars = toSeq( line.items )
    for jndex, elem in chars:
        if vehicle_chars.contains( elem ):
            echo "adding vehicle"
            vehicle_pos.add(Pos(x: jndex, y: iii, v: elem))
            map[iii][jndex].vehicle_index = global_vehicle_index
            map[iii][jndex].vehicle = elem
            global_vehicle_index += 1
            vehicle_memory.add(0)

            if elem == '<' or elem == '>':
                map[iii][jndex].track = '-'
            elif elem == 'v' or elem == '^':
                map[iii][jndex].track = '|'
        else: 
            map[iii][jndex].track = elem
    iii += 1

echo vehicle_pos

echo map

echo "\n\n\nclean map: \n"

#let's print it to check
for ii in 0 .. height - 1:
    var line = "" & $ii
    for jj in 0 .. width - 1:
        line &= map[ii][jj].track
    echo line
        
proc clean_vehicles(mapa: seq[seq[Cell]]) : seq[seq[Cell]] =
    result = mapa
    for ii in 0 .. height - 1:
        for jj in 0 .. width - 1:
            result[ii][jj].vehicle = ' '
            result[ii][jj].vehicle_index = -1
    return result

proc decide_turn(vehicle: char, vehicle_index: int): char =
    let current_memory = vehicle_memory[vehicle_index]
    result = vehicle
    if vehicle == '<':
        if current_memory == 0:
            result = 'v'
            vehicle_memory[vehicle_index] = 1
        if current_memory == 1:
            vehicle_memory[vehicle_index] = 2
        if current_memory == 2:
            result = '^'
            vehicle_memory[vehicle_index] = 0
    if vehicle == '^':
        if current_memory == 0:
            result = '<'
            vehicle_memory[vehicle_index] = 1
        if current_memory == 1:
            vehicle_memory[vehicle_index] = 2
        if current_memory == 2:
            result = '>'
            vehicle_memory[vehicle_index] = 0
    if vehicle == '>':
        if current_memory == 0:
            result = '^'
            vehicle_memory[vehicle_index] = 1
        if current_memory == 1:
            vehicle_memory[vehicle_index] = 2
        if current_memory == 2:
            result = 'v'
            vehicle_memory[vehicle_index] = 0
    if vehicle == 'v':
        if current_memory == 0:
            result = '>'
            vehicle_memory[vehicle_index] = 1
        if current_memory == 1:
            vehicle_memory[vehicle_index] = 2
        if current_memory == 2:
            result = '<'
            vehicle_memory[vehicle_index] = 0
    return result
    
proc move_and_maybe_turn(mapa: seq[seq[Cell]], vehicle: char, x, y, vehicle_index: int) : char =
    result = vehicle
    if vehicle == '<':
        let next_track = mapa[y][x - 1].track
        if next_track == '/':
            result = 'v'
        elif next_track == '\\':
            result = '^'
        elif next_track == '+':
            result = decide_turn(vehicle, vehicle_index)
    if vehicle == '>':
        let next_track = mapa[y][x + 1].track
        if next_track == '/':
            result = '^'
        elif next_track == '\\':
            result = 'v'
        elif next_track == '+':
            result = decide_turn(vehicle, vehicle_index)
    if vehicle == '^':
        let next_track = mapa[y-1][x].track
        if next_track == '/':
            result = '>'
        elif next_track == '\\':
            result = '<'
        elif next_track == '+':
            result = decide_turn(vehicle, vehicle_index)
    if vehicle == 'v':
        let next_track = mapa[y+1][x].track
        if next_track == '/':
            result = '<'
        elif next_track == '\\':
            result = '>'
        elif next_track == '+':
            result = decide_turn(vehicle, vehicle_index)
    return result

echo "\n\nmoving\n\n"

while true: 
    var next_map = clean_vehicles( map )
    for ii in 0 .. height - 1:
        for jj in 0 .. width - 1:
            if map[ii][jj].vehicle == '<':
                let vehicle_next= move_and_maybe_turn(map, '<', jj, ii, map[ii][jj].vehicle_index)
                vehicle_pos[map[ii][jj].vehicle_index].x = jj - 1
                vehicle_pos[map[ii][jj].vehicle_index].y = ii
                vehicle_pos[map[ii][jj].vehicle_index].v = vehicle_next
                if next_map[ii][jj - 1].vehicle != ' ' or map[ii][jj - 1].vehicle != ' ':
                    echo "x: ", jj - 1, " y: ", ii
                    echo vehicle_pos
                    quit(1) 
                next_map[ii][jj - 1].vehicle = vehicle_next
                next_map[ii][jj - 1].vehicle_index = map[ii][jj].vehicle_index
            if map[ii][jj].vehicle == '>':
                let vehicle_next= move_and_maybe_turn(map, '>', jj, ii, map[ii][jj].vehicle_index)
                vehicle_pos[map[ii][jj].vehicle_index].x = jj + 1
                vehicle_pos[map[ii][jj].vehicle_index].y = ii
                vehicle_pos[map[ii][jj].vehicle_index].v = vehicle_next
                if next_map[ii][jj + 1].vehicle != ' ' or map[ii][jj + 1].vehicle != ' ':
                    echo "x: ", jj + 1, " y: ", ii
                    echo vehicle_pos
                    quit(1) 
                next_map[ii][jj + 1].vehicle = vehicle_next
                next_map[ii][jj + 1].vehicle_index = map[ii][jj].vehicle_index
            if map[ii][jj].vehicle == '^':
                let vehicle_next= move_and_maybe_turn(map, '^', jj, ii, map[ii][jj].vehicle_index)
                vehicle_pos[map[ii][jj].vehicle_index].x = jj
                vehicle_pos[map[ii][jj].vehicle_index].y = ii - 1
                vehicle_pos[map[ii][jj].vehicle_index].v = vehicle_next
                if next_map[ii - 1][jj].vehicle != ' ' or map[ii - 1][jj].vehicle != ' ':
                    echo "x: ", jj, " y: ", ii - 1
                    echo vehicle_pos
                    quit(1) 
                next_map[ii - 1][jj].vehicle = vehicle_next
                next_map[ii - 1][jj].vehicle_index = map[ii][jj].vehicle_index
            if map[ii][jj].vehicle == 'v':
                let vehicle_next= move_and_maybe_turn(map, 'v', jj, ii, map[ii][jj].vehicle_index)
                vehicle_pos[map[ii][jj].vehicle_index].x = jj
                vehicle_pos[map[ii][jj].vehicle_index].y = ii + 1
                vehicle_pos[map[ii][jj].vehicle_index].v = vehicle_next
                if next_map[ii + 1][jj].vehicle != ' ' or map[ii + 1][jj].vehicle != ' ':
                    echo "x: ", jj, " y: ", ii + 1
                    echo vehicle_pos
                    quit(1) 
                next_map[ii + 1][jj].vehicle = vehicle_next
                next_map[ii + 1][jj].vehicle_index = map[ii][jj].vehicle_index

    for ii in 0 .. height - 1:
        var line = "" & $ii
        if ii < 10: 
            line = "  " & $ii
        elif ii < 100: 
            line = " " & $ii
        for jj in 0 .. width - 1:
            if next_map[ii][jj].vehicle == ' ':
                line &= next_map[ii][jj].track
            else:
                line &= next_map[ii][jj].vehicle
        echo line
    map = next_map
    echo "\n\n"
    


