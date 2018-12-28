import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Day_13 {

    public static final Set<Character> carts = new HashSet<Character>();

    public static void main(String[] args) throws Exception {
	String filename = "d13_input.txt";
	boolean debug = !filename.equals("d13_input.txt");
	List<String> allLines = Files.readAllLines(Paths.get(filename));
	int height = allLines.size();
	int width = allLines.get(0).length();// assumes all lines are equal.
	carts.add('<');
	carts.add('^');
	carts.add('v');
	carts.add('>');
	Track[][] map = new Track[height][width];
	System.out.println("map.height = " + map.length);
	System.out.println("map.width = " + map[0].length);
	System.out.println("map cell = " + map[2][2]);
	int cart_id = 0;
	List<Cart> all_carts = new ArrayList<Cart>();
	for (int yndex = 0; yndex < height; yndex++) {
	    String line = allLines.get(yndex);
	    char[] chars = line.toCharArray();
	    for (int xndex = 0; xndex < width; xndex++) {
		char letter = chars[xndex];
		Track track = null;
		Cart cart = null;
		if (carts.contains(letter)) {
		    cart = new Cart(letter, cart_id);
		    cart_id++;
		    all_carts.add(cart);
		    if (letter == '<' || letter == '>') {
			letter = '-';
		    }
		    if (letter == '^' || letter == 'v') {
			letter = '|';
		    }
		}
		track = new Track(xndex, yndex, letter);
		track.setCart(cart);
		map[yndex][xndex] = track;
	    }
	}
	System.out.println("map cell = " + map[2][2]);
	sanity_check(all_carts);
	Collections.sort(all_carts);
	print(map);
	System.out.println("all carts: " + all_carts);
	List<Cart> to_delete = new ArrayList<Cart>();
	while (true) {
	    for (Cart cart : all_carts) {
		Cart[] collided = cart.moveCart(map);
		boolean second = false;
		for (Cart cc : collided) {
		    to_delete.add(cc);
		    if (second) {
			System.out.println("Collision at " + cc.track.x + ", " + cc.track.y);
		    }
		    second = true;
		}
	    }
	    remove_carts(all_carts, to_delete);
//	    print(map);
	    if (all_carts.size() == 1) {
		System.out.println(all_carts);
		System.exit(0);
	    }
	    sanity_check(all_carts);
	    Collections.sort(all_carts);
//	    Thread.sleep(300);
	}
    }

    private static void remove_carts(List<Cart> all_carts, List<Cart> to_delete) {
	for (Cart cc: to_delete) {
	    cc.track.cart = null;
	}
	all_carts.removeAll(to_delete);
    }

    private static void print(Track[][] map) {
	for (int yndex = 0; yndex < map.length; yndex++) {
	    String line = "";
	    for (int xndex = 0; xndex < map[yndex].length; xndex++) {
		if (map[yndex][xndex].cart == null) {
		    line += map[yndex][xndex].rail;
		} else {
		    line += map[yndex][xndex].cart.dir;
		}
	    }
	    System.out.println(line);
	}
	System.out.println("\n");
    }

    private static void sanity_check(List<Cart> all_carts) {
	List<Cart> to_elim = new ArrayList<Cart>();
	for (Cart cart : all_carts) {
	    if (cart.track == null) {
		to_elim.add(cart);
	    }
	}
	for (Cart cart : to_elim) {
	    all_carts.remove(cart);
	}
    }
}

class Track {
    public final char rail;
    public final int x, y;
    public Cart cart;

    public Track(int x, int y, char letter) {
	this.x = x;
	this.y = y;
	cart = null;
	rail = letter;
    }

    public void setCart(Cart this_cart) {
	if (this_cart == null) {
	    cart = null;
	} else {
	    cart = this_cart;
	    this_cart.track = this;
	}
    }

    public Track(int x, int y) {
	this.x = x;
	this.y = y;
	cart = null;
	rail = ' ';
    }

    public String toString() {
	return "" + rail;
    }
}

class Cart implements Comparable {
    public final int id;
    public int last_turn = 0;
    public Track track = null;
    public char dir;
    public boolean collided;
    
    public Cart(char letter, int id) {
	dir = letter;
	this.id = id;
	collided = false;
    }

    public String toString() {
	return "C[id: " + id + " @ (" + track.x + ", " + track.y + ") to: " + dir + "]";
    }

    public Cart[] moveCart(Track[][] map) {
	int x = track.x;
	int y = track.y;
	Track next = null;
	if (dir == '^') { // get next track
	    next = map[y - 1][x];
	    if (next.rail == '/') {
		dir = '>';
	    }
	    if (next.rail == '\\') {
		dir = '<';
	    }
	    if (next.rail == '+') {
		if (last_turn == 0) {
		    dir = '<';
		    last_turn = 1;
		} else if (last_turn == 1) {// keep forward
		    last_turn = 2;
		} else if (last_turn == 2) {
		    dir = '>';
		    last_turn = 0;
		}
	    }
	    // handle collisions
	    // move
	} else if (dir == '>') { // get next track
	    next = map[y][x + 1];
	    if (next.rail == '/') {
		dir = '^';
	    }
	    if (next.rail == '\\') {
		dir = 'v';
	    }
	    if (next.rail == '+') {
		if (last_turn == 0) {
		    dir = '^';
		    last_turn = 1;
		} else if (last_turn == 1) {// keep forward
		    last_turn = 2;
		} else if (last_turn == 2) {
		    dir = 'v';
		    last_turn = 0;
		}
	    }
	} else if (dir == 'v') { // get next track
	    next = map[y + 1][x];
	    if (next.rail == '/') {
		dir = '<';
	    }
	    if (next.rail == '\\') {
		dir = '>';
	    }
	    if (next.rail == '+') {
		if (last_turn == 0) {
		    dir = '>';
		    last_turn = 1;
		} else if (last_turn == 1) {// keep forward
		    last_turn = 2;
		} else if (last_turn == 2) {
		    dir = '<';
		    last_turn = 0;
		}
	    }
	} else if (dir == '<') { // get next track
	    next = map[y][x - 1];
	    if (next.rail == '/') {
		dir = 'v';
	    }
	    if (next.rail == '\\') {
		dir = '^';
	    }
	    if (next.rail == '+') {
		if (last_turn == 0) {
		    dir = 'v';
		    last_turn = 1;
		} else if (last_turn == 1) {// keep forward
		    last_turn = 2;
		} else if (last_turn == 2) {
		    dir = '^';
		    last_turn = 0;
		}
	    }
	}
	// handle collisions
	if (next.cart != null && !next.cart.collided && !this.equals(next.cart)) {
	    //last one is sanity check
	    this.collided = true;
	    next.cart.collided = true;
	    return new Cart[] { this, next.cart };
	}
	// move
	track.setCart(null);
	next.setCart(this);
	return new Cart[] {};
    }

    @Override
    public int hashCode() {
	final int prime = 31;
	int result = 1;
	result = prime * result + id;
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
	Cart other = (Cart) obj;
	if (id != other.id)
	    return false;
	return true;
    }

    @Override
    public int compareTo(Object o) {
	if (o == null || o == this) {
	    return 0;
	} else if (!(o instanceof Cart)) {
	    return 0;
	}
	Cart other = (Cart) o;
	int x = track.x;
	int y = track.y;
	int this_read_order = 300 * y + x;

	int x2 = other.track.x;
	int y2 = other.track.y;
	int other_read_order = 300 * y2 + x2;

	return this_read_order - other_read_order;
    }
}
