import strutils, strscans, sets, sequtils, times, tables
 
let grid_serial = 3628
let minimum = -999999999
let debug = false

proc check_coord(x, y: int) : bool =
    if x == 122 and y == 79:
        return true
    return false

type Cell = object
    x, y: int
    rack_id : int
    power_level: int
    total_power_level: seq[int]

proc get_hundreds(num: int) : int =
    if num < 100:
        return 0
    let hundreds = num %% 1000
    let digit = hundreds div 100
    return digit

var grid = newSeq[seq[Cell]]()
for yndex in 0..299:
    grid.add(newSeq[Cell]())
    for xndex in 0..299:
        grid[yndex].add( Cell(x:xndex, y:yndex, rack_id:0, power_level:0, total_power_level: newSeq[int]()) )
        let rack_id_1 = xndex + 1 + 10 #+1 because the problem counts from 1
        let power_level_1 = rack_id_1 * (yndex + 1) #+1 because problem counts from 1
        let power_level_2 = power_level_1 + grid_serial
        let power_level_3 = power_level_2 * rack_id_1
        let power_level_4 = get_hundreds(power_level_3)
        let power_level_5 = power_level_4 - 5
        if debug or check_coord(xndex+1, yndex+1): 
            echo "for (", xndex+1, ", ", yndex+1, ") rid: ", rack_id_1, " pl1: ", power_level_1, " pl2: ", power_level_2, 
                " pl3: ", power_level_3, " pl4: ", power_level_4, " pl5: ", power_level_5
        grid[yndex][xndex].rack_id = rack_id_1
        grid[yndex][xndex].power_level = power_level_5

proc calc_total_power(this_grid: seq[seq[Cell]], x, y, size: int) : int =
    result = 0
    let max = this_grid.len
    if x >= max - (size - 1)  or y >= max - (size - 1):
        return minimum

    if size == 1:
        grid[y][x].total_power_level.add(this_grid[y][x].power_level)
        return this_grid[y][x].total_power_level[0]
#    echo "power level: ", this_grid[y][x].total_power_level, " size: ", size
    let old_total_power_level = this_grid[y][x].total_power_level[size-2]
    result += old_total_power_level

    for x_add in 0..(size - 1):
        for y_add in 0..(size - 1):
            if (y_add == size - 1) or (x_add == size - 1):
                result += this_grid[y + y_add][x + x_add].power_level
    
    grid[y][x].total_power_level.add(result)
    
    return result

var max_grid_power_level = minimum
var max_x = 0
var max_y = 0
var max_size = 0

for square_side in 1..300:
    for yndex, row in grid:
        for xndex, elem in row:
            let group_power_level = calc_total_power(grid, xndex, yndex, square_side)
            if group_power_level > max_grid_power_level:
                max_grid_power_level = group_power_level
                max_x = xndex
                max_y = yndex
                max_size = square_side

    echo "best power level = ", max_grid_power_level, " at (", max_x+1, ", ", max_y+1, ", ", max_size,")  (current size: ", square_side, ")"

echo "\n!best power level = ", max_grid_power_level, " at (", max_x+1, ", ", max_y+1, ", ", max_size,")"


