import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Day_22 {

	public static int width, height, target_x, target_y, depth;

	public static long iterations = 0;

	public static final long _20183 = 20183l;
	public static final long _16807 = 16807l;
	public static final long _48271 = 48271l;
	public static final long _3 = 3l;
	public static final double margin = 2;
	public static long _depth;
	public static final String allowed_a = "|";
	public static final String allowed_b = "=";

	public static final String allowed_c = ".";
	public static final String allowed_d = "|";

	public static void main(String[] args) throws Exception {
		boolean test = false;
		if (test) {
			target_x = 5;
			target_y = 5;
			depth = 510;
		} else {
			target_x = 13;
			target_y = 734;
			depth = 7305;
		}
		_depth = (long) depth;
		width = (int) ((target_x + 1) * margin);
		height = (int) ((target_y + 1) * margin);
		System.out.println("depth: " + depth + " target in (" + width + ", " + height + ")");

		List<List<Square>> map = new ArrayList<List<Square>>();
		// basic rules first
		for (int yndex = 0; yndex < height; yndex++) {
			map.add(new ArrayList<Square>());
			for (int xndex = 0; xndex < width; xndex++) {
				Square Square = new Square(xndex, yndex);
				apply_basic_rules(Square, xndex, yndex);
				map.get(yndex).add(Square);
			}
		}
		// multiply complex rule
		for (int yndex = 1; yndex < height; yndex++) {
			List<Square> row = map.get(yndex);
			for (int xndex = 1; xndex < width; xndex++) {
				Square square = row.get(xndex);
				boolean advanced = false;
				if (xndex != target_x || yndex != target_y) {
					Square prev = row.get(xndex - 1);
					Square above = map.get(yndex - 1).get(xndex);
					square.geoIndex = prev.erosionLevel * above.erosionLevel;
					square.erosionLevel = (square.geoIndex + _depth) % _20183;
					advanced = true;
				}
			}
		}
		int above_y = target_y - 1;
		int prev_x = target_x - 1;
		System.out
				.println("above: (" + target_x + ", " + above_y + ") = " + map.get(above_y).get(target_x).erosionLevel);
		System.out.println("prev : (" + prev_x + ", " + target_y + ") = " + map.get(target_y).get(prev_x).erosionLevel);
		// apply rules
		for (int yndex = 0; yndex < height; yndex++) {
			List<Square> row = map.get(yndex);
			for (int xndex = 0; xndex < width; xndex++) {
				Square square = row.get(xndex);
				long decision = square.erosionLevel % 3;
				if (decision == 0) {
					square.type = ".";
				} else if (decision == 1) {
					square.type = "=";
				} else if (decision == 2) {
					square.type = "|";
				}
			}
		}

		print_map(map);
		int risk = calc_risk_levels(map);
		// List<ListSet> all_paths = generate_all_paths(map);
		// print_all_paths(all_paths);
		// int minimum_traversal = go_through_all(all_paths);
		Square from = map.get(0).get(0);
		Square to = map.get(target_y).get(target_x);
		flood_fill(map, allowed_a, allowed_b, to, from);
		print_map_flood(map);
		Square max = get_max_cost(map);
		if (to.equals(max)) {
			System.out.println("success! cost: " + max.cost);
		} else {
			System.out.println("failure, no valid route :( max: " + max);
		}
		reset_map(map);
		System.out.println("switch--------------");
		Square mid = find_closest_to(map, from);
		flood_fill(map, allowed_c, allowed_c, from, mid);
		print_map_flood(map);
		System.out.println("find mid: " + mid);
		System.out.println("risk = " + risk);
		// System.out.println("all existing paths: " + all_paths.size());
		// System.out.println("min traversal: " + minimum_traversal);
	}

	private static void reset_map(List<List<Square>> map) {
		for (int yndex = 0; yndex < height; yndex++) {
			for (int xndex = 0; xndex < width; xndex++) {
				Square sq = map.get(yndex).get(xndex);
				sq.cost = -1;
			}
		}
	}

	private static void print_map_flood(List<List<Square>> map) {
		for (int yndex = 0; yndex < height; yndex++) {
			String line = "";
			for (int xndex = 0; xndex < width; xndex++) {
				Square sq = map.get(yndex).get(xndex);
				if (sq.cost == -1) {
					line += " ";
				} else if (sq.cost < 5) {
					line += ".";
				} else if (sq.cost < 20) {
					line += ":";
				} else if (sq.cost < 50) {
					line += "+";
				} else if (sq.cost < 100) {
					line += "n";
				} else if (sq.cost < 250) {
					line += "m";
				}
			}
			System.out.println(line);
		}
		System.out.println("\n");
	}

	private static Square find_closest_to(List<List<Square>> map, Square from) {
		Square sq = null;
		int min_cost = 9999999;
		for (int yndex = 0; yndex < height; yndex++) {
			for (int xndex = 0; xndex < width; xndex++) {
				Square this_square = map.get(yndex).get(xndex);
				if (min_cost > this_square.cost && this_square.cost > -1) {
					min_cost = this_square.cost;
					sq = this_square;
				}
			}
		}
		return sq;
	}

	private static Square get_max_cost(List<List<Square>> map) {
		int max_cost = 0;
		Square max_sq = null;
		for (int yndex = 0; yndex < height; yndex++) {
			for (int xndex = 0; xndex < width; xndex++) {
				Square sq = map.get(yndex).get(xndex);
				if (max_cost < sq.cost) {
					max_cost = sq.cost;
					max_sq = sq;
				}
			}
		}
		return max_sq;
	}

	private static void flood_fill(List<List<Square>> map, String allowed1, String allowed2, Square from, Square to) {
		Square origin = from;
		List<Square> current_squares = new ArrayList<Square>();
		current_squares.add(origin);
		int current_value = 0;
		while (!current_squares.isEmpty()) {
			for (Square square : current_squares) {
				if (square.cost == -1) {
					square.cost = current_value;
				}
			}
			current_value++;
			List<Square> candidates = new ArrayList<Square>();
			for (Square square : current_squares) {
				List<Square> adjacents = get_adjacent(map, square, allowed1, allowed2);
				for (Square candidate : adjacents) {
					if (candidate.equals(to)) {
						candidate.cost = current_value;
						return;
					}
					candidates.add(candidate);
				}
			}
			current_squares = candidates;
		}
	}

	private static List<Square> get_adjacent(List<List<Square>> map, Square last, String allowed1, String allowed2) {
		List<Square> result = new ArrayList<Square>();
		// top
		if (last.y > 0) {
			Square square = map.get(last.y - 1).get(last.x);
			if (square.type.equals(allowed1) || square.type.equals(allowed2)) {
				if (square.cost == -1) {
					result.add(square);
				}
			}
		}
		// bottom
		if (last.y < height - 1) {
			Square square = map.get(last.y + 1).get(last.x);
			if (square.type.equals(allowed1) || square.type.equals(allowed2)) {
				if (square.cost == -1) {
					result.add(square);
				}
			}
		}
		// left
		if (last.x > 0) {
			Square square = map.get(last.y).get(last.x - 1);
			if (square.type.equals(allowed1) || square.type.equals(allowed2)) {
				if (square.cost == -1) {
					result.add(square);
				}
			}
		}
		// right
		if (last.x < width - 1) {
			Square square = map.get(last.y).get(last.x + 1);
			if (square.type.equals(allowed1) || square.type.equals(allowed2)) {
				if (square.cost == -1) {
					result.add(square);
				}
			}
		}
		return result;
	}

	private static void print_all_paths(List<ListSet> all_paths) {
		for (ListSet path : all_paths) {
			for (int yndex = 0; yndex < height; yndex++) {
				String line = "";
				for (int xndex = 0; xndex < width; xndex++) {
					Coord coord = new Coord(xndex, yndex);
					if (path.poss.containsKey(coord)) {
						int position = path.poss.get(coord);
						line += position;
					} else {
						line += " ";
					}
				}
				System.out.println(line);
			}
			System.out.println("finished: " + path.finished + " - valid? " + path.valid);
		}
	}

	private static int go_through_all(List<ListSet> all_paths) {
		return 0;
	}

	private static List<ListSet> generate_all_paths(List<List<Square>> map) {
		List<ListSet> all_paths = new ArrayList<ListSet>();
		Square from = map.get(0).get(0);
		Square to = map.get(target_y).get(target_x);

		Square current = from;
		ListSet first_path = new ListSet();
		first_path.add(current);
		all_paths.add(first_path);
		while (true) {
			List<ListSet> next_paths = step_one(map, all_paths, to);
			all_paths = next_paths;
			if (all_finished(next_paths)) {
				break;
			}
		}

		return all_paths;
	}

	private static boolean all_finished(List<ListSet> next_paths) {
		boolean all_finished = true;
		for (ListSet path : next_paths) {
			if (path.valid && !path.finished) {
				all_finished = false;
			}
		}
		return all_finished;
	}

	private static List<ListSet> step_one(List<List<Square>> map, List<ListSet> all_paths, Square destiny) {
		List<ListSet> result = new ArrayList<ListSet>();
		for (ListSet path : all_paths) {
			if (path.valid && !path.finished) {
				iterations++;
				if (iterations % 100 == 0) {
					System.out.println("iterations: " + iterations);
				}
				Square last = path.last();
				List<Square> next_ones = get_all_next_squares(map, path, last);
				for (Square next : next_ones) {
					// check we haven't traversed these
					if (!path.has(next)) {
						ListSet next_path = copy_path(path);
						next_path.add(next);
						// did we arrive to the finish?
						if (next.equals(destiny)) {
							next_path.finished = true;
						}
						result.add(next_path);
					}
				}
				if (next_ones.isEmpty()) {
					path.valid = false;
					// gotta keep this one
					result.add(path);
				}
			} else {
				// we gotta keep the invalid paths and the finished ones
				result.add(path);
			}
		}
		return result;
	}

	private static ListSet copy_path(ListSet path) {
		ListSet result = new ListSet();
		for (Square square : path.list) {
			result.add(square);
		}
		return result;
	}

	private static List<Square> get_all_next_squares(List<List<Square>> map, ListSet path, Square last) {
		List<Square> result = new ArrayList<Square>();
		// top
		if (last.y > 0) {
			Square square = map.get(last.y - 1).get(last.x);
			if (!path.has(square)) {
				result.add(square);
			}
		}
		// bottom
		if (last.y < height - 1) {
			Square square = map.get(last.y + 1).get(last.x);
			if (!path.has(square)) {
				result.add(square);
			}
		}
		// left
		if (last.x > 0) {
			Square square = map.get(last.y).get(last.x - 1);
			if (!path.has(square)) {
				result.add(square);
			}
		}
		// right
		if (last.x < width - 1) {
			Square square = map.get(last.y).get(last.x + 1);
			if (!path.has(square)) {
				result.add(square);
			}
		}
		return result;
	}

	private static int calc_risk_levels(List<List<Square>> map) {
		int total = 0;
		for (int yndex = 0; yndex < target_y + 1; yndex++) {
			List<Square> row = map.get(yndex);
			for (int xndex = 0; xndex < target_x + 1; xndex++) {
				Square square = row.get(xndex);
				if (square.type.equals(".")) {
					total += 0;
				} else if (square.type.equals("=")) {
					total += 1;
				} else if (square.type.equals("|")) {
					total += 2;
				}
			}
		}
		return total;
	}

	private static void print_map(List<List<Square>> map) {
		for (int yndex = 0; yndex < height; yndex++) {
			String line = "";
			for (int xndex = 0; xndex < width; xndex++) {
				if (xndex == 0 && yndex == 0) {
					line += "M";
				} else if (xndex == target_x && yndex == target_y) {
					line += "T";
				} else {
					line += map.get(yndex).get(xndex).type;
				}
			}
			System.out.println(line);
		}
		System.out.println("\n");
	}

	private static void apply_basic_rules(Square square, int x, int y) {
		boolean applied = false;
		if (x == 0 && y == 0) {
			square.geoIndex = 0l;
			applied = true;
		} else if (x == target_x && y == target_y) {
			square.geoIndex = 0l;
			applied = true;
		} else {
			if (y == 0) {
				square.geoIndex = _16807 * x;
				applied = true;
			}
			if (x == 0) {
				square.geoIndex = _48271 * y;
				applied = true;
			}
		}
		if (applied) {
			square.erosionLevel = (square.geoIndex + _depth) % _20183;
		}
	}
	// answer: 10204
}

class ListSet {
	public final List<Square> list;
	public final Map<Coord, Integer> poss;
	public final Set<Square> set;
	public boolean valid, finished;

	public ListSet() {
		list = new ArrayList<Square>();
		set = new HashSet<Square>();
		poss = new HashMap<Coord, Integer>();
		valid = true;
		finished = false;
	}

	public Square last() {
		if (list.size() > 0) {
			return list.get(list.size() - 1);
		}
		return null;
	}

	public void add(Square t) {
		Coord coord = new Coord(t.x, t.y);
		poss.put(coord, list.size());
		list.add(t);
		set.add(t);
	}

	public boolean has(Square t) {
		return set.contains(t);
	}
}

class Square {
	public final int x, y;
	public String type;
	public long erosionLevel, geoIndex;

	@Override
	public String toString() {
		return "( " + x + ", " + y + ", " + type + ", " + cost + ")";
	}

	public int cost;

	public Square(int xx, int yy) {
		x = xx;
		y = yy;
		cost = -1;
	}

	@Override
	public int hashCode() {
		final int prime = 34543;
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
		Square other = (Square) obj;
		if (x != other.x)
			return false;
		if (y != other.y)
			return false;
		return true;
	}
}
