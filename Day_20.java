import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

public class Day_20 {

    public static final Map<Coord, Room> all_rooms = new HashMap<Coord, Room>();
    public static final Map<String, String> opposites = new HashMap<String, String>();
    public static final Set<String> directions = new TreeSet<String>();
    
    public static void main(String[] args) throws Exception {
	List<String> allLines = Files.readAllLines(Paths.get("d20_input_test2.txt"));
	String line = allLines.get(0);
	System.out.println("line: " + line);
	String dataStr = line.substring(1, line.length() - 1);
	System.out.println("line: " + dataStr);
	String[] chars = dataStr.split("");
	List<String> charList = Arrays.asList(chars);
	System.out.println("chars: " + charList);

	directions.add("N");
	directions.add("W");
	directions.add("S");
	directions.add("E");
	
	opposites.put("N", "S");
	opposites.put("S", "N");
	opposites.put("W", "E");
	opposites.put("E", "W");
	
	Room root = new Room(new Coord(0, 0));
	all_rooms.put(root.coord, root);
	int total = parse_room(charList, 0, root);
	System.out.println("total: " + total);
	Iterator<Room> iter = all_rooms.values().iterator();
	while (iter.hasNext()) {
	    Room r = iter.next();
	    System.out.println("" + r);
	}
    }
    
    public static int parse_room(List<String> seq, int pos, Room first_room) {
	Room curr_room = first_room;
	while(true) {
	    String letter = seq.get(pos);
	    if (directions.contains(letter)) {
		curr_room = join_room(curr_room, letter);
	    } else if (letter.equals("(")) {
		int subindex = parse_room(seq, pos + 1, curr_room);
		pos = subindex;
	    } else if (letter.equals(")")) {
		return pos;
	    } else if (letter.equals("|")) {
		int subindex = parse_room(seq, pos + 1, first_room);
		pos = subindex;
	    }
	    pos++;
	    if (pos >= seq.size()) {
		break;
	    }
	}
	return pos;
    }
    
    public static Room join_room(Room orig, String dir) {
	Coord new_pos = calc_new_pos(orig.coord, dir);
	System.out.println("join: " + orig.coord + " by " + dir +" to " + new_pos);
	if (! all_rooms.containsKey(new_pos)) {
	    all_rooms.put(new_pos, new Room(new_pos));
	}
	Room new_room = all_rooms.get(new_pos);
	System.out.println("new room: " + new_room);
	Door orig_2_new = new Door(dir, orig, new_room);
	orig.doors.put(dir, orig_2_new);
	
	String opp_dir = opposites.get(dir);
	Door new_2_orig = new Door(opp_dir, new_room, orig);
	new_room.doors.put(opp_dir, new_2_orig);
	
	System.out.println("pos join orig: " + orig);
	System.out.println("pos join newr: " + new_room);
	return new_room;
    }
    
    public static Coord calc_new_pos(Coord orig, String dir) {
	int x = orig.x;
	int y = orig.y;
	
	if (dir.equals("N")) {
	    y -= 1;
	}
	if (dir.equals("S")) {
	    y += 1;
	}
	if (dir.equals("W")) {
	    x -= 1;
	}
	if (dir.equals("E")) {
	    x += 1;
	}
	
	
	return new Coord(x,y);
    }

}

class Coord {
    public final int x, y;
    public Coord(int xx, int yy) {
	x = xx;
	y = yy;
    }
    public String toString() {
	return "(" + x + ", " + y + ")"; 
    }
}

class Room {
    public final Coord coord;
    public final Map<String, Door> doors;
    public Room(Coord coord) {
	this.coord = coord;
	doors = new HashMap<String, Door>();
    }
    public String toString() {
	String door_str = "";
	Iterator<String> iter = doors.keySet().iterator();
	while(iter != null && iter.hasNext()) {
	    String dir = iter.next();
	    door_str += "(" + dir + ") -> " + doors.get(dir).to.coord + " ";
	}
	return "R " + coord + " => " + (door_str.isEmpty() ? "X" : door_str);
    }
}

class Door {
    public final String name;
    public final Room from;
    public final Room to;
    public Door(String name, Room from, Room to) {
	this.name = name;
	this.from = from;
	this.to = to;
    }
    
}