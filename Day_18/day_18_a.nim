import strutils, strscans, sets, sequtils, times, tables, strformat, parseutils#, nimprof 
 
let file_name = "d18_input.txt"
let debug = file_name != "d18_input.txt"

var o = open("output.txt", fmWrite)

#let max_minutes = 10000

let max_minutes = 1000000000

var x_max = 0
var y_max = 0

var data = newSeq[seq[char]]()

for line in lines file_name:
    data.add(toSeq( line.items ))
    y_max = line.len
    x_max += 1

echo "map is (", x_max, " x ", y_max, ")"

proc print_map(minute = 0) =
    for yndex, row in data:
        var line = alignString($yndex, 2)
        for cell in row:
            line &= $cell
        echo line
    if minute > 0:
        echo "minute: ", minute, "\n"
    else: echo "\n"

print_map(0)

let surrounding = @[@[-1,-1], @[0,-1], @[1,-1],
                    @[-1,0], @[1,0],
                    @[-1,1], @[0,1], @[1,1]]

proc count_surrounding(x, y: int) : (int, int) =
    var trees = 0
    var lumberyards = 0
    for elem in surrounding:
        let add_x = elem[0] + x
        let add_y = elem[1] + y
        if add_x >= 0 and add_x < x_max and add_y >= 0 and add_y < y_max:
            let which = data[add_y][add_x]
            if which == '|':
                trees += 1
            if which == '#':
                lumberyards += 1
    return (trees, lumberyards)

proc calc_next(x, y: int): char =
    let (trees, lumberyards) = count_surrounding(x, y)
    let which = data[y][x]
    if which == '.' and trees >= 3:
        return '|'
    if which == '|' and lumberyards >= 3:
        return '#'
    if which == '#' and lumberyards >= 1 and trees >= 1:
        return '#'
    elif which == '#':
        return '.'
    return which

proc count_all(): (int, int) =
    var trees = 0
    var lumberyards = 0
    for row in data:
        for cell in row:
            if cell == '|':
                trees += 1
            if cell == '#':
                lumberyards += 1
    return (trees, lumberyards)
    
for minute in 1..max_minutes:
    var next_data = newSeq[seq[char]](y_max)
    for yndex, row in data:
        next_data[yndex] = newSeq[char](x_max)
        for xndex, cell in row:
            next_data[yndex][xndex] = calc_next(xndex, yndex)
    #update everything at the same time
    data = next_data
    let (tree_total, lumber_total) = count_all()
    if minute %% 1000 == 0:
        o.writeln( "minute: ", minute, " trees: ", tree_total, 
        " lumberyards: ", lumber_total, " answer: ", (tree_total * lumber_total) )
    if minute %% 10000 == 0:
        o.flushFile()
    if debug: print_map(minute)
        
o.close()

let (tree_total, lumber_total) = count_all()

echo "trees: ", tree_total, " lumberyards: ", lumber_total
echo "answer: ", (tree_total * lumber_total) 
#190740 (too low)