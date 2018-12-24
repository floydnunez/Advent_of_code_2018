import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times, typetraits#, nimprof
 
let file_name = "d23_input.txt"
let debug = "d23_input.txt" != file_name
#107272899 right answer

type Bot = object
    x, y, z, r: int

var all_bots = newSeq[Bot]()

var bot_file_index = 0
for line in lines file_name:
    var x,y,z,r: int
    if scanf(line, "pos=<$i,$i,$i>, r=$i", x,y,z,r):
        all_bots.add( Bot(x:x, y:y, z:z, r:r) )

#blatantly copied from Eriikko on reddit. Dunno why this works?
type Data = object
    val, priority: int

proc sort_data(x, y: Data): int =
    result = x.val - y.val
    return result

var all_data = newSeq[Data]()

for bot in all_bots:
    let d = abs(bot.x) + abs(bot.y) + abs(bot.z)
    all_data.add(Data(val: max(0, d - bot.r), priority: 1))
    all_data.add( Data(val: d + bot.r, priority: -1))

sort( all_data, sort_data )

echo all_data.len

var count = 0
var maxCount = 0
var result = 0

for dist in all_data:
    count += dist.priority    
    if count > maxCount:
        result = dist.val
        maxCount = count
echo result

