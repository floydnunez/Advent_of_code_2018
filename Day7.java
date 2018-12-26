import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Day7 {

    public static void main(String[] args) throws Exception {
	Map<String, Node> nodes = new HashMap<String, Node>();
	String filename = "input.txt";
	List<String> allLines = Files.readAllLines(Paths.get(filename));
	int elves = 0;
	int wait; 
	int step;
	if (filename.equals("input.txt")) {
	    elves = 5;
	    wait = 1;
	    step = 60;
	} else {
	    elves = 2;
	    wait = 500;
	    step = 0;
	}
	Pattern pattern = Pattern.compile("Step (\\w{1}) must be finished before step (\\w{1}) can begin\\.");
	Set<String> reqs = new HashSet<String>();
	Set<String> results = new HashSet<String>();
	for (String line : allLines) {
	    Matcher m = pattern.matcher(line);
	    if (m.find()) {
		String req = m.group(1);
		String end = m.group(2);
		System.out.println(req + " -> " + end);
		reqs.add(req);
		results.add(end);
		Node req_node = nodes.containsKey(req)? nodes.get(req): new Node(req);
		Node end_node = nodes.containsKey(end)? nodes.get(end): new Node(end);
		req_node.next.add(end_node);
		end_node.prev.add(req_node);
		nodes.put(req, req_node);
		nodes.put(end, end_node);
	    } else {
		System.out.println("LINE " + line + " WEIRD");
		System.exit(1);
	    }
	}
	Set<String> first_str = find_first_node(reqs, results);
	System.out.println(nodes);
	System.out.println(first_str);
	System.out.println("fin");

	List<Node> done_nodes = new ArrayList<Node>();
	List<Node> pending_nodes = new ArrayList<Node>(nodes.values());
	List<Node> available = toList(first_str, nodes);
	List<Node> current = new ArrayList<Node>();
	for (int index = 0; index < elves; index++) {
	    Node next = get_next_possible_node(pending_nodes, done_nodes);
	    if (next != null) {
		current.add(next);
	    }
	}
	System.out.println("current: " + available);
	String result = "";
 	for (int second = 0; !current.isEmpty(); second++) {
 	    List<Node> to_eliminate = new ArrayList<Node>();
	    for (Node node : current) {
		node.spent++;
		if (node.spent == node.getTime()) {//done with this node!
		    System.out.println("done! " + node + " : " + node.spent + " ==? " + node.getTime());
		    to_eliminate.add(node);
		    done_nodes.add(node);
		    result += node.name;
		}
	    }
	    for (Node node : to_eliminate) {
		current.remove(node);
	    }
	    if (current.size() < elves) {
		//pump into current...how many?
		int how_many = elves - current.size();
		for (int index = 0; index < how_many; index++) {
		    Node next = get_next_possible_node(pending_nodes, done_nodes);
		    if (next != null) {
			current.add(next);
		    }
		}
		Collections.sort(current);
	    } 	
	    System.out.println("t: " + second + " = " + result + " current.size = " + current);
	    Thread.sleep(wait);
	}
 	System.out.println("result: " + result);
    }

    private static Node get_next_possible_node(List<Node> pending_nodes, List<Node> done_nodes) {
	Collections.sort(pending_nodes);
	for (Node node : pending_nodes) {
	    //check dones
	    boolean all_done = true;
	    for (Node requirement: node.prev) {
		if (!done_nodes.contains(requirement)) {
		    all_done = false;
		}
	    }
	    if (all_done) {
		pending_nodes.remove(node);
		return node;
	    }
	}
	return null;
    }

    private static List<Node> first(List<Node> available, int elves) {
	List<Node> result = new ArrayList<Node>();
	for (int index = 0; index < elves && index < available.size(); index++) {
	    result.add(available.get(index));
	}
	return result;
    }

    private static List<Node> toList(Set<String> first_str, Map<String, Node> nodes) {
	List<Node> result = new ArrayList<Node>();
	Iterator<String> iter = first_str.iterator();
	while (iter != null && iter.hasNext()) {
	    String key = iter.next();
	    result.add(nodes.get(key));
	}
	return result;
    }

    private static Set<String> find_first_node(Set<String> reqs, Set<String> results) {
	Set copy = new TreeSet<String>();
	copy.addAll(reqs);
	copy.removeAll(results);
	return copy;
    }

}

class Node implements Comparable {
    public final String name;
    public final Set<Node> next, prev;
    public int spent = 0;
    
    public Node(String nn) {
	name = nn;
	next = new TreeSet<Node>();
	prev = new TreeSet<Node>();
    }

    public int getTime() {
	char n = name.charAt(0);
	return (int)((int)n - (int)'A' + 1 + 60);
    }
    
    public String toString() {
	String result;
	if (next.isEmpty()) {
	    result = "(" + name + ")";
	} else {
	    String list_data = "[";
	    Iterator<Node> iter = next.iterator();
	    while (iter.hasNext()) {
		Node node = iter.next();
		list_data += node.name;
		if (iter.hasNext()) {
		    list_data += ", ";
		}
	    }
	    list_data += "]";
	    result =  "(" + name + ") -> " + list_data;
	}
	result += " t:" + getTime() + " s:" + spent;
	return result;
    }

    @Override
    public int compareTo(Object arg) {
	if (arg instanceof Node) {
	    Node other = (Node) arg;
	    return this.name.compareTo(other.name);
	} else {
	    return 0;
	}
    }

    @Override
    public int hashCode() {
	final int prime = 31;
	int result = 1;
	result = prime * result + ((name == null) ? 0 : name.hashCode());
	return result;
    }

    @Override
    public boolean equals(Object obj) {
	if (this == obj)
	    return true;
	if (obj == null)
	    return false;
	if (getClass() != obj.getClass())
	    return false;
	Node other = (Node) obj;
	if (name == null) {
	    if (other.name != null)
		return false;
	} else if (!name.equals(other.name))
	    return false;
	return true;
    }
}