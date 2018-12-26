import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Day_08_a {

	public static void main(String[] args) throws Exception {
		List<String> allLines = Files.readAllLines(Paths.get("input.txt"));
		String theOneLine = allLines.get(0);
		String [] splitted = theOneLine.split(" ");
		List<String> dataStr = Arrays.asList(splitted);
		List<Integer> data = new ArrayList<Integer>();
		for (String elem: dataStr) {
			data.add(Integer.parseInt(elem));
		}
		//System.out.println("data: " + data + "\n");
		Node root = solveA(data, "", 'A');
		System.out.println("total part one = " + root.meta_total);
		int part_b_total = calc_node_value(root); 
		System.out.println("total part two = " + part_b_total);
	}
	
	private static int calc_node_value(Node node) {
		int result = 0;
		if (node.child_nodes <= 0) {
			for (Integer elem : node.metadata) {
				result += elem;
			}
		} else {
			for (Integer elem : node.metadata) {
				if (elem > node.child_nodes || elem < 1) {
					continue;
				}
				Node sub = node.childs.get(elem - 1);
				result += calc_node_value(sub);
			}
		}
		return result;
	}

	public static final int CHILD_AMOUNT = 0, METADATA_AMOUNT = 1, CHILD_NODES = 2, META_NODES = 3;
	
	public static Node solveA(List<Integer> data, String prefix, char name) {
		Node result = new Node();
		
		int stage = 0;
		
		for(int index = 0; index < data.size(); index++) {
			//System.out.println(prefix + name + " stage: " + stage + " index: " + index + " list: " + remove_top(data, index));
			if (stage == CHILD_AMOUNT) {
				result.child_nodes = data.get(index);
				result.entries_read++;
				//System.out.println(prefix + "child entries: " + result.child_nodes);
				stage++;
				continue;
			}
			if (stage == METADATA_AMOUNT) {
				result.meta_entries = data.get(index);
				result.entries_read++;
				//System.out.println(prefix + "meta_entries : " + result.meta_entries);
				stage++;
				continue;
			}
			if (stage == CHILD_NODES){
				List<Integer> sub_list = remove_top(data, 2);
				for (int child_index = 0; child_index < result.child_nodes; child_index++) {
					//System.out.println(prefix + "sub node: " + child_index);
					Node sub = solveA(sub_list, prefix + "\t",(char) (name + child_index + 1));
					sub_list = remove_top(sub_list, sub.entries_read);
					result.meta_total += sub.meta_total;
					result.childs.add(sub);
				}
				//if there's no child nodes, we wasted an element. Recovering it
					index--;
				stage++;
				continue;
			}
			if (stage == META_NODES) {
				for (int sub_index = 0; sub_index < result.child_nodes; sub_index++) {
					Node sub = result.childs.get(sub_index);
					index += sub.entries_read;
					result.entries_read += sub.entries_read;
				}
				for (int meta_index = 0; meta_index < result.meta_entries; meta_index++) {
					List<Integer> meta_list = remove_top(data, index);
					//System.out.println(prefix + "meta node: " + meta_index + " gran index: " + index + " data: " + meta_list);
					index++;
					int meta = meta_list.get(0);
					result.meta_total += meta;
					result.metadata.add(meta);
					result.entries_read++;
				}
				if (result.meta_entries <= 0) {
					index--;
				}
				//System.out.println(prefix + name + " meta_nodes = " + result.metadata);
				break;
			}
		}
		//System.out.println(prefix + "returning node: " + name + " read: " + result.entries_read);
		return result;
	}

	private static List<Integer> remove_top(List<Integer> data, int from) {
		List<Integer> result = new ArrayList<Integer>();
		for (int index = 0; index < data.size(); index++) {
			if (index >= from) {
				result.add(data.get(index));
			}
		}
		return result;
	}

}

class Node {
	public int entries_read;
	public int child_nodes, meta_entries, meta_total;
	public List<Node> childs;
	public List<Integer> metadata;
	
	public Node() {
		this.entries_read = 0;
		this.child_nodes = 0;
		this.meta_entries = 0;
		this.meta_total = 0;
		childs = new ArrayList<Node>();
		metadata = new ArrayList<Integer>();
	}
}