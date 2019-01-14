import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Day_24 {

    // 16867
    // 16848
    // 16665
    // 16530 (right!)
    private static final boolean debug = false;
    private static final String filename = debug ? "d24_input_test1.txt" : "d24_input.txt";

    private static final int initial_boost = 41;
     
    private static final boolean print = false;
    
    public static void main(String[] args) throws Exception {
	List<String> allLines = Files.readAllLines(Paths.get(filename));
	Pattern side = Pattern.compile("(\\w*) (\\w*):");
	Pattern army_size = Pattern.compile("(\\d*) units each with (\\d*) hit points");
	Pattern immunities = Pattern.compile("immune to ([\\w*\\s*,*]*)");
	Pattern weaknesses = Pattern.compile("weak to ([\\w*\\s*,*]*)");
	Pattern attack = Pattern.compile("with an attack that does (\\d*) (\\w*) damage at initiative (\\d*)");

	List<Group> original_immune = new ArrayList<Group>();
	List<Group> original_infect = new ArrayList<Group>();

	String last_side = null;
	String[] empty_arr = new String[] {};
	int group_number = 1;
	for (String line : allLines) {
	    Matcher side_match = side.matcher(line);
	    String units_str = "", hp_str = "", imm_list = "", weak_list = "", power = "", elem = "", init = "";
	    if (side_match.find()) {
		last_side = side_match.group(1);
		group_number = 1;
	    }
	    Matcher army_size_match = army_size.matcher(line);
	    if (army_size_match.find()) {
		units_str = army_size_match.group(1);
		hp_str = army_size_match.group(2);
	    }
	    Matcher immunities_match = immunities.matcher(line);
	    if (immunities_match.find()) {
		imm_list = immunities_match.group(1);
	    }
	    Matcher weaknesses_match = weaknesses.matcher(line);
	    if (weaknesses_match.find()) {
		weak_list = weaknesses_match.group(1);
	    }
	    Matcher attack_match = attack.matcher(line);
	    if (attack_match.find()) {
		power = attack_match.group(1);
		elem = attack_match.group(2);
		init = attack_match.group(3);
	    }
	    String[] weak_arr = weak_list.isEmpty() ? empty_arr
		    : weak_list.indexOf(',') > 0 ? weak_list.split(",") : new String[] { weak_list };
	    String[] imm_arr = imm_list.isEmpty() ? empty_arr
		    : imm_list.indexOf(',') > 0 ? imm_list.split(",") : new String[] { imm_list };
	    if (!units_str.isEmpty()) {
		Group group = new Group(group_number, last_side, units_str, hp_str, power, init, elem, weak_arr,
			imm_arr);
		group_number++;
		if (last_side.equals("Immune")) {
		    original_immune.add(group);
		} else {
		    original_infect.add(group);
		}
	    }
	}
	System.out.println("PRE FIGHT");
	System.out.println("immune side: " + original_immune);
	System.out.println("infect side: " + original_infect);
	System.out.println("fight: ");
	
	conduct_battle_with_boost(original_immune, original_infect, 0);
	
	boolean keep_going = true;
	for(int boost = initial_boost; keep_going; boost++) {
	    keep_going = conduct_battle_with_boost(original_immune, original_infect, boost);
	}
    }

    private static boolean conduct_battle_with_boost(List<Group> original_immune, List<Group> original_infect, int boost) {
	List<Group> immune = deep_copy(original_immune, boost);
	List<Group> infect = deep_copy(original_infect, 0);
	
	while (immune.size() > 0 && infect.size() > 0) {
	    if (print) print_sides(immune, infect);
	    select_target(infect, immune);
	    select_target(immune, infect);
	    if (print) System.out.println("");
	    List<Group> grand_list = new ArrayList<Group>(immune);
	    grand_list.addAll(infect);
	    grand_list.sort((g1, g2) -> g2.initiative - g1.initiative);
	    for (Group attacker : grand_list) {
		actual_attack(attacker, immune, infect);
	    }
	    if (print) System.out.println("End turn\n");
	}
	System.out.println("FIGHT RESULT");
	System.out.println("immune side: " + immune);
	System.out.println("infect side: " + infect);
	int total = 0;
	boolean infect_won = true;
	for (Group group : immune) {
	    total += group.units;
	    infect_won = false;
	}
	for (Group group : infect) {
	    total += group.units;
	}
	System.out.println("grand total: " + total + " with boost " + boost);
	if (!infect_won) {
	    System.out.println("immune won with boost " + boost + " and remaining units " + total);
	}
	return infect_won;
    }

    private static List<Group> deep_copy(List<Group> original, int boost) {
	List<Group> result = new ArrayList<Group>();
	for(Group g: original) {
	    Group copy = new Group(g, boost);
	    result.add(copy);
	}
	return result;
    }

    private static void print_sides(List<Group> immune, List<Group> infect) {
	System.out.println("Immune System:");
	for (Group g : immune) {
	    System.out.println("Group " + g.group_number() + " contains " + g.units + " units");
	}
	System.out.println("Infect System:");
	for (Group g : infect) {
	    System.out.println("Group " + g.group_number() + " contains " + g.units + " units");
	}
	System.out.println("");
    }

    private static void actual_attack(Group attacker, List<Group> immune, List<Group> infect) {
	if (attacker.current_target == null) {
	    return;
	}
	boolean immune_to_attack = attacker.current_target.immunities.contains(attacker.attack_type);
	if (immune_to_attack) {
	    attacker.current_target = null;
	    return;
	}
	Group victim = attacker.current_target;
	boolean weakness_to_attack = attacker.current_target.weakness.contains(attacker.attack_type);
	int effective_power = attacker.units * attacker.attack_damage * (weakness_to_attack ? 2 : 1);
	int effective_life = victim.hp * victim.units;
	if (effective_power >= effective_life) {// ded
	    immune.remove(victim);
	    infect.remove(victim); // we take it from both and save an if. One of them will succeed.
	    victim.current_target = null; // it's ded, so it should not attack later on the same turn it
					  // died
	    if (print) System.out.println(attacker.getSide() + " group " + attacker.group_number() + " attacks group "
		    + victim.group_number() + ", killing " + victim.units + " = ded");
	    victim.units = 0;
	    attacker.current_target = null;
	    return;
	}
	int killed = (int) Math.floor(effective_power / victim.hp);
	if (print) System.out.println(attacker.getSide() + " group " + attacker.group_number() + " attacks group "
		+ victim.group_number() + ", killing " + killed);
	victim.units -= killed;
	attacker.current_target = null;
    }

    private static void select_target(List<Group> attackers, final List<Group> targets) {
	List<Group> copy_target = new ArrayList<Group>(targets); // we shouldn't modify the targets
	attackers.sort(
		(a1, a2) -> a2.comparable_effective_power_initiative() - a1.comparable_effective_power_initiative());
	for (Group attacker : attackers) {
	    final String attacking_type = attacker.attack_type;
	    final int effective_power = attacker.effective_power();
	    Collections.sort(copy_target, new Comparator<Group>() {
		public int compare(Group g1, Group g2) {
		    long diff_eff_power = g2.comparable_effective_power_initiative(effective_power, attacking_type)
			    - g1.comparable_effective_power_initiative(effective_power, attacking_type);
		    return (diff_eff_power > 0)? 1: (diff_eff_power < 0) ? -1: 0;
		}
	    });
	    if (copy_target.size() > 0) {
		Group candidate = copy_target.get(0);
		// System.out.println("targets ordered for " + attacker + " =\n" + copy_target);
		for (Group victim : copy_target) {
		    if (print) System.out.println(attacker.getSide() + " group " + attacker.group_number() + " (" + pad(7,attacker.comparable_effective_power_initiative()) + 
			    ") would deal group " + victim.group_number() + " " + calc_attack(attacker, victim) + " damage ("
			    + pad(16, victim.comparable_effective_power_initiative(effective_power, attacking_type)) + ") (attacker: "
			    + attacker.attack_type + " victim: " + victim.weakness);
		}
		if (candidate.immunities.contains(attacking_type)) {
		    attacker.current_target = null;
		} else {
		    attacker.current_target = candidate;
		    copy_target.remove(candidate);
		}
	    } else {
		attacker.current_target = null;
	    }
	}
    }

    private static String calc_attack(Group attacker, Group victim) {
	if (victim.immunities.contains(attacker.attack_type)) {
	    return "     0";
	}
	int multiplier = victim.weakness.contains(attacker.attack_type) ? 2 : 1;
	int result = multiplier * attacker.attack_damage * attacker.units;
	// System.out.println("attacker: " + attacker + " victim: " + victim + " multiplier " + multiplier + " result: "
	// + result);
	return pad(6, result);
    }

    public static String pad(int pad, int number) {
	String result = "";
	String nstr = "" + number;
	int how_many = pad - nstr.length();
	for (int index = 0; index < how_many; index++) {
	    result += " ";
	}
	return result + nstr;
    }
    public static String pad(int pad, long number) {
	String result = "";
	String nstr = "" + number;
	int how_many = pad - nstr.length();
	for (int index = 0; index < how_many; index++) {
	    result += " ";
	}
	return result + nstr;
    }
}

class Group {
    private final int group_number;
    boolean immune;
    int units;
    final int hp;
    final int attack_damage;
    final int initiative;
    final String attack_type;
    final List<String> weakness = new ArrayList<String>();
    final List<String> immunities = new ArrayList<String>();

    Group current_target = null;

    public String getSide() {
	return immune ? "Immune" : "Infect";
    }

    public String group_number() {
	return Day_24.pad(2, group_number);
    }

    public Group(Group g, int boost) {
	this.group_number = g.group_number;
	this.immune = g.immune;
	this.units = g.units;
	this.hp = g.hp;
	this.attack_damage = g.attack_damage + boost;
	this.initiative = g.initiative;
	this.attack_type = g.attack_type;
	for (String weak: g.weakness) {
	    this.weakness.add(weak);
	}
	for (String imm: g.immunities) {
	    this.immunities.add(imm);
	}
    }

    public Group(int gu, boolean immune, int units, int hp, int attack_damage, int initiative, String attack_type,
	    String[] weakness, String[] immunities) {
	super();
	this.group_number = gu;
	this.immune = immune;
	this.units = units;
	this.hp = hp;
	this.attack_damage = attack_damage;
	this.initiative = initiative;
	this.attack_type = attack_type;
	for (String string : weakness) {
	    this.weakness.add(string.trim());
	}
	for (String string : immunities) {
	    this.immunities.add(string.trim());
	}
    }

    public int effective_power() {
	return units * attack_damage;
    }

    public int comparable_effective_power_initiative() {
	return effective_power() * 1000 + initiative;
    }

    public long comparable_effective_power_initiative(int effective_power_int, String attacking_type) {
	long effective_power = (long) effective_power_int;
 	long result = 0;
	if (immunities.contains(attacking_type)) {
	    return comparable_effective_power_initiative();
	}
	long multiplier = 1000000000;
	if (weakness.contains(attacking_type)) {
	    multiplier = 2000000000;
	}
	result = multiplier * effective_power + ((long)comparable_effective_power_initiative());
	return result;
    }

    public Group(int gu, String immune, String units, String hp, String attack_damage, String initiative,
	    String attack_type, String[] weakness, String[] immunities) {
	super();
	this.group_number = gu;
	this.immune = immune.equals("Immune");
	this.units = Integer.parseInt(units);
	this.hp = Integer.parseInt(hp);
	this.attack_damage = Integer.parseInt(attack_damage);
	this.initiative = Integer.parseInt(initiative);
	this.attack_type = attack_type;
	for (String string : weakness) {
	    this.weakness.add(string.trim());
	}
	for (String string : immunities) {
	    this.immunities.add(string.trim());
	}
    }

    public String toString() {
	return "G[" + group_number + "]: [" + (immune ? "IMMUNE" : "INFECT") + "][" + units + " units with " + hp
		+ " each (imm: " + immunities + ") (weak: " + weakness + ") attack: " + attack_damage + " of "
		+ attack_type + " at " + initiative + "] ("
		+ NumberFormat.getInstance().format(comparable_effective_power_initiative()) + ")\n";
    }

    @Override
    public int hashCode() {
	final int prime = 31;
	int result = 1;
	result = prime * result + attack_damage;
	result = prime * result + ((attack_type == null) ? 0 : attack_type.hashCode());
	result = prime * result + hp;
	result = prime * result + (immune ? 1231 : 1237);
	result = prime * result + ((immunities == null) ? 0 : immunities.hashCode());
	result = prime * result + initiative;
	result = prime * result + units;
	result = prime * result + ((weakness == null) ? 0 : weakness.hashCode());
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
	Group other = (Group) obj;
	if (attack_damage != other.attack_damage)
	    return false;
	if (attack_type == null) {
	    if (other.attack_type != null)
		return false;
	} else if (!attack_type.equals(other.attack_type))
	    return false;
	if (hp != other.hp)
	    return false;
	if (immune != other.immune)
	    return false;
	if (immunities == null) {
	    if (other.immunities != null)
		return false;
	} else if (!immunities.equals(other.immunities))
	    return false;
	if (initiative != other.initiative)
	    return false;
	if (units != other.units)
	    return false;
	if (weakness == null) {
	    if (other.weakness != null)
		return false;
	} else if (!weakness.equals(other.weakness))
	    return false;
	return true;
    }
}