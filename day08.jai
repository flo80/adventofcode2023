#load "aoc.jai";

exampleA1 :: #string DONE
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
DONE

exampleA2 :: #string DONE
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
DONE

exampleB :: #string DONE
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
DONE

Node:: u32;
Edges :: struct {
	left, right: Node;
}

Network :: HashTable.Table(Node, Edges);

// store only numeric to avoid string comparisons (slightly faster)
to_node :: inline (str: string) -> Node {
	assert(str.count >= 3);
	return ((cast(Node)str[0]) << 16) |
		   ((cast(Node)str[1]) << 8)  |
		   ((cast(Node)str[2]) << 0)  ;
}

parse_input :: (input: string) -> instructions: string, graph: Network {
	lines := to_lines(input);

	instructions := String.trim(lines[0]);
	nodes : Network;

	for i:2..lines.count-1 {
		line := lines[i];
		if !line continue;

		node  := to_node(String.slice(line, 0, 3));
        left  := to_node(String.slice(line, 7, 3));
        right := to_node(String.slice(line, 12, 3));

		HashTable.table_add(*nodes, node, .{left, right});
	}

	return instructions, nodes;
}

step :: inline (current: Node, instruction: u8, map: Network) -> Node {
		e, ok := HashTable.table_find(*map, current);
		assert(ok);

		if instruction == #char "L" return e.left;
		else return e.right;
}

current_loop_body :: #string DONE
	{
		i := instructions[idx];
		steps += 1;
		idx += 1;
		if idx >= instructions.count idx = 0;
		curr = step(curr, i, map);
	}
DONE

parta :: (input: string) -> int {
	start := to_node("AAA");
	dest  := to_node("ZZZ");

	instructions, map := parse_input(input);

	curr := start;
	steps := 0;
	idx := 0;
	while curr != dest #insert current_loop_body;
	return steps;
}

partb :: (input: string) -> u64 {
	instructions, map := parse_input(input);
	first_letter :: #char "A";
	last_letter :: #char "Z";

	count :: (start: Node, instructions: string, map: Network) -> u64 {
		curr := start;
		steps:u64 = 0;
		idx := 0;
		while curr & 0xff != last_letter #insert current_loop_body;
		return steps;
	}

	required_steps : [..]u64;
	{
		// workaround for broken for_expansion
		#import "Hash_Table";

		for e,n: map {
			if n & 0xff != first_letter continue; // not A at end
			c := count(n, instructions, map);
			array_add(*required_steps, c);
		}
	}
	return lcm(required_steps);
}

day :: #run get_day();
valid :: #run test(parta, .[.{exampleA1, 2}, .{exampleA2, 6}], partb, .[.{exampleB, 6}], day);

main :: () {
	execute(parta, partb, valid, day);
}
