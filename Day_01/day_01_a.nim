import parseutils

var value: int
var total = 0

for line in lines "d1_input.txt":
  echo line
  discard parseInt(line, value)
  echo value
  total += value


echo "total: ", total