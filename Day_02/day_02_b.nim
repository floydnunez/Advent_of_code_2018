import parseutils
import sets
import sequtils
import tables

var value: int
var total = 0

proc remove_char(line: string, col: int): string =
  var seq_string = toSeq(line.items)
  var new_seq = newSeq[char]()
  for i,c in seq_string:
    if i+1 != col:
      new_seq.add(c)
  return cast[string](new_seq)

proc check_repeated_without_char_in_pos(lines: seq[string], col: int): bool =
  var seen = initSet[string](256)
  var lines_removed = newSeq[string]()

  for line in lines:
    let line_removed = remove_char(line, col)
    if not seen.contains(line_removed):
      seen.incl(line_removed)
    else:
      echo "RESULT: ", line_removed
      return true
  return false

var last_length = 0
var lines = newSeq[string]()

for line in lines "d2_input.txt":
  if last_length != 0 and line.len != last_length:
    echo "error, all lines must be the exact same length"
    quit(QuitFailure)
  else:
    last_length = line.len
  lines.add(line)
echo "last_length: ", last_length
echo lines

for pos in 1..last_length:
  if check_repeated_without_char_in_pos(lines, pos):
    break

