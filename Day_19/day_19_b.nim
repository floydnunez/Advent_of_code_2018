import os, strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times#, nimprof 
let file_name = "d19_opt.txt"

type Line = object
    opcode: string
    a, b, c: int

var register = @[1,0,0,0,0,0]

proc addr(data: Line) {.inline.} =
    let temp = register[data.a] + register[data.b]
    register[data.c] = temp

proc addi(data: Line) {.inline.} =
    let temp = register[data.a] + data.b
    register[data.c] = temp

proc mulr(data: Line) {.inline.} =
    let temp = register[data.a] * register[data.b]
    register[data.c] = temp

proc muli(data: Line) {.inline.} =
    let temp = register[data.a] * data.b
    register[data.c] = temp

proc banr(data: Line) {.inline.} =
    let temp = register[data.a] and register[data.b]
    register[data.c] = temp

proc bani(data: Line) {.inline.} =
    let temp = register[data.a] and data.b
    register[data.c] = temp

proc borr(data: Line) {.inline.} =
    let temp = register[data.a] or register[data.b]
    register[data.c] = temp

proc bori(data: Line) {.inline.} =
    let temp = register[data.a] or data.b
    register[data.c] = temp

proc setr(data: Line) {.inline.} =
    register[data.c] = register[data.a]

proc seti(data: Line) {.inline.} =
    register[data.c] = data.a

proc gtrr(data: Line) {.inline.} =
    let first = register[data.a]
    let second = register[data.b]
    register[data.c] = if first > second: 1
        else: 0

proc gtir(data: Line) {.inline.} =
    let first = data.a
    let second = register[data.b]
    register[data.c] = if first > second: 1
        else: 0

proc gtri(data: Line) {.inline.} =
    let first =  register[data.a]
    let second = data.b
    register[data.c] = if first > second: 1
        else: 0

proc eqrr(data: Line) {.inline.} =
    let first = register[data.a]
    let second = register[data.b]
    register[data.c] = if first == second: 1
        else: 0

proc eqir(data: Line) {.inline.} =
    let first = data.a
    let second = register[data.b]
    register[data.c] = if first == second: 1
        else: 0

proc eqri(data: Line) {.inline.} =
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

let ini_time = cpuTime()

var cycles = 0
var hacked = false
while register[ins_pointer] >= 0 and register[ins_pointer] < instructions.len:
    let old_inst = register[ins_pointer]
    let old_register = register
    let data = instructions[register[ins_pointer]]
    let opcode = data.opcode
    #hack
    var main_loop_done = false
    if old_inst == 3:
        #echo "entering main loop!"
        while true:
            if cycles %% 500_000_000 == 0:
                echo register, " at ", cycles
            cycles += 1
            #echo register
            register[4] = register[1] * register[3] #3
            if register[4] == register[5]: #4
                register[4] = 1
                register[0] += register[1] #7
            else:
                register[4] = 0 #end 4
            register[3] += 1 #8
            if register[3] > register[5]: #9
                register[4] = 1
            else:
                register[4] = 0 #end 9
                register[2] = 3 #11 (it's actually 2, but it adds 1 to it at the end of every "real" loop)
                continue
            if register[4] == 1: 
                register[2] = 12 #10
                register[1] += 1 #12
                if register[1] > register[5]: #13 #end condition!!!
                    register[4] = 1
                    register[2] = 15 + 1 #14
                    register[2] *= register[2] #16
                    register[2] += 1 #end of loop when it ends
                    echo "END: ", register, " at ", cycles
                    quit(0)
                else:
                    register[4] = 0
                    #14 does nothing in this case
                    register[2] = 3 #was 1, but adds 1 for that instruction and instruction 2
                    register[3] = 1 #2. Loops

    
    if main_loop_done:
        continue

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
#    if register[ins_pointer] == 16 or cycles %% 10000000 == 0:
    if cycles %% 10000 == 0:   
        echo register, " at ", cycles
    #if cycles > 7299900:
    echo $old_inst, " : ", data, "   \t ", old_register, " -> ", register, " next instruction: ", register[ins_pointer] + 1, " cycles: ", cycles
    register[ins_pointer] += 1
    cycles += 1
#    if cycles > 1000000:
#        quit(1)

let end_time = cpuTime()

echo register
echo "result: ", register[0], " in cycles: ", cycles, " -> ", end_time - ini_time, " seconds "


