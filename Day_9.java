import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.magicwerk.brownies.collections.GapList;

public class Day_9 {
    //80 		  (71)
    //954 		  (719)
    //10276 		  (7192)
    //439089		  (71924)
    //37414246 		  (719240)
    //?                    (7192400)
    public static void main(String[] args) throws Exception {
	boolean debug = false;
	long answer = runAlgo(debug, 403, 7192400);
	System.out.println("answer: " + answer);
    }

    private static long runAlgo(boolean debug, int num_players, int last_marble) {    
	Map<Integer, Long> scores = new HashMap<Integer,Long>();
	for (int index = 0; index < num_players; index++) {
	    scores.put(index, 0l);
	}
	
	Circle circle = new Circle();
	long last_time = 0;
	int iterations = 0;
	for (int index = 1; true; index++) {
	    int player = index % num_players;
	    if (index % 23 == 0) {
		long curr_score = scores.get(player);
		circle.moveClockWise();
		circle.moveClockWise();
		circle.moveClockWise();
		circle.moveClockWise();
		circle.moveClockWise();
		circle.moveClockWise();
		circle.moveClockWise();
		long extra_score = circle.remove_current();
		scores.put(player, curr_score + index + extra_score);
	    } else {
		circle.addMarble(index);
	    }
//	    if (debug) {
//		System.out.println(circle);
//	    }
	    if (index == last_marble) {
		if (debug) {
		    System.out.println("scores: " + scores);
		}
		break;
	    }
	    iterations++;
	    if (iterations % 100000 == 0 && debug) {
		long now = new Date().getTime();
		System.out.println("100k iter: " + iterations + " - " + (now - last_time));
		last_time = now;
	    }
	}
	Entry<Integer, Long> winner = find_max(scores);
//	System.out.println("winner: " + winner);
	return winner.getValue();
    }

    private static Entry<Integer, Long> find_max(Map<Integer, Long> scores) {
	Iterator<Entry<Integer, Long>> iter = scores.entrySet().iterator();
	Entry<Integer, Long> max_pair = null;
	long max_val = 0;
	while(iter.hasNext()) {
	    Entry<Integer, Long> entry = iter.next();
	    if (max_val < entry.getValue()) {
		max_val = entry.getValue();
		max_pair = entry;
	    }
	}
	return max_pair;
    }
}

class Circle {
    public final List<Long> list = new GapList<Long>();//new ArrayList<Integer>(7192000);
    private int pos = 0;
    
    public String toString() {
	String result = "";
	for (int index = 0; index < list.size(); index++) {
	    if (index == pos) {
		result += " (" + list.get(index) + ")";
	    } else {
		result += "  " + list.get(index) + " ";
	    }
	}
	return result + "\t\t\tpos:" + pos;
    }
    
    public long remove_current() {
	long current_marble = list.get(pos);
	list.remove((int)pos);
	return current_marble;
    }

    public Circle() {
	list.add(0l);
    }
    
    public void addMarble(long new_marble) {
	moveCounterCWise();
	if (pos == list.size() - 1) {
	    list.add(new_marble);
	    pos = list.size() - 1;
	    return;
	} else {
	    moveCounterCWise();
	    list.add(pos, new_marble);
	    return;
	}
    }
    
    public long getValue() {
	return list.get(pos);
    }
    
    public int getPos() {
	return pos;
    }
    
    public void moveCounterCWise() {
	String msg = "pos orig: " + pos + " list size: " + list.size();
	pos = (pos + 1) % list.size();
	//System.out.println("mvcc: " + msg + " new pos: " + pos);
    }
    public void moveClockWise() {
	pos = (pos - 1) % list.size();
	if (pos < 0) {
	    pos += list.size();
	}
    }
}
