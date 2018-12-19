import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times
 
let file_name = "d16_input.txt"

let OP = 0
let A = 1
let B = 2
let R = 3
let C = 3

type Entry = object
    before: seq[int]
    data: seq[int]
    after: seq[int]

var value : Entry
var data = newSeq[Entry]()
for line in lines file_name:
    var opcode, a, b, final: int
    if scanf(line, "Before:$s[$i, $i, $i, $i]", opcode, a, b, final):
        value.before = @[opcode, a, b, final]
#        echo "before: ", value.before
    if scanf(line, "$i $i $i $i", opcode, a, b, final):
        value.data = @[opcode, a, b, final]
#        echo "data: ", value.data
    if scanf(line, "After:$s[$i, $i, $i, $i]", opcode, a, b, final):
        value.after = @[opcode, a, b, final]
#        echo "after: ", value.after
        data.add(value)

let INVALID = @[-1,-1,-1,-1]

proc addr(before, data: seq[int]): seq[int] =
    result = before
    try:
        let temp = before[data[A]] + before[data[B]]
        result[data[C]] = temp
    except IndexError:
        echo "INVALID OP: ", before, data
        result = INVALID
    return result

proc addi(before, data: seq[int]): seq[int] =
    result = before
    try:
        let temp = before[data[A]] + data[B]
        result[data[C]] = temp
    except IndexError:
        echo "INVALID OP: ", before, data
        result = INVALID
    return result

proc mulr(before, data: seq[int]): seq[int] =
    result = before
    try:
        let temp = before[data[A]] * before[data[B]]
        result[data[C]] = temp
    except IndexError:
        echo "INVALID OP: ", before, data
        result = INVALID
    return result

proc muli(before, data: seq[int]): seq[int] =
    result = before
    try:
        let temp = before[data[A]] * data[B]
        result[data[C]] = temp
    except IndexError:
        echo "INVALID OP: ", before, data
        result = INVALID
    return result


proc banr(before, data: seq[int]): seq[int] =
    result = before
    try:
        let temp = before[data[A]] and before[data[B]]
        result[data[C]] = temp
    except IndexError:
        echo "INVALID OP: ", before, data
        result = INVALID
    return result

proc bani(before, data: seq[int]): seq[int] =
    result = before
    try:
        let temp = before[data[A]] and data[B]
        result[data[C]] = temp
    except IndexError:
        echo "INVALID OP: ", before, data
        result = INVALID
    return result

proc borr(before, data: seq[int]): seq[int] =
    result = before
    try:
        let temp = before[data[A]] or before[data[B]]
        result[data[C]] = temp
    except IndexError:
        echo "INVALID OP: ", before, data
        result = INVALID
    return result

proc bori(before, data: seq[int]): seq[int] =
    result = before
    try:
        let temp = before[data[A]] or data[B]
        result[data[C]] = temp
    except IndexError:
        echo "INVALID OP: ", before, data
        result = INVALID
    return result

proc setr(before, data: seq[int]): seq[int] =
    result = before
    try:
        result[data[C]] = before[data[A]]
    except IndexError:
        echo "INVALID OP: ", before, data
        result = INVALID
    return result

proc seti(before, data: seq[int]): seq[int] =
    result = before
    try:
        result[data[C]] = data[A]
    except IndexError:
        result = INVALID
        echo "INVALID OP: ", before, data
    return result

proc gtrr(before, data: seq[int]): seq[int] =
    result = before
    try:
        let first = before[data[A]]
        let second = before[data[B]]
        result[data[C]] = if first > second: 1
            else: 0
    except IndexError:
        result = INVALID
    return result

proc gtir(before, data: seq[int]): seq[int] =
    result = before
    try:
        let first = data[A]
        let second = before[data[B]]
        result[data[C]] = if first > second: 1
            else: 0
    except IndexError:
        result = INVALID
    return result

proc gtri(before, data: seq[int]): seq[int] =
    result = before
    try:
        let first =  before[data[A]]
        let second = data[B]
        result[data[C]] = if first > second: 1
            else: 0
    except IndexError:
        result = INVALID
    return result

proc eqrr(before, data: seq[int]): seq[int] =
    result = before
    try:
        let first = before[data[A]]
        let second = before[data[B]]
        result[data[C]] = if first == second: 1
            else: 0
    except IndexError:
        result = INVALID
    return result

proc eqir(before, data: seq[int]): seq[int] =
    result = before
    try:
        let first = data[A]
        let second = before[data[B]]
        result[data[C]] = if first == second: 1
            else: 0
    except IndexError:
        result = INVALID
    return result

proc eqri(before, data: seq[int]): seq[int] =
    result = before
    try:
        let first =  before[data[A]]
        let second = data[B]
        result[data[C]] = if first == second: 1
            else: 0
    except IndexError:
        result = INVALID
    return result


var entry_test = Entry()
entry_test.before = @[3,2,1,1]
entry_test.data = @[9,2,1,2] 
entry_test.after = @[3,2,2,1]

let test_val = mulr(entry_test.before, entry_test.data)

proc test_all_opcodes(entry: Entry): Table[string, bool] =
    result = initTable[string, bool]()
    result["addr"] = (addr(entry.before, entry.data) == entry.after)
    result["addi"] = (addi(entry.before, entry.data) == entry.after)
    result["mulr"] = (mulr(entry.before, entry.data) == entry.after)
    result["muli"] = (muli(entry.before, entry.data) == entry.after)
    result["banr"] = (banr(entry.before, entry.data) == entry.after)
    result["bani"] = (bani(entry.before, entry.data) == entry.after)
    result["borr"] = (borr(entry.before, entry.data) == entry.after)
    result["bori"] = (bori(entry.before, entry.data) == entry.after)
    result["setr"] = (setr(entry.before, entry.data) == entry.after)
    result["seti"] = (seti(entry.before, entry.data) == entry.after)
    result["gtrr"] = (gtrr(entry.before, entry.data) == entry.after)
    result["gtri"] = (gtri(entry.before, entry.data) == entry.after)
    result["gtir"] = (gtir(entry.before, entry.data) == entry.after)
    result["eqrr"] = (eqrr(entry.before, entry.data) == entry.after)
    result["eqri"] = (eqri(entry.before, entry.data) == entry.after)
    result["eqir"] = (eqir(entry.before, entry.data) == entry.after)

proc only(table: Table[string,bool], desired = true) : (int, seq[string]) =
    var seq_result = newSeq[string]()
    for key, val in table.pairs:
        if val == desired:
            seq_result.add(key)

    return (seq_result.len, seq_result)     

echo "test_val: ", test_val, " ==? ", (test_val == entry_test.after)
let test_results = test_all_opcodes(entry_test)
echo "test all: ", test_results

echo "true only : ", only(test_results ,true)
echo "false only: ", only(test_results ,false)

var total = 0
var surely = initTable[int,string]()
var twos = initTable[int, HashSet[string]]()
var threes = initTable[int, HashSet[string]]()
var fours = initTable[int, HashSet[string]]()

var numbers_x_opcodes = initTable[int, HashSet[string]]()
var opcodes_x_numbers = initTable[string, seq[int]]()

for index, elem in data:
    let this_summary = test_all_opcodes(elem)
    let (count, trues) = only(this_summary)
    let number = elem.data[0]
    if not numbers_x_opcodes.contains(number):
        numbers_x_opcodes[number] = initSet[string]()
    for trutru in trues:
        numbers_x_opcodes[number].incl( trutru )

    if count >= 3:
        total += 1
    if count == 1:
        for sub_elem in trues: #this should only be one
            let opcode = trues[0]
            let entry = data[index]
            let number = entry.data[0]
            surely[number] = opcode
            break
    if count == 2:
        for sub_elem in trues: #this should only be one
            if not twos.contains(number):
                twos[number] = initSet[string]()
            twos[number].incl( sub_elem )
    if count == 3:
        for sub_elem in trues: #this should only be one
            let entry = data[index]
            let number = entry.data[0]
            if not threes.contains(number):
                threes[number] = initSet[string]()
            threes[number].incl( sub_elem )
    if count == 4:
        for sub_elem in trues: #this should only be one
            let entry = data[index]
            let number = entry.data[0]
            if not fours.contains(number):
                fours[number] = initSet[string]()
            fours[number].incl( sub_elem )

for index, elem in data:
    if elem.data[0] == 13:
        let table = test_all_opcodes(elem)
        if not table["gtrr"]:
            echo "\ncounterexample to gtrr"
        if not table["gtri"]:
            echo "\ncounterexample to gtri"
        if not table["eqir"]:
            echo "\ncounterexample to eqir"
        if not table["eqri"]:
            echo "\ncounterexample to eqri"


echo "total: ", total

echo "surely: ", surely

echo "twos: ", twos

echo "threes: ", threes

echo "fours: ", fours, "\n"

var filtered_opcodes = numbers_x_opcodes

let figured_out = @["eqri", "eqrr", "eqir", "gtri", "gtrr", "gtir", "setr", "banr",
    "bani", "seti", "mulr", "muli", "bori", "borr"]

#filter the opcodes
for key, val in numbers_x_opcodes.pairs:
    var values_to_delete = newSeq[string]()
    for elem in val:
        if figured_out.contains( elem ):
            values_to_delete.add(elem)
    for elem in values_to_delete:
        numbers_x_opcodes[key].excl(elem)


for index in 0..15:
    echo $index, " = ", numbers_x_opcodes[index]



