import strutils, strscans, sets, sequtils, times, tables, strformat
 
let file_name = "d17_input.txt"
let debug = file_name != "d17_input.txt"
let max_repeats = if debug: 100
    else: 680

let flowable = @['.', '|']

type Rect = object
    x_ini, y_ini, x_fin, y_fin: int

type Drop = object
    x, y: int
    dir: int #0 = down, -1 = left, 1 = right

let fountain = Drop(x:500, y:0, dir: 0)

var rects = newSeq[Rect]()

var x_min = 99999
var x_max = 0
var y_max = 0

for line in lines file_name:
    var y_ini, y_fin, x_ini, x_fin: int
    if scanf(line, "y=$i, x=$i..$i", y_ini, x_ini, x_fin):
        y_fin = y_ini
    elif scanf(line, "x=$i, y=$i..$i", x_ini, y_ini, y_fin):
        x_fin = x_ini
    else:
        echo "NANI"
        quit(1)
    if x_max < x_fin:
        x_max = x_fin
    if y_max < y_fin:
        y_max = y_fin
    if x_min > x_ini:
        x_min = x_ini
    #sanity check
    if x_ini > x_fin:
        echo "LINE: ", line, " WRONG"
        quit(2)
    if y_ini > y_fin:
        echo "LINE: ", line, " SUPER WRONG"
        quit(2)
    rects.add(Rect(x_ini: x_ini, y_ini:y_ini, x_fin: x_fin, y_fin: y_fin))

#one square of margin
x_min -= 1
x_max += 1
let offset = x_min

echo "x_min: ", x_min, " x_max: ", x_max, " y_max: ", y_max

var map = newSeq[seq[char]]()
for yndex in 0..y_max:
    map.add( newSeq[char](x_max + 1) )

for yndex in 0..map.high:
    for xndex in 0..map[yndex].high:
        map[yndex][xndex] = '.'

#adding the fountain
map[0][500] = '+'

proc print_map() =
    for yndex in 0..y_max:
        var line = alignString($yndex, 4)
        for xndex in 0..x_max:
            if xndex >= offset:
                line &= $map[yndex][xndex]
        echo line
#    var line = "\n"
#    for index in 1..560:
#        line &= "-"
#    echo line, "\n"
    echo ""

#should only fill if it's .'s or |
proc fill_rect(elem: Rect, letter: char) =
    if letter == '~' and debug: echo "fill_rect ", elem
    for yy in elem.y_ini..elem.y_fin:
        for xx in elem.x_ini..elem.x_fin:
            if flowable.contains( map[yy][xx] ):
                map[yy][xx] = letter

#write the rects
for elem in rects:
    fill_rect(elem, '#')

#print_map()

proc check_drop_inside_map(drop: Drop): bool =
    if drop.x >= 0 and drop.x <= x_max:
        if drop.y >= 0 and drop.y <= y_max:
            return true
    return false

let blocks = @['#', '~']

proc does_have_it(sequ: seq[Drop], drop: Drop): bool =
    for elem in sequ:
        if elem.x == drop.x and elem.y == drop.y and elem.dir == drop.dir:
            return true
    return false

proc walk_and_fill_pipe(x, y, dir: int) =
    var curr_x = x
    while true:
        if map[y][curr_x] == '.':
            map[y][curr_x] = '|'
        curr_x += dir
        if map[y][curr_x] == '#':
            break

proc fill_line(x, y: int): (bool, bool, Drop, Drop) =
    var wall_to_the_left = false
    var wall_to_the_right = false
    var create_l = false
    var create_r = false
    var drop_l = Drop(x: -1, y: -1, dir: 3)
    var drop_r = Drop(x: -1, y: -1, dir: 3)
    #walk left searching for a wall. ONLY a wall
    var curr_x = x
    var min_x : int
    var max_x : int
    if debug: echo "trying to fill line at (", x, ", ", y, ")"
    while true:
        if debug: echo "walking left: (", curr_x, ", ", y, ")", " left block ", $map[y][curr_x - 1], " down block: ", $map[y+1][curr_x]
        if curr_x >= 0 and map[y][curr_x - 1] == '#' and blocks.contains( map[y+1][curr_x] ):
            wall_to_the_left = true
            min_x = curr_x
            if debug: echo "walked left, wall"
            break
        elif curr_x >= 0 and flowable.contains( map[y+1][curr_x] ):
            #there's a hole
            if debug: echo "walked left, hole"
            break
        elif curr_x < 0: 
            #fell off the border
            if debug: echo "walked left, end"
            break
        curr_x -= 1
    #walk RIGHT searching for a wall. ONLY a wall
    curr_x = x
    while true:
        if debug: echo "walking right: (", curr_x, ", ", y, ")", " right block ", $map[y][curr_x + 1], " down block: ", $map[y+1][curr_x]
        if curr_x <= x_max and map[y][curr_x + 1] == '#' and blocks.contains( map[y+1][curr_x] ):
            wall_to_the_right = true
            max_x = curr_x
            if debug: echo "walked right, wall"
            break
        elif curr_x <= x_max and flowable.contains( map[y+1][curr_x] ):
            #there's a hole
            if debug: echo "walked right, hole"
            break
        elif curr_x > x_max: 
            #fell off the border
            if debug: echo "walked right, end"
            quit(1)
            
        curr_x += 1
    if debug: echo "should we fill? ", wall_to_the_left, " and ", wall_to_the_right, " at (", x, ", ", y, ")"
    if wall_to_the_left and wall_to_the_right:
        #fill one line
        fill_rect(Rect(x_ini:min_x, y_ini: y, x_fin: max_x, y_fin: y), '~')
    elif wall_to_the_left: #a wall left means filling with pipe left
        walk_and_fill_pipe(x,y, -1)
    elif wall_to_the_right: #a wall right means a fountain left
        walk_and_fill_pipe(x,y, +1)

    if not wall_to_the_right: #no wall to the right: put new drop
        drop_r.x = x + 1
        drop_r.y = y
        drop_r.dir = 1
        create_r = check_drop_inside_map(drop_r)
    if not wall_to_the_left: #put new drop
        drop_l.x = x - 1
        drop_l.y = y
        drop_l.dir = -1
        create_l = check_drop_inside_map(drop_l)

    if create_l or create_r:
        if debug: echo "CREATING DROPS: at (", x,", ", y, ") = " , (create_l, create_r, drop_l, drop_r)
        if drop_r.x >= 503 or drop_l.x >= 503:
            if debug: echo "HEEEEEE"
    return (create_l, create_r, drop_l, drop_r)

proc drop_and_fill(param_drop: Drop): (bool, seq[Drop]) =
    var res = newSeq[Drop]()
    var did_something = false
    #flow and mark with |
    var drop = param_drop
    while true:
        #echo "drop: ", drop
        if drop.dir == 0:
            #echo "falling water"
            if drop.y < y_max and flowable.contains( map[drop.y+1][drop.x] ):
                if not blocks.contains( map[drop.y][drop.x] ): 
                    if map[drop.y+1][drop.x] == '.': #only did something if we are writing this block
                        did_something = true
                    map[drop.y+1][drop.x] = '|'
                drop.y += 1
            elif drop.y < y_max and blocks.contains( map[drop.y+1][drop.x] ):
                if debug: echo "found block at (", drop.x, ", ", drop.y+1,")"
                #try to fill this line; if it fails, create two fountains to the side of touchdown point
                let (create_l, create_r, drop_l, drop_r) = fill_line(drop.x, drop.y)
                did_something = true
                if create_l:
                    res.add( drop_l )
                if create_r:
                    res.add( drop_r )
                break
            elif drop.y >= y_max:
                break
        elif drop.dir == 1 or drop.dir == -1:
            if debug: echo "sideways flow: ", drop 
            if not flowable.contains( map[drop.y][drop.x + drop.dir]):
                if debug: echo "found wall??"
                did_something = true
                break
            if not blocks.contains( map[drop.y][drop.x] ):
                if debug: echo "writing pipe"
                map[drop.y][drop.x] = '|'
                did_something = true
            #check there's no hole under the drop. if no hole under, move drop to drop.dir
            if drop.y < y_max and blocks.contains( map[drop.y+1][drop.x] ) and flowable.contains( map[drop.y][drop.x + drop.dir]):
                #echo "no hole, moving"
                if map[drop.y][drop.x + drop.dir] == '.': #only did something if we are writing to this block
                    #echo "did something!"
                    did_something = true
                if not blocks.contains( map[drop.y][drop.x] ): 
                    map[drop.y][drop.x + drop.dir] = '|'
                drop.x += + drop.dir
            #check for hole under drop
            elif drop.y < y_max and flowable.contains( map[drop.y+1][drop.x] ):
                drop.dir = 0
                #echo "hole"
                #let the earlier if take care of this
        else:
            #echo "no dir?"
            break
    if did_something:
        if not does_have_it(res, param_drop):
            res.add(param_drop)
    return (did_something, res)

var origins = @[fountain]
var last_origin_count = -1
var repeated_origin_count = 0
while true:
    var next_origins = newSeq[Drop]()
    var did_anything_at_all = false
    for elem in origins:
        var (did_something, new_fountains) = drop_and_fill(elem)
        if did_something:
            did_anything_at_all = true
        next_origins.add(new_fountains)
    origins = deduplicate( next_origins )
    if debug: echo "did anything at all? ", did_anything_at_all, " next origins: ", next_origins.len
    if last_origin_count < origins.len:
        last_origin_count = origins.len
    elif origins.len == last_origin_count:
        repeated_origin_count += 1
    if repeated_origin_count >= max_repeats:
        echo next_origins
        print_map()
        break
    if not did_anything_at_all:
        break

let water = @['~','|']

var total_water = 0
for yndex in 0..y_max:
    for xndex in 0..x_max:
        let letter = map[yndex][xndex]
        if water.contains( letter):
            total_water += 1

#31790
#29000
#35112
echo "total water: ", total_water


