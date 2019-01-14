import strutils, rdstdin, strscans, sequtils, tables, algorithm, sets, times
 
let file_name = "d7_input_test3.txt"

type Node = object
    id: string
    next: seq[string]
    prev: seq[string]

var nodes = initTable[string, Node]()

func to_seq_of_char(candidates: seq[string]) : seq[char] =
    result = newSeq[char]()
    for elem in candidates:
        result.add elem[0]
    return result

func has_all_letters(word: string, candidates: seq[string]) : bool = 
    let cands = to_seq_of_char(candidates)
    for elem in cands:
        if not word.contains elem:
            return false
    return true

for line in lines file_name:
    var req, step: string
    if scanf(line, "Step $w must be finished before step $w can begin.", req, step):
        echo "step: ", step 
        var step_node = if nodes.contains(step): nodes[step]
            else: Node(id: step, next: newSeq[string](), prev: newSeq[string]())

        var req_node = if nodes.contains(req): nodes[req]
            else: Node(id: req, next: newSeq[string](), prev: newSeq[string]())

        req_node.next.add step
        step_node.prev.add req 
        nodes[step] = step_node
        nodes[req] = req_node

var firsts = newSeq[string]()
for code, node in nodes.pairs():
    if node.prev.len == 0:
        firsts.add code

var last: Node
for code, node in nodes.pairs():
    if node.next.len == 0:
        last = node
        echo "last? ", node


echo nodes
sort(firsts, system.cmp[string])
echo "firsts: ", firsts
echo "last: ", last

var current_node = nodes[firsts[0]]

var availables = newSeq[string]()
firsts.delete(0)
if firsts.len > 0:
    availables = firsts


echo "\n\nprocessing\n" 

var processed_string = ""
var count = 0
while current_node != last:
    echo "processing ", current_node, " current string: ", processed_string
    processed_string &= current_node.id
    for elem in current_node.next:
        if not availables.contains(elem) and not processed_string.contains(elem):
            availables.add elem
    sort(availables, system.cmp[string])
    echo "\tavailables: ", availables
    var changed_node = false
    for index, elem in availables:
        let node = nodes[elem]
        if has_all_letters(processed_string, node.prev):
            changed_node = true
            current_node = node
            availables.delete(index)
            break
        else: 
            echo "Step ", elem, " requires ", node.prev, " which ain't done. it is followed by: ", node.next 
    if not changed_node:
        echo "yo, what the fuck"
        quit(2)

processed_string &= last.id

echo "result:\t", processed_string
    

