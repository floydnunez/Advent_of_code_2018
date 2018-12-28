import sequtils, strutils, rdstdin, strscans, algorithm, tables

let file_name = "d4_input_sorted.txt"

type
    Wake_Sleep = object
        sleeping: bool #0 = sleep, 1 = wake
        minute: int
        month: int
        day: int

type
    Schedule = ref object
        id: int
        day: int
        month: int
        state: seq[int]
        wake_sleep_list: seq[Wake_Sleep]
        sleep_calendar: OrderedTable[string, seq[bool]]
        most_slept: seq[int]
        slept_minutes: OrderedTable[int, int] #minute of the hour x total slept

proc new_schedule(id: int, day: int, month: int): Schedule = 
    result = Schedule(id: id, day: day, month: month)
    result.state = newSeq[int](60)
    result.wake_sleep_list = newSeq[Wake_Sleep]()
 
var last_schedule: Schedule
var all_schedules = initOrderedTable[int,Schedule]()

for line in lines file_name:
    #echo line
    var year, month, day, hour, minute, id: int
    if scanf(line, "[$i-$i-$i $i:$i] Guard #$i begins shift", year, month, day, hour, minute, id):
        if all_schedules.contains(id):
            last_schedule = all_schedules[id]
        else:
            last_schedule = new_schedule(id, day, month)
            all_schedules[id] = last_schedule
        #echo "guard #", id, " begins shift!"
    if scanf(line, "[$i-$i-$i $i:$i] falls asleep", year, month, day, hour, minute):
        last_schedule.wake_sleep_list.add(Wake_Sleep(sleeping: true, minute: minute, month: month, day: day))    
        #echo "guard #", last_schedule.id, " falls asleep"
    if scanf(line, "[$i-$i-$i $i:$i] wakes up", year, month, day, hour, minute):
        last_schedule.wake_sleep_list.add(Wake_Sleep(sleeping: false, minute: minute, month: month, day: day))   
        #echo "guard #", last_schedule.id, " wakes up "
        

echo "\n\n\n"

func calc_value(x: Wake_Sleep): int =
    let sleep_val = if x.sleeping:
        0
    else:
        1
    return (x.month * 12 * 32 * 2 + x.day * 31 * 2 + x.minute + sleep_val)

func sort_wake_sleep(x, y: Wake_Sleep): int =
    return x.calc_value() - y.calc_value()

func new_day_sleep_schedule(): seq[bool] =
    result = newSeq[bool](60)
    for elem in 0..result.high:
        result[elem] = false

for id, sche in all_schedules.pairs:
    var list = sche.wake_sleep_list
    echo "sche: ", sche.wake_sleep_list.len
    sort[Wake_Sleep](list, sort_wake_sleep)
    var sleeps_per_day = initOrderedTable[string, seq[bool]]()
    for ws in list:
        #echo "Guard #", sche.id, " sleeps: ", ws.sleeping, " the ", ws.month, "-", ws.day, " at ", ws.minute, " val: ", ws.calc_value()
        let day_val = $ws.month & "-" & $ws.day
        var sleep_for_the_day = if sleeps_per_day.contains(day_val):
            sleeps_per_day[day_val]
        else:
            new_day_sleep_schedule()
        if ws.sleeping: 
            #echo "sleeping: ", $sche.id, " at ", ws.month, "-", ws.day, " : ", ws.minute, " to ", sleep_for_the_day.high
            for minute_of_sleep in ws.minute..sleep_for_the_day.high:
                sleep_for_the_day[minute_of_sleep] = true
        else:
            #echo "waking  : ", $sche.id, " at ", ws.month, "-", ws.day, " : ", ws.minute, " to ", sleep_for_the_day.high
            for minute_of_sleep in ws.minute..sleep_for_the_day.high:
                sleep_for_the_day[minute_of_sleep] = false
        sleeps_per_day[day_val] = sleep_for_the_day
    sche.sleep_calendar = sleeps_per_day
#    for day, val in sleeps_per_day.pairs():
#        echo " day: ", day, " : ", val

echo "\n\n"

var max_sleep = 0
var max_sleep_id = 0
var most_slept_global: seq[int]
var max_sche: Schedule

for id, sche in all_schedules.pairs:
    echo "schedule for guard #", sche.id
    var total = 0
    var most_slept = newSeq[int](60)
    for min in 0..most_slept.high:
        most_slept[min] = 0
    for day, sleeps in sche.sleep_calendar.pairs:
        for ii, elem in sleeps:
            if elem:
                total += 1
                most_slept[ii] = most_slept[ii] + 1
    sche.most_slept = most_slept
    if total > max_sleep:
        max_sleep = total
        max_sleep_id = sche.id
        most_slept_global = most_slept
        max_sche = sche

echo "max_sleep: ", max_sleep, " for guard: ", max_sleep_id
echo most_slept_global
for i, total in most_slept_global:
    echo i, " = ", total
echo " \t:000000000011111111112222222222333333333344444444445555555555"
echo " \t:012345678901234567890123456789012345678901234567890123456789"
for day, calendar in max_sche.sleep_calendar.pairs:
    var binary_rep = ""
    for min in calendar:
        if min:
            binary_rep &= "#"
        else:
            binary_rep &= "." 
    echo day, "\t:", binary_rep


let magic_number = 1000 * 1000

for id, sche in all_schedules.pairs:
    var max_per_minute = initOrderedTable[int, int]() #minute of the hour x total slept
    for slept_per_minute in sche.sleep_calendar.values:
        for index, slept in slept_per_minute:
            var total_slept = 0
            if max_per_minute.contains(index):
                total_slept = max_per_minute[index]
            if slept: total_slept += magic_number
            max_per_minute[index] = total_slept 
    sche.slept_minutes = max_per_minute
    echo "id ", id, "\t: ", max_per_minute

var max_total = 0
var max_minute = 0
var max_id = 0

for id, sche in all_schedules.pairs:
    let max_per_minute = sche.slept_minutes
    for minute, total in max_per_minute.pairs:
        if total > max_total:
            max_total = total
            max_minute = minute
            max_id = id

echo "max_minute: ", max_minute
echo "max_id: ", max_id

echo "result: ", max_minute * max_id

echo "fin"
