import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

public class Day_20 {

	public static final Map<Coord, Room> all_rooms = new HashMap<Coord, Room>();
	public static final Map<String, String> opposites = new HashMap<String, String>();
	public static final Set<String> directions = new TreeSet<String>();
	public static final Coord zero = new Coord(0, 0);
	
	public static void main(String[] args) throws Exception {
		String filename = "d20_input_test11.txt";
		boolean debug = !filename.equals("d20_input.txt");
		List<String> allLines = Files.readAllLines(Paths.get(filename));
		String line = allLines.get(0);
		String dataStr = line.substring(1, line.length() - 1);
		String[] chars = dataStr.split("");
		List<String> charList = Arrays.asList(chars);
		System.out.println(dataStr);

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
		flood_fill(root, 0);
		Iterator<Room> iter = all_rooms.values().iterator();
		int at_least_1000 = 0;
		int max_cost = 0;
		int min_x = 0, min_y = 0, max_x = 0, max_y = 0;
		while (iter.hasNext()) {
			Room r = iter.next();
			System.out.println("" + r);
			if (r.cost > max_cost) {
				max_cost = r.cost;
			}
			if (r.cost >= 1000) {
				at_least_1000 += 1;
			}
			if (min_x > r.coord.x) {
				min_x = r.coord.x;
			}
			if (min_y > r.coord.y) {
				min_y = r.coord.y;
			}
			if (max_x < r.coord.x) {
				max_x = r.coord.x;
			}
			if (max_y < r.coord.y) {
				max_y = r.coord.y;
			}
		}
		
		int height = max_y - min_y + 1;
		int width = max_x - min_x + 1;
		List<List<String>> map = init_map2(height, width);
		write_rooms2(all_rooms, map, min_x, min_y);
		if (debug) {
			System.out.println(dataStr);
		}
		print_map2(height, width, map);
		System.out.println("total: " + total + 
			" max cost: " + max_cost + " from (" + min_x + ", " + min_y + ") to (" + max_x + ", " + max_y+ ") " +
			" size: (" + width + ", " + height + ") at least 1000? " + at_least_1000  );
	}

	private static void print_map2(int fheight, int fwidth, List<List<String>> map) {
		int height = 2 * fheight + 1;
		int width= 2 * fwidth + 1;
		for (int yndex = 0; yndex < height; yndex++) {
			String ll = "";
			for (int xndex = 0; xndex < width; xndex++) {
				ll += map.get(yndex).get(xndex);
			}
			if ((yndex + 1) % 2 == 0 ) {
				System.out.println((yndex / 2) + "\t" + ll);
			}
			else {
				System.out.println(" " + "\t" + ll);
			}
		}
	}

	private static void print_map(int height, int width, List<List<String>> map) {
		for (int yndex = 0; yndex < height; yndex++) {
			String ll = "";
			for (int xndex = 0; xndex < width; xndex++) {
				ll += map.get(yndex).get(xndex);
			}
			System.out.println(yndex + "\t" + ll);
		}
	}

	private static List<List<String>> init_map2(int fheight, int fwidth) {
		int height = 2 * fheight + 1;
		int width= 2 * fwidth + 1;
		List<List<String>> map = new ArrayList<List<String>>();
		for (int yndex = 0; yndex < height; yndex++) {
			map.add(new ArrayList<String>());
			for (int xndex = 0; xndex < width; xndex++) {
				if (yndex == height - 1 || xndex == width - 1) {
					map.get(yndex).add("#");
				} else {
					map.get(yndex).add(" ");
				}
			}
		}
		return map;
	}

	private static List<List<String>> init_map(int height, int width) {
		List<List<String>> map = new ArrayList<List<String>>();
		for (int yndex = 0; yndex < height; yndex++) {
			map.add(new ArrayList<String>());
			for (int xndex = 0; xndex < width; xndex++) {
				map.get(yndex).add(" ");
			}
		}
		return map;
	}

	private static void write_rooms2(Map<Coord, Room> allRooms, List<List<String>> map, int min_x, int min_y) {
		Iterator<Room> iter = all_rooms.values().iterator();
		while(iter.hasNext()) {
			Room room = iter.next();
			int x = room.coord.x - min_x;
			int y = room.coord.y - min_y;
			int real_x = 2 * x;
			int real_y = 2 * y;
			map.get(real_y).set(real_x, "#");
			map.get(real_y).set(real_x + 1, room.has("N")? "-": "#");
			map.get(real_y + 1).set(real_x, room.has("W")? "|": "#");
			map.get(real_y + 1).set(real_x + 1, (room.coord.equals(zero))? "X": ".");
		}
	}

	private static void write_rooms(Map<Coord, Room> allRooms, List<List<String>> map, int min_x, int min_y) {
		Iterator<Room> iter = all_rooms.values().iterator();
		while(iter.hasNext()) {
			Room room = iter.next();
			System.out.println(room.coord + " + " + min_x + ", " + min_y);
			int x = room.coord.x - min_x;
			int y = room.coord.y - min_y;
			System.out.println("writing to " + x + " , " + y);
			map.get(y).set(x, calc_room_symbol(room));
		}
	}

	private static String calc_room_symbol(Room room) {
		String result = "#";
		if (room.doors.containsKey("N") && room.doors.containsKey("E") && room.doors.containsKey("S") && room.doors.containsKey("W") ) {
			result = "#";
		}
		else if (room.doors.containsKey("E") && room.doors.containsKey("S") && room.doors.containsKey("W") ) {
			result = "m";
		}
		else if (room.doors.containsKey("N") && room.doors.containsKey("S") && room.doors.containsKey("W") ) {
			result = "3";
		}
		else if (room.doors.containsKey("N") && room.doors.containsKey("E") && room.doors.containsKey("W") ) {
			result = "±";
		}
		else if (room.doors.containsKey("N") && room.doors.containsKey("E") && room.doors.containsKey("S") ) {
			result = "E";
		}
		else if (room.doors.containsKey("N") && room.doors.containsKey("W") ) {
			result = "/";
		}
		else if (room.doors.containsKey("N") && room.doors.containsKey("E") ) {
			result = "\\";
		}
		else if (room.doors.containsKey("N") && room.doors.containsKey("S") ) {
			result = "|";
		}
		else if (room.doors.containsKey("E") && room.doors.containsKey("W") ) {
			result = "=";
		}
		else if (room.doors.containsKey("E") && room.doors.containsKey("S") ) {
			result = "/";
		}
		else if (room.doors.containsKey("S") && room.doors.containsKey("W") ) {
			result = "\\";
		}
		else if (room.doors.containsKey("N") ) {
			result = "'";
		}
		else if (room.doors.containsKey("E") ) {
			result = "»";
		}
		else if (room.doors.containsKey("S") ) {
			result = ".";
		}
		else if (room.doors.containsKey("W") ) {
			result = "«";
		}
		return result;
	}

	public static void flood_fill(Room root, int cost) {
		Set<Room> to_flood = new HashSet<Room>();
		to_flood.add(root);
		while(! to_flood.isEmpty()) {
			//paint current rooms
			for(Room room: to_flood) {
				if (room.cost == -1) {
					room.cost = cost;
				}
			}
			//get the candidates
			Set<Room> candidates = new HashSet<Room>();
			for(Room room: to_flood) {
				Iterator<Door> doors = room.doors.values().iterator();
				while(doors.hasNext()) {
					Door door = doors.next();
					if (door.to.cost == -1) { //do not repaint rooms
						candidates.add(door.to);
					}
				}
			}
			//dangerous, empty the main set
			to_flood.clear();
			to_flood.addAll(candidates);
			cost++;
		}
	}

	public static int parse_room(List<String> seq, int pos, Room first_room) {
		Room curr_room = first_room;
		while (true) {
			String letter = seq.get(pos);
			if (directions.contains(letter)) {
				curr_room = join_room(curr_room, letter);
			} else if (letter.equals("(")) {
				int subindex = parse_room(seq, pos + 1, curr_room);
				pos = subindex;
			} else if (letter.equals(")")) {
				return pos;
			} else if (letter.equals("|")) {
				pos++;
				curr_room = first_room;
				continue;
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
		System.out.println("join: " + orig.coord + " by " + dir + " to " + new_pos);
		if (!all_rooms.containsKey(new_pos)) {
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

		return new Coord(x, y);
	}

}

class Coord {
	@Override
	public int hashCode() {
		final int prime = 10007; //31;
		int result = 1;
		result = prime * result + x;
		result = prime * result + y;
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
		Coord other = (Coord) obj;
		if (x != other.x)
			return false;
		if (y != other.y)
			return false;
		return true;
	}

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
	public int cost;

	public Room(Coord coord) {
		this.coord = coord;
		doors = new HashMap<String, Door>();
		cost = -1;
	}

	public boolean has(String dir) {
		return doors.containsKey(dir);
	}
	
	public String toString() {
		String door_str = "";
		Iterator<String> iter = doors.keySet().iterator();
		while (iter != null && iter.hasNext()) {
			String dir = iter.next();
			door_str += "(" + dir + ") -> " + doors.get(dir).to.coord + " ";
		}
		return "R '" + cost + "'\t" + coord + " => " + (door_str.isEmpty() ? "X" : door_str);
	}

	@Override
	public int hashCode() {
		final int prime = 10009;//31;
		int result = 1;
		result = prime * result + ((coord == null) ? 0 : coord.hashCode());
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
		Room other = (Room) obj;
		if (coord == null) {
			if (other.coord != null)
				return false;
		} else if (!coord.equals(other.coord))
			return false;
		return true;
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
		Door other = (Door) obj;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		return true;
	}

}