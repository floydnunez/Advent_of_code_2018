import strutils, strscans, sets, sequtils, times, tables, os
 
let file_name = "d15_input.txt"

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

type Monster = object
    exists: bool
    letter: char
    hit_points: int
    attack_power: int
    attacked: bool
    moved: bool

type Cell = object
    letter : char
    is_floor: bool
    monster : Monster
    cost: int

var elf_attacking_power = parseInt( paramStr(1) )
let goblin_attacking_power = 3
let no_monster = Monster(exists: false, letter: '.', hit_points: 0, attack_power: 0, attacked: false, moved: false)
let elf = Monster(exists: true, letter: 'E', hit_points: 200, attack_power: 3, attacked: false, moved: false)
let goblin = Monster(exists: true, letter: 'G', hit_points: 200, attack_power: 3, attacked: false, moved: false)

var map = newSeq[seq[Cell]](height)

let monster_or_floor = @['.', 'E', 'G']

var index = 0
#actually read the file
var elves_total = 0
for line in lines file_name:
    let chars = toSeq( line.items )
    map[index] = newSeq[Cell]()
    for jndex, elem in chars:
        if elem == '#':
            let wall = Cell(letter: '#', is_floor: false, monster: no_monster, cost: -1)
            map[index].add( wall )
        if monster_or_floor.contains( elem ):
            var monster: Monster
            if elem == 'E':
                monster = elf
                elves_total += 1
            elif elem == 'G':
                monster = goblin
            else:
                monster = no_monster
            let floor = Cell(letter: '.', is_floor: true, monster: monster, cost: -1)
            map[index].add( floor ) 
    index += 1

proc numbers(fro, to: int) : string =
    result = ""
    for elem in fro..to:
        result &= $(elem %% 10)
    return result

proc echo_map() =
    var counter = 0
    echo "   ", numbers(0, width-1)
    for line in map:
        var print_line = toHex(counter, 2) & " "
        var healths = newSeq[string]()
        for elem in line:
            if elem.monster == no_monster:
                print_line &= elem.letter
            else:
                print_line &= elem.monster.letter
                var health = ""
                health &= $elem.monster.letter
                health &= "("
                health &= $elem.monster.hit_points
                health &= ")"
                healths.add(health)
        for elem in healths:
            print_line &= " " & elem
        counter += 1
        echo print_line

#copies, use sparingly
proc echo_map_flood(x,y: int, that_map: seq[seq[Cell]], floodP = false) =
    var counter = 0
    echo "flood from (", x, ", ", y, ")"
    echo "   ", numbers(0, width-1)
    for line in that_map:
        var print_line = toHex(counter, 2) & " "
        var healths = newSeq[string]()
        for elem in line:
            if elem.monster == no_monster:
                if floodP:
                    if elem.letter == '.':
                        if elem.cost < 0:
                            print_line &= ','
                        else:
                            print_line &= toLower(toHex(elem.cost, 1))
                    else: print_line &= elem.letter
                else:
                    print_line &= elem.letter
            else:
                print_line &= elem.monster.letter
                if not floodP:
                    var health = ""
                    health &= $elem.monster.letter
                    health &= "("
                    health &= $elem.monster.hit_points
                    health &= ")"
                    healths.add(health)
        for elem in healths:
            print_line &= " " & elem
        echo print_line
        counter += 1

    echo ""

proc did_either_side_win(): char =
    var only_elves = true
    var only_goblins = true
    for line in map:
        for elem in line:
            if elem.monster.letter == 'E':
                only_goblins = false
            if elem.monster.letter == 'G':
                only_elves = false
            if (not only_elves) and (not only_goblins):
                return '-'
    if only_elves:
        return 'E'
    if only_goblins:
        return 'G'
    return '-'

type Candidate = object
    x, y, hp: int
    letter: char

proc get_four_monsters_around(x,y: int, letter: char): seq[Candidate] =
    result = newSeq[Candidate]()
    if y > 0:
        let monster = map[y - 1][x].monster
        if monster.exists and monster.letter != letter:
            let candidate = Candidate(x: x, y: y-1, hp: monster.hit_points, letter: monster.letter)
            result.add( candidate )
    if x > 0:
        let monster = map[y][x - 1].monster
        if monster.exists and monster.letter != letter:
            let candidate = Candidate(x: x-1, y: y, hp: monster.hit_points, letter: monster.letter)
            result.add( candidate )
    if x < width - 1:
        let monster = map[y][x + 1].monster
        if monster.exists and monster.letter != letter:
            let candidate = Candidate(x: x+1, y: y, hp: monster.hit_points, letter: monster.letter)
            result.add( candidate )
    if y < height - 1:
        let monster = map[y + 1][x].monster
        if monster.exists and monster.letter != letter:
            let candidate = Candidate(x: x, y: y+1, hp: monster.hit_points, letter: monster.letter)
            result.add( candidate )
    return result

proc get_first_candidate_with_min_health(candidates: seq[Candidate]): Candidate =
    var min_index = -1
    var min_health = 999999
    for index, elem in candidates:
        if elem.hp < min_health:
            min_health = elem.hp
    #now decide reading order
    var min_read_cost = 9999999
    for index, elem in candidates:
        let reading_cost = elem.y * width + elem.x
        if min_health == elem.hp and reading_cost < min_read_cost:
            min_read_cost = reading_cost
            min_index = index

    return candidates[min_index]

proc attack(x,y: int, guy: Monster): bool =
    #sanity check
    if map[y][x].monster.attacked:
        return false
    #check four directions
    let four_candidates = get_four_monsters_around(x, y, guy.letter)
    if four_candidates.len == 0:
        return false
    echo "for ", guy.letter, " at ", x, ", ", y, " victims are: ", four_candidates
    let victim = get_first_candidate_with_min_health(four_candidates)
    #hurt the guy
    if guy.letter == 'E':
        map[victim.y][victim.x].monster.hit_points -= elf_attacking_power
    else:
        map[victim.y][victim.x].monster.hit_points -= goblin_attacking_power
    map[y][x].monster.attacked = true
    map[y][x].monster.moved = true
    echo map[y][x].monster, " assaulted ", map[victim.y][victim.x].monster, " at ", victim.x, ", ", victim.y 
    #remove the dead guy
    if map[victim.y][victim.x].monster.hit_points <= 0:
        echo map[victim.y][victim.x].monster, " died at (", victim.x, ", ", victim.y, ")" 
        map[victim.y][victim.x].monster = no_monster
    return true

type Square = object
    x,y: int

proc has_any_monster_adjacent(x,y: int, letter: char): bool =
    if y > 0:
        let monster = map[y - 1][x].monster
        if monster.exists and monster.letter != letter:
            return true
    if x > 0:
        let monster = map[y][x - 1].monster
        if monster.exists and monster.letter != letter:
            return true
    if x < width - 1:
        let monster = map[y][x + 1].monster
        if monster.exists and monster.letter != letter:
            return true
    if y < height - 1:
        let monster = map[y + 1][x].monster
        if monster.exists and monster.letter != letter:
            return true
    return false

proc find_squares_in_range(letter: char): seq[Square] =
    result = newSeq[Square]()
    for y, line in map:
        for x, elem in line:
            if map[y][x].is_floor and not map[y][x].monster.exists:
                if has_any_monster_adjacent(x,y, letter):
                    result.add(Square(x:x, y:y))
    result = deduplicate( result )
    return result

proc get_adjacent_candidates(x,y: int, that_map: seq[seq[Cell]]) : seq[Square] =
    result = newSeq[Square]()
    if y > 0:
        let cell = that_map[y-1][x]
        if cell.is_floor and (not cell.monster.exists) and cell.cost == -1:
            result.add( Square(x: x, y: y-1) )
    if x > 0:
        let cell = that_map[y][x-1]
        if cell.is_floor and (not cell.monster.exists) and cell.cost == -1:
            result.add( Square(x: x-1, y: y) )
    if x < width - 1:
        let cell = that_map[y][x+1]
        if cell.is_floor and (not cell.monster.exists) and cell.cost == -1:
            result.add( Square(x: x+1, y: y) )
    if y < height - 1:
        let cell = that_map[y+1][x]
        if cell.is_floor and (not cell.monster.exists) and cell.cost == -1:
            result.add( Square(x: x, y: y+1) )
    return result

type Step = object
    x,y,cost: int

proc get_adjacent_costs(x,y: int, that_map: seq[seq[Cell]]) : seq[Step] =
    result = newSeq[Step]()
    if y > 0:
        let cell = that_map[y-1][x]
        if cell.is_floor and (not cell.monster.exists) and cell.cost > -1:
            result.add( Step(x: x, y: y-1, cost:cell.cost) )
    if x > 0:
        let cell = that_map[y][x-1]
        if cell.is_floor and (not cell.monster.exists) and cell.cost > -1:
            result.add( Step(x: x-1, y: y, cost:cell.cost) )
    if x < width - 1:
        let cell = that_map[y][x+1]
        if cell.is_floor and (not cell.monster.exists) and cell.cost > -1:
            result.add( Step(x: x+1, y: y, cost:cell.cost) )
    if y < height - 1:
        let cell = that_map[y+1][x]
        if cell.is_floor and (not cell.monster.exists) and cell.cost > -1:
            result.add( Step(x: x, y: y+1, cost:cell.cost) )
    return result
   
proc flood_fill(x,y: int): seq[seq[Cell]] =
    result = map #copy
    let this_square = Square(x:x, y:y)
    var current_squares = @[this_square]
    var current_value = 0
    while current_squares.len > 0:
        #paint the current squares
        for elem in current_squares:
            result[elem.y][elem.x].cost = current_value
        #get the candidates
        var candidates = newSeq[Square]()
        for elem in current_squares:
            let sub_cands = get_adjacent_candidates(elem.x, elem.y, result)
            for sub_elem in sub_cands:
                candidates.add( sub_elem )
        current_squares = deduplicate(candidates)
        current_value += 1
    return result

proc take_one_step(that_map: seq[seq[Cell]], min_x, min_y: int): (int, int) = 
    var x = min_x
    var y = min_y
    var iterations = 0
    while true:
        echo "searching at (",x, ", ", y, ") = ", that_map[y][x].cost
        iterations += 1
        if that_map[y][x].cost == 1:
            return (x, y)
        var candidates = newSeq[Step]()
        if y > 0:
            let cell = that_map[y-1][x]
            if cell.cost > -1:
                candidates.add( Step(x: x, y: y-1, cost: cell.cost) )
        if x > 0:
            let cell = that_map[y][x-1]
            if cell.cost > -1:
                candidates.add( Step(x: x-1, y: y, cost: cell.cost) )
        if x < width - 1:
            let cell = that_map[y][x+1]
            if cell.cost > -1:
                candidates.add( Step(x: x+1, y: y, cost: cell.cost) )
        if y < height - 1:
            let cell = that_map[y+1][x]
            if cell.cost > -1:
                candidates.add( Step(x: x, y: y+1, cost: cell.cost) )
        echo "candidates: ", candidates
        var min_cost = 999999
        for elem in candidates:
            if elem.cost < min_cost:
                min_cost = elem.cost
        #get the min candidate that's first in reading order
        var min_read_cost = 9999999
        var min_x = -1
        var min_y = -1
        for elem in candidates:
            let reading_cost = elem.y * width + elem.x
            if min_cost == that_map[elem.y][elem.x].cost and reading_cost < min_read_cost:
                min_x = elem.x
                min_y = elem.y
                min_read_cost = reading_cost
        x = min_x
        y = min_y
        if iterations > 100:
            quit(1)

proc move(x,y: int, guy: Monster, list_targets: seq[Square]) : (int, int) =
    #sanity check. Do not move if there's a monster next to us
    let four_candidates = get_four_monsters_around(x, y, guy.letter)
    if four_candidates.len > 0:
        return (-1, -1)
    #make a copy of the map for this guy and flood fill it
    let this_map = flood_fill(x,y)
    echo_map_flood(x,y,this_map, true)
    #check costs at those squares
    var min_cost = 9999999
    for elem in list_targets:
        let this_cost = this_map[elem.y][elem.x].cost
        if this_cost < min_cost and this_cost > -1:
            min_cost = this_cost
    #get all squares for min_cost
    var candidates = newSeq[Square]()
    for elem in list_targets:
        let this_cost = this_map[elem.y][elem.x].cost
        if this_cost == min_cost:
            candidates.add(elem)
   #now get the one that's first reading order
    var min_read_cost = 9999999
    var min_x = -1
    var min_y = -1
    for elem in candidates:
        let reading_cost = elem.y * width + elem.x
        if reading_cost < min_read_cost:
            min_x = elem.x
            min_y = elem.y
            min_read_cost = reading_cost
    echo "move guy ", guy, " at (", x, ", ", y, ") to (", min_x, ", ", min_y,")" 
    #now do reverse flood, from the minimum target
    if min_x < 0 and min_y < 0:
        return (-1, -1)
    let that_map = flood_fill(min_x, min_y)
    let first_step_candidates = get_adjacent_costs(x,y, that_map)
    if first_step_candidates.len == 0:
        return (-1, -1)
    #get min cost
    var cand_reverse_cost = 999999
    for reverse_index, elem in first_step_candidates:
        if elem.cost > -1 and elem.cost < cand_reverse_cost:
            cand_reverse_cost = elem.cost
    var cand_read_cost = 999999
    var step_x = -1
    var step_y = -1
    for reverse_index, elem in first_step_candidates:
        let read_cost = width * elem.y + elem.x
        if cand_reverse_cost == elem.cost and read_cost < cand_read_cost:
            cand_read_cost = read_cost
            step_x = elem.x
            step_y = elem.y
    #finally, actually move
    if step_x > -1 and step_y > -1:
        map[y][x].monster = no_monster
        map[step_y][step_x].monster = guy
        map[step_y][step_x].monster.moved = true
        echo "moved guy ", map[step_y][step_x].monster, " at (", x, ", ", y, ") to (", step_x, ", ", step_y,")" 
        return (step_x, step_y)
    return (-1, -1)
proc move_everyone() =
    for y, line in map:
        for x, elem in line:
            if elem.monster.exists and not map[y][x].monster.moved:
                echo "\n--------------------------------------------------\n"
                #check if it can attack
                let list_targets = find_squares_in_range(elem.monster.letter)
                let (new_x, new_y) = move(x,y, elem.monster, list_targets)
                if new_x > -1 and new_y > -1:
                    if map[new_y][new_x].monster.exists and not map[new_y][new_x].monster.attacked:
                        if not attack(new_x,new_y, elem.monster):
                            echo map[new_y][new_x].monster, " at ", "(", new_x, ", ", new_y ,") moved but didn't attack"
                        else: echo map[new_y][new_x].monster, " at ", "(", new_x, ", ", new_y ,") moved and attacked"
            if elem.monster.exists and not map[y][x].monster.attacked:
                if not attack(x,y, elem.monster):
                    echo map[y][x].monster, " at ", "(", x, ", ", y ,") didn't attack"
                else: echo map[y][x].monster, " at ", "(", x, ", ", y ,") did attack"

    #reset turns
    for y, line in map:
        for x, elem in line:
            if elem.monster.exists:
                map[y][x].monster.attacked = false
                map[y][x].monster.moved = false

echo_map()

var turns = 0
while did_either_side_win() == '-':
    echo "turn begin: ..........................................."
    move_everyone()
    echo_map()
    turns += 1
    echo "turn: ", turns, "\n"

var total_hit_points = 0
for line in map:
    for elem in line:
        if elem.monster.exists:
            total_hit_points += elem.monster.hit_points

proc count_elves(): int =
    result = 0
    for line in map:
        for elem in line:
            if elem.monster.letter == 'E':
                result += 1
    return result


#201292
echo "turns: ", turns, " total hp: ", total_hit_points
echo "result: ", turns * total_hit_points
echo "\none turn less\n"
turns -= 1
echo "turns: ", turns, " total hp: ", total_hit_points
echo "result: ", turns * total_hit_points
echo "\nelf count\n"
echo "original elves: ", elves_total
echo "current_elves: ", count_elves()