import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times
 
let file_name = "d16_input_b.txt"

let OP = 0
let A = 1
let B = 2
let R = 3
let C = 3

type Entry = object
    before: seq[int]
    data: seq[int]
    after: seq[int]


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


var register = @[0,0,0,0]

var data : seq[int]
var count = 0
for line in lines file_name:
    var opcode, a, b, final: int
    if scanf(line, "$i $i $i $i", opcode, a, b, final):
        data = @[opcode, a, b, final]
        echo "data: ", data
        if opcode == 0: register = bori(register, data)
        if opcode == 1: register = muli(register, data)
        if opcode == 2: register = banr(register, data)
        if opcode == 3: register = bani(register, data)
        if opcode == 4: register = gtir(register, data)
        if opcode == 5: register = setr(register, data)
        if opcode == 6: register = addr(register, data)
        if opcode == 7: register = eqir(register, data)
        if opcode == 8: register = seti(register, data)
        if opcode == 9: register = addi(register, data)
        if opcode == 10: register = eqrr(register, data)
        if opcode == 11: register = eqri(register, data)
        if opcode == 12: register = borr(register, data)
        if opcode == 13: register = gtrr(register, data)
        if opcode == 14: register = mulr(register, data)
        if opcode == 15: register = gtri(register, data)
    count += 1

echo register
