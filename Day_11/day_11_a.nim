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
        grid[yndex].add( Cell(x:xndex, y:yndex, rack_id:0, power_level:0) )
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

proc calc_total_power(this_grid: seq[seq[Cell]], x, y: int) : int =
    result = 0
    let max = this_grid.len
    if x >= max - 2 or y >= max - 2:
        return minimum

    result += this_grid[y][x].power_level
    result += this_grid[y+1][x].power_level
    result += this_grid[y+2][x].power_level
    result += this_grid[y][x+1].power_level
    result += this_grid[y+1][x+1].power_level
    result += this_grid[y+2][x+1].power_level
    result += this_grid[y][x+2].power_level
    result += this_grid[y+1][x+2].power_level
    result += this_grid[y+2][x+2].power_level

    return result

var max_grid_power_level = minimum
var max_x = 0
var max_y = 0

for yndex, row in grid:
    for xndex, elem in row:
        let group_power_level = calc_total_power(grid, xndex, yndex)
        if group_power_level > max_grid_power_level:
            max_grid_power_level = group_power_level
            max_x = xndex
            max_y = yndex

        #echo "best power level = ", max_grid_power_level, " at (", max_x+1, ", ", max_y+1, 
        #    ") for this (", xndex, ", ", yndex,") = ", group_power_level 

echo "\n!best power level = ", max_grid_power_level, " at (", max_x+1, ", ", max_y+1, ")"


