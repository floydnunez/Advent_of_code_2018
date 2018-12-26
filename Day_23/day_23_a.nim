import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times, typetraits#, nimprof
 
let file_name = "d23_input.txt"
let debug = "d23_input.txt" != file_name

type Bot = object
    x, y, z, r: int

var all_bots = newSeq[Bot]()

var max_rad = 0
var max_index = -1

var bot_file_index = 0
for line in lines file_name:
    var x,y,z,r: int
    if scanf(line, "pos=<$i,$i,$i>, r=$i", x,y,z,r):
        all_bots.add( Bot(x:x, y:y, z:z, r:r) )
        if r > max_rad:
            max_rad = r
            max_index = bot_file_index
    bot_file_index += 1

echo "all bots: ", all_bots.len
let max_bot = all_bots[max_index]
echo "max radius: ", max_rad
echo "max bot: ", max_bot

var in_range = newSeq[Bot]()

for bot in all_bots:
    #calc distance
    let manhattan = abs(max_bot.x - bot.x) + abs(max_bot.y - bot.y) + abs(max_bot.z - bot.z)
    echo bot, " md: ", manhattan
    if manhattan <= max_bot.r:
        in_range.add(bot)

echo in_range.len