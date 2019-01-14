import java.util.ArrayList;
import java.util.List;

import edu.stanford.nlp.util.FixedPrioritiesPriorityQueue;
import edu.stanford.nlp.util.PriorityQueue;

public class Day_22 {
    // 1122, 1095, 1094, 974
    private static final boolean test = false;

    private static final int CHANGE_COST = 7;

    public static int width, height, target_x, target_y, depth;

    public static long iterations = 0;

    public static final long _20183 = 20183l;
    public static final long _16807 = 16807l;
    public static final long _48271 = 48271l;
    public static final long _3 = 3l;
    public static final double margin_x = 2.25;
    public static double margin_y = 1.01;
    public static long _depth;
    public static final String allowed_a = "|";
    public static final String allowed_b = "=";

    public static final String allowed_c = ".";
    public static final String allowed_d = "|";

    public static void main(String[] args) throws Exception {
	if (test) {
	    target_x = 10;
	    target_y = 10;
	    depth = 510;
	    margin_y = 1.4;
	} else {
	    target_x = 13;
	    target_y = 734;
	    depth = 7305;
	}
	_depth = (long) depth;
	width = (int) ((target_x + 1) * margin_x);
	height = (int) ((target_y + 1) * margin_y);
	System.out.println("depth: " + depth + " target in (" + width + ", " + height + ")");

	List<List<Square>> map_torch = new ArrayList<List<Square>>();
	// basic rules first
	for (int yndex = 0; yndex < height; yndex++) {
	    map_torch.add(new ArrayList<Square>());
	    for (int xndex = 0; xndex < width; xndex++) {
		Square Square = new Square(xndex, yndex, TOOL.TORCH);
		apply_basic_rules(Square, xndex, yndex);
		map_torch.get(yndex).add(Square);
	    }
	}
	// multiply complex rule
	for (int yndex = 1; yndex < height; yndex++) {
	    List<Square> row = map_torch.get(yndex);
	    for (int xndex = 1; xndex < width; xndex++) {
		Square square = row.get(xndex);
		boolean advanced = false;
		if (xndex != target_x || yndex != target_y) {
		    Square prev = row.get(xndex - 1);
		    Square above = map_torch.get(yndex - 1).get(xndex);
		    square.geoIndex = prev.erosionLevel * above.erosionLevel;
		    square.erosionLevel = (square.geoIndex + _depth) % _20183;
		    advanced = true;
		}
	    }
	}
	int above_y = target_y - 1;
	int prev_x = target_x - 1;
	System.out.println(
		"above: (" + target_x + ", " + above_y + ") = " + map_torch.get(above_y).get(target_x).erosionLevel);
	System.out.println(
		"prev : (" + prev_x + ", " + target_y + ") = " + map_torch.get(target_y).get(prev_x).erosionLevel);
	// apply rules
	for (int yndex = 0; yndex < height; yndex++) {
	    List<Square> row = map_torch.get(yndex);
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

	print_map(map_torch);
	int risk = calc_risk_levels(map_torch);
	Square from = map_torch.get(0).get(0);
	Square to = map_torch.get(target_y).get(target_x);
	System.out.println("risk: " + risk);
	List<List<Square>> map_climb = copy_map(map_torch, TOOL.CLIMB);
	List<List<Square>> map_neither = copy_map(map_torch, TOOL.NEITHER);
	System.out.println("pre flood fill");
	flood_fill(map_torch, map_climb, map_neither, from, to);
	System.out.println("calc path");
	 calc_path(map_torch, map_climb, map_neither, from, to);
	// print_map_flood(map_torch, map_climb, map_neither);
	print_path(map_torch, map_climb, map_neither);
	System.out.println("to: " + to);
	System.out.println("to torch: " + map_torch.get(target_y - 1).get(target_x));
	System.out.println("to torch: " + map_torch.get(target_y + 1).get(target_x));
	System.out.println("to torch: " + map_torch.get(target_y).get(target_x - 1));
	System.out.println("to torch: " + map_torch.get(target_y).get(target_x + 1));
	System.out.println("climb: ");
	System.out.println("to climb: " + map_climb.get(target_y).get(target_x));
	System.out.println("to climb: " + map_climb.get(target_y - 1).get(target_x));
	System.out.println("to climb: " + map_climb.get(target_y + 1).get(target_x));
	System.out.println("to climb: " + map_climb.get(target_y).get(target_x - 1));
	System.out.println("to climb: " + map_climb.get(target_y).get(target_x + 1));
	System.out.println("neither: ");
	System.out.println("to neither: " + map_neither.get(target_y).get(target_x));
	System.out.println("to neither: " + map_neither.get(target_y - 1).get(target_x));
	System.out.println("to neither: " + map_neither.get(target_y + 1).get(target_x));
	System.out.println("to neither: " + map_neither.get(target_y).get(target_x - 1));
	System.out.println("to neither: " + map_neither.get(target_y).get(target_x + 1));
    }

    private static void calc_path(List<List<Square>> map_torch, List<List<Square>> map_climb,
	    List<List<Square>> map_neither, Square from, Square to) {
	Square current = to;
	to.path = "X";
	while (true) {
	    List<Square> candidates = back_path_candidates(map_torch, map_climb, map_neither, current);
	    int min_cost = 9999999;
	    Square best_square = null;
	    for (Square cand : candidates) {
		if (cand.cost < min_cost) {
		    min_cost = cand.cost;
		    best_square = cand;
		}
	    }
	    best_square.path = "X";
	    current = best_square;
	    if (current.x == 0 && current.y == 0) {
		return;
	    }
	}
    }

    private static List<Square> back_path_candidates(List<List<Square>> map_torch, List<List<Square>> map_climb,
	    List<List<Square>> map_neither, Square last) {
	List<Square> result = new ArrayList<Square>();
	List<List<Square>> map = null;
	if (last.tool == TOOL.TORCH) {
	    map = map_torch;
	} else if (last.tool == TOOL.CLIMB) {
	    map = map_climb;
	} else if (last.tool == TOOL.NEITHER) {
	    map = map_neither;
	} else {
	    System.exit(1);
	}
	if (last.y > 0) {
	    Square square = map.get(last.y - 1).get(last.x);
	    if (square.cost != -1 && square.isPossible()) {
		result.add(square);
	    }
	}
	// bottom
	if (last.y < height - 1) {
	    Square square = map.get(last.y + 1).get(last.x);
	    if (square.cost != -1 && square.isPossible()) {
		result.add(square);
	    }
	}
	// left
	if (last.x > 0) {
	    Square square = map.get(last.y).get(last.x - 1);
	    if (square.cost != -1 && square.isPossible()) {
		result.add(square);
	    }
	}
	// right
	if (last.x < width - 1) {
	    Square square = map.get(last.y).get(last.x + 1);
	    if (square.cost != -1 && square.isPossible()) {
		result.add(square);
	    }
	}
	Square to_torch = map_torch.get(last.y).get(last.x);
	Square to_climb = map_climb.get(last.y).get(last.x);
	Square to_neither = map_neither.get(last.y).get(last.x);
	if (last.tool == TOOL.TORCH) {
	    if (to_climb.isPossible() && to_climb.cost != -1) {
		result.add(to_climb);
	    }
	    if (to_neither.isPossible() && to_neither.cost != -1) {
		result.add(to_neither);
	    }
	} else if (last.tool == TOOL.CLIMB) {
	    if (to_torch.isPossible() && to_torch.cost != -1) {
		result.add(to_torch);
	    }
	    if (to_neither.isPossible() && to_neither.cost != -1) {
		result.add(to_neither);
	    }
	} else if (last.tool == TOOL.NEITHER) {
	    if (to_torch.isPossible() && to_torch.cost != -1) {
		result.add(to_torch);
	    }
	    if (to_climb.isPossible() && to_climb.cost != -1) {
		result.add(to_climb);
	    }
	}
	return result;
    }

    private static List<List<Square>> copy_map(List<List<Square>> map_orig, int tool) {
	List<List<Square>> result = new ArrayList<List<Square>>();
	for (int yndex = 0; yndex < height; yndex++) {
	    List<Square> fila = new ArrayList<Square>();
	    for (int xndex = 0; xndex < width; xndex++) {
		Square old = map_orig.get(yndex).get(xndex);
		Square sq = new Square(old.x, old.y, tool);
		sq.type = old.type;
		fila.add(sq);
	    }
	    result.add(fila);
	}
	return result;
    }

    private static void print_map_flood(List<List<Square>> map_torch, List<List<Square>> map_climb,
	    List<List<Square>> map_neither) {
	for (int yndex = 0; yndex < height; yndex++) {
	    String line = "";
	    for (int xndex = 0; xndex < width; xndex++) {
		Square sq = map_torch.get(yndex).get(xndex);
		line = add_line_by_cost(line, sq);
	    }
	    line += "   ";
	    for (int xndex = 0; xndex < width; xndex++) {
		Square sq = map_climb.get(yndex).get(xndex);
		line = add_line_by_cost(line, sq);
	    }
	    line += "   ";
	    for (int xndex = 0; xndex < width; xndex++) {
		Square sq = map_neither.get(yndex).get(xndex);
		line = add_line_by_cost(line, sq);
	    }
	    System.out.println(line);
	}
	System.out.println("\n");
    }

    private static void print_path(List<List<Square>> map_torch, List<List<Square>> map_climb,
	    List<List<Square>> map_neither) {
	for (int yndex = 0; yndex < height; yndex++) {
	    String line = "";
	    for (int xndex = 0; xndex < width; xndex++) {
		Square t = map_torch.get(yndex).get(xndex);
		Square c = map_climb.get(yndex).get(xndex);
		Square n = map_neither.get(yndex).get(xndex);
		int paths = 0;
		if (!" ".equals(t.path)) {
		    paths += 1;
		}
		if (!" ".equals(c.path)) {
		    paths += 1;
		}
		if (!" ".equals(n.path)) {
		    paths += 1;
		}
		if (paths > 1) {
		    line += "%";
		} else if (paths == 1) {
		    line += "X";
		} else {
		    line += t.type;
		}
	    }
	    line += "   ";
	    for (int xndex = 0; xndex < width; xndex++) {
		Square t = map_torch.get(yndex).get(xndex);
		if (xndex == 0 && yndex == 0) {
		    line += "M";
		} else if (xndex == target_x && yndex == target_y) {
		    line += "T";
		} else {
		    line += t.type;
		}
	    }
	    System.out.println(line);
	}
	System.out.println("\n");
    }

    private static String add_line_by_cost(String line, Square sq) {
	if (sq.x == 0 && sq.y == 0) {
	    line += "M";
	} else if (sq.x == target_x && sq.y == target_y) {
	    line += "T";
	} else if (!sq.path.equals(" ")) {
	    line += sq.path;
	} else if (sq.cost == -1) {
	    line += " ";
	} else if (sq.cost < 3) {
	    line += ".";
	} else if (sq.cost < 9) {
	    line += ":";
	} else if (sq.cost < 18) {
	    line += "+";
	} else if (sq.cost < 28) {
	    line += "n";
	} else if (sq.cost < 42) {
	    line += "m";
	} else {
	    line += "#";
	}
	return line;
    }

    private static void flood_fill(List<List<Square>> map_torch, List<List<Square>> map_climb,
	    List<List<Square>> map_neither, Square from, Square to) {
	List<Square> current_squares = new ArrayList<Square>();
	current_squares.add(from);

	from.cost = 0;

	while (!current_squares.isEmpty()) {
	    List<Square> candidates = new ArrayList<Square>();
	    PriorityQueue<Square> adjacents = new FixedPrioritiesPriorityQueue<Square>();
	    for (Square square : current_squares) {
		PriorityQueue<Square> this_adjacents = get_adjacent(map_torch, map_climb, map_neither, square.x,
			square.y, square.tool, square.cost);
		join_priority_queue(adjacents, this_adjacents);
	    }
	    while (!adjacents.isEmpty()) {
		int priority = (int) - adjacents.getPriority();
		Square square = adjacents.removeFirst();
		if (square.cost == -1 && square.isPossible()) {
		    if (square.x == target_x && square.y == target_y && square.tool == TOOL.TORCH) {
			System.out.println("\n\n\nGOT TO THE EXIT: " + square + " p= " + -priority);
		    }
		    square.cost = priority; // do note the negative!
		    candidates.add(square);
		} else if (square.isPossible() && priority < square.cost) {
		    square.cost = priority;
		    candidates.add(square);
		}
	    }
	    current_squares = candidates;
	}
    }

    private static void join_priority_queue(PriorityQueue<Square> big_queue, PriorityQueue<Square> small_queue) {
	while (!small_queue.isEmpty()) {
	    int priority = (int) small_queue.getPriority();
	    Square square = small_queue.removeFirst();
	    big_queue.add(square, priority);
	}
    }

    private static PriorityQueue<Square> get_adjacent(List<List<Square>> map_torch, List<List<Square>> map_climb,
	    List<List<Square>> map_neither, int x, int y, int tool, int cost) {
	PriorityQueue<Square> result = new FixedPrioritiesPriorityQueue<Square>();

	List<List<Square>> map = null;
	if (tool == TOOL.TORCH) {
	    map = map_torch;
	} else if (tool == TOOL.CLIMB) {
	    map = map_climb;
	} else if (tool == TOOL.NEITHER) {
	    map = map_neither;
	} else {
	    System.exit(1);
	}
	int margin = 1;
	// top
	if (y > 0) {
	    Square square = map.get(y - 1).get(x);
	    if (square.isPossible() && square.cost == -1) {
		result.add(square, -1 - cost);
	    } else if (square.isPossible() && square.cost > -1 && square.cost > cost && cost > -1) {
		result.add(square, -1 - cost);
//		square.cost = cost + margin; // reset!
	    }
	}
	// bottom
	if (y < height - 1) {
	    Square square = map.get(y + 1).get(x);
	    if (square.isPossible() && square.cost == -1) {
		result.add(square, -1 - cost);
	    } else if (square.isPossible() && square.cost > -1 && square.cost > cost && cost > -1) {
		result.add(square, -1 - cost);
//		square.cost = cost + margin; // reset!
	    }
	}
	// left
	if (x > 0) {
	    Square square = map.get(y).get(x - 1);
	    if (square.isPossible() && square.cost == -1) {
		result.add(square, -1 - cost);
	    } else if (square.isPossible() && square.cost > -1 && square.cost > cost && cost > -1) {
		result.add(square, -1 - cost);
//		square.cost = cost + margin; // reset!
	    }
	}
	// right
	if (x < width - 1) {
	    Square square = map.get(y).get(x + 1);
	    if (square.isPossible() && square.cost == -1) {
		result.add(square, -1 - cost);
	    } else if (square.isPossible() && square.cost > -1 && square.cost > cost && cost > -1) {
		result.add(square, -1 - cost);
//		square.cost = cost + margin; // reset!
	    }
	}
	Square to_torch = map_torch.get(y).get(x);
	Square to_climb = map_climb.get(y).get(x);
	Square to_neither = map_neither.get(y).get(x);

	margin = 7;

	if (tool == TOOL.TORCH) {
	    if (to_climb.isPossible() && to_climb.cost == -1) {
		result.add(to_climb, -CHANGE_COST - cost);
	    } else if (to_climb.isPossible() && to_climb.cost > -1 && to_climb.cost > cost + margin && cost > -1) {
		System.out.println("NANI 5? " + to_climb + " nc: " + cost);
		result.add(to_climb, - margin - cost);
//		to_climb.cost = cost + margin; // reset!
	    }
	    if (to_neither.isPossible() && to_neither.cost == -1) {
		result.add(to_neither, -CHANGE_COST - cost);
	    } else if (to_neither.isPossible() && to_neither.cost > -1 && to_neither.cost > cost + margin && cost > -1) {
		System.out.println("NANI 6? " + to_neither + " nc: " + cost);
		result.add(to_neither, - margin - cost);
//		to_neither.cost = cost + margin; // reset!	    
	    }
	} else if (tool == TOOL.CLIMB) {
	    if (to_torch.isPossible() && to_torch.cost == -1) {
		result.add(to_torch, -CHANGE_COST - cost);
	    } else if (to_torch.isPossible() && to_torch.cost > -1 && to_torch.cost > cost + margin && cost > -1) {
		System.out.println("NANI 7? " + to_torch + " nc: " + cost);
		result.add(to_torch, - margin - cost);
//		to_torch.cost = cost + margin; // reset!
	    }
	    if (to_neither.isPossible() && to_neither.cost == -1) {
		result.add(to_neither, -CHANGE_COST - cost);
	    } else if (to_neither.isPossible() && to_neither.cost > -1 && to_neither.cost > cost + margin && cost > -1) {
		System.out.println("NANI 8? " + to_neither + " nc: " + cost);
		result.add(to_neither, - margin - cost);
//		to_neither.cost = cost + margin; // reset!
	    }
	} else if (tool == TOOL.NEITHER) {
	    if (to_torch.isPossible() && to_torch.cost == -1) {
		result.add(to_torch, -CHANGE_COST - cost);
	    } else if (to_torch.isPossible() && to_torch.cost > -1 && to_torch.cost > cost + margin && cost > -1) {
		System.out.println("NANI 9? " + to_torch + " nc: " + cost);
		result.add(to_torch, - margin - cost);
//		to_torch.cost = cost + margin; // reset!
	    }
	    if (to_climb.isPossible() && to_climb.cost == -1) {
		result.add(to_climb, -CHANGE_COST - cost);
	    } else if (to_climb.isPossible() && to_climb.cost > -1 && to_climb.cost > cost + margin && cost > -1) {
		System.out.println("NANI 10? " + to_climb + " nc: " + cost);
		result.add(to_climb, - margin - cost);
//		to_climb.cost = cost + margin; // reset!
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

class Square {
    public final int x, y, tool;
    public String type;
    public long erosionLevel, geoIndex;
    public String path;

    @Override
    public String toString() {
	return "( " + x + ", " + y + ", tool: " + tool + " type: " + type + ", " + cost + ")";
    }

    public int cost;

    public Square(int xx, int yy, int tt) {
	x = xx;
	y = yy;
	cost = -1;
	tool = tt;
	type = null;
	path = " ";
    }

    public boolean isPossible() {
	if (".".equals(type) && tool == TOOL.NEITHER) {
	    return false;
	}
	if ("=".equals(type) && tool == TOOL.TORCH) {
	    return false;
	}
	if ("|".equals(type) && tool == TOOL.CLIMB) {
	    return false;
	}
	if (type == null) {
	    return false;
	}
	return true;
    }

    @Override
    public int hashCode() {
	final int prime = 34313;
	int result = 1;
	result = prime * result + tool;
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
	if (tool != other.tool)
	    return false;
	if (x != other.x)
	    return false;
	if (y != other.y)
	    return false;
	return true;
    }

}

interface TOOL {
    public static final int TORCH = 0, CLIMB = 1, NEITHER = 2;
}
