import parseutils
import sets
import sequtils
import tables

var value: int
var total = 0

var has_2 = initSet[string](256)
var has_3 = initSet[string](256)

proc has_repeated_letters(value: string, how_many: int): bool =
  var hash_chars = initCountTable[char]()
  let seq_chars = toSeq(value.items)

  for c in seq_chars:
    if hash_chars.contains(c):
      hash_chars.inc(c)
    else:
      hash_chars[c] = 1

  for c, count in hash_chars.pairs():
    if count == how_many:
      return true

  echo hash_chars

  return false

for line in lines "d2_input.txt":
  echo line
  if has_repeated_letters(line, 2):
    has_2.incl(line)
  if has_repeated_letters(line, 3):
    has_3.incl(line)

let total_2 = has_2.len()
let total_3 = has_3.len()

echo "has_2: ", has_2
echo "has_3: ", has_3

echo "checksum: ", total_2 * total_3