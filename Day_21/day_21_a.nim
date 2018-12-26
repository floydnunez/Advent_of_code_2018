import os, strutils, rdstdin, strscans, sequtils, tables, algorithm, sets 
let file_name = "d21_input.txt"

var o = open("cycles_value.txt", fmWrite)
var p = open("value_cycles.txt", fmWrite)
var q = open("answers.txt", fmWrite)

type Line = object
    opcode: string
    a, b, c: int

#var register = @[10961197,0,0,0,0,0]
var register = @[16716591,0,0,0,0,0]

proc addr(data: Line) =
    let temp = register[data.a] + register[data.b]
    register[data.c] = temp

proc addi(data: Line) =
    let temp = register[data.a] + data.b
    register[data.c] = temp

proc mulr(data: Line) =
    let temp = register[data.a] * register[data.b]
    register[data.c] = temp

proc muli(data: Line) =
    let temp = register[data.a] * data.b
    register[data.c] = temp

proc banr(data: Line) =
    let temp = register[data.a] and register[data.b]
    register[data.c] = temp

proc bani(data: Line) =
    let temp = register[data.a] and data.b
    register[data.c] = temp

proc borr(data: Line) =
    let temp = register[data.a] or register[data.b]
    register[data.c] = temp

proc bori(data: Line) =
    let temp = register[data.a] or data.b
    register[data.c] = temp

proc setr(data: Line) =
    register[data.c] = register[data.a]

proc seti(data: Line) =
    register[data.c] = data.a

proc gtrr(data: Line) =
    let first = register[data.a]
    let second = register[data.b]
    register[data.c] = if first > second: 1
        else: 0

proc gtir(data: Line) =
    let first = data.a
    let second = register[data.b]
    register[data.c] = if first > second: 1
        else: 0

proc gtri(data: Line) =
    let first =  register[data.a]
    let second = data.b
    register[data.c] = if first > second: 1
        else: 0

proc eqrr(data: Line) =
    let first = register[data.a]
    let second = register[data.b]
    register[data.c] = if first == second: 1
        else: 0

proc eqir(data: Line) =
    let first = data.a
    let second = register[data.b]
    register[data.c] = if first == second: 1
        else: 0

proc eqri(data: Line) =
    let first = register[data.a]
    let second = data.b
    register[data.c] = if first == second: 1
        else: 0


var data_line : Line
var instructions = newSeq[Line]()
var ins_pointer: int

for line in lines file_name:
    var opcode: string
    var a, b, c: int
    if scanf(line, "#ip $i", ins_pointer):
        echo "instruction pointer: ", ins_pointer
        register[ins_pointer] = 0
    if scanf(line, "$w $i $i $i", opcode, a, b, c):
        data_line = Line(opcode: opcode, a:a, b:b, c:c)
        instructions.add( data_line ) 
        if (opcode == "mulr" or opcode == "muli") and c == ins_pointer:
            echo "exit condition: ", line, " at ", instructions.len - 1
        
#for index, inst in instructions:
#    echo $index, " = ", inst

var cycles = 0
var hacked = false
let step = 10000000

var answers = initSet[int]()

while register[ins_pointer] >= 0 and register[ins_pointer] < instructions.len:
    let old_inst = register[ins_pointer]
    let old_register = register
    let data = instructions[register[ins_pointer]]
    let opcode = data.opcode
    #hack
#[
    if (not hacked) and old_inst == 3 and register[5] == 10551355:
        register[1] = 5
        register[3] = 2110271
        echo "hack: ", register
        hacked = true
]#
    if opcode == "bori": bori(data)
    if opcode == "muli": muli(data)
    if opcode == "banr": banr(data)
    if opcode == "bani": bani(data)
    if opcode == "gtir": gtir(data)
    if opcode == "setr": setr(data)
    if opcode == "addr": addr(data)
    if opcode == "eqir": eqir(data)
    if opcode == "seti": seti(data)
    if opcode == "addi": addi(data)
    if opcode == "eqrr": eqrr(data)
    if opcode == "eqri": eqri(data)
    if opcode == "borr": borr(data)
    if opcode == "gtrr": gtrr(data)
    if opcode == "mulr": mulr(data)
    if opcode == "gtri": gtri(data)
#[    if register[ins_pointer] == 28:
        #echo $old_inst, " : ", data, "   \t ", old_register, " > ", register, " n ", register[ins_pointer] + 1
        if answers.contains(register[4]):
            echo "repeat! cycle: ", cycles, " value: ", register[4]
            q.flushFile()
            q.close()
            quit(1)
        answers.incl(register[4])
        q.writeLine(register[4])
        o.writeLine( $cycles & " - " & $register[4] )
        p.writeLine( $register[4] & " - " & $cycles )
    if cycles %% step == 0:
        o.flushFile()
        p.flushFile()
        q.flushFile()
]#
    register[ins_pointer] += 1
    cycles += 1
#[
    if cycles > 10000 * step:
        o.close()
        p.close()
        quit(1)
]#
#16777215 too high
#641049 wrong
echo register
echo "result: ", register[0], " in cycles: ", cycles