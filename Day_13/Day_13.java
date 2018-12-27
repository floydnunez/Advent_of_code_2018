import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Day_13 {

    public static final Set<Character> carts = new HashSet<Character>();
    
    public static void main(String[] args) throws Exception {
	String filename = "d13_input_1.txt";
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
	System.out.println("all carts: " + all_carts);
    }

    private static void sanity_check(List<Cart> all_carts) {
	List<Cart> to_elim = new ArrayList<Cart>();
	for(Cart cart: all_carts) {
	    if (cart.track == null) {
		to_elim.add(cart);
	    }
	}
	for(Cart cart: to_elim) {
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

class Cart {
    public final int id;
    public int last_turn = 0;
    public Track track = null;
    public char dir;

    public Cart(char letter, int id) {
	dir = letter;
	this.id = id;
    }
    public String toString() {
	return "C[id: " + id + " @ (" + track.x + ", " + track.y + ") to: " + dir + "]";
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
}