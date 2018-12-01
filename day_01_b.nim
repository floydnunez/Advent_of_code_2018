import parseutils
import sets

var value: int
var first_repeated: int64
var total = 0

var seen = initSet[int64]()
seen.incl(0)
var not_seen_already = true

  while(not_seen_already): #brute force as fuck
    for line in lines "d1_input.old.txt":
    discard parseInt(line, value)
    total += value
    if total in seen:
      echo "SEEN ALREADY = ", total
      first_repeated = total
      not_seen_already = false
      break
    else:
      incl(seen, total)

echo "seen: ", seen
echo "seen size: ", seen.len()
echo "total: ", total
echo "first_repeated : ", first_repeated
