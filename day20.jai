#load "aoc.jai";

example1 :: #string DONE
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
DONE

example2 :: #string DONE
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
DONE

initial :: "broadcaster";

Typ :: enum u8 {
	FlipFlop :: #char "%";
	Conjunction :: #char "&";
	Broadcaster :: #char "b";
}

Node :: struct {
	type: Typ;
	outputs: []string;
	state: bool = false;
}

Q :: struct {
	node: string;
	signal: bool;
}

LOW :: false;
HIGH :: true;

parse_input :: (input: string) -> inputs: HashTable.Table(string, [..]string), nodes: HashTable.Table(string, Node) {
	inputs: HashTable.Table(string, [..]string);
	nodes: HashTable.Table(string, Node);

	for to_lines(input) {
		if !it continue;
		tokens := String.split(it, " -> ");

		type := cast(Typ)tokens[0][0];
		name := ifx type == .Broadcaster then tokens[0] else String.slice(tokens[0], 1, tokens[0].count);
		outputs := String.split(tokens[1], ", ");
		HashTable.table_add(*nodes, name, .{type, outputs, false});

		for outputs {
			list := HashTable.find_or_add(*inputs, it);
			array_add(list, name);
		}
	}

	return inputs, nodes;
}

parta :: (input: string) -> int {
	inputs, nodes := parse_input(input);

	// for nodes print("%: %\n", it_index, it);
	// for inputs print("%: %\n", it_index, it);

	counts_low: int;
	counts_high: int;
	queue: [..]Q;

	run :: () #expand {
		counts_low += 1;
		b := HashTable.table_find_pointer(*nodes, initial);
		for b.outputs array_add(*queue, .{it, LOW});

		while queue {
			item := pop(*queue);
			if item.signal counts_high += 1;
			else counts_low += 1;

			node := HashTable.table_find_pointer(*nodes, item.node);
			if(node == null) continue;

			if #complete node.type == {
				case .FlipFlop;
					if item.signal == HIGH continue;
					else node.state = !node.state;

				case .Conjunction;
					ins, found := HashTable.table_find(*inputs, item.node);
					assert(found);
					x:=true;
					for ins x &= HashTable.table_find_pointer(*nodes, it).state;
					node.state = !x;

				case .Broadcaster; assert(false);
			}
			for node.outputs array_add(*queue, .{it, node.state});
		}
	}

	for i:1..1000 run();

	return counts_low * counts_high;
}

partb :: (input: string) -> int {
	inputs, nodes := parse_input(input);
	queue: [..]Q;
	counts: [..]int;

	rx_predecessor_name, found := HashTable.table_find(*inputs, "rx");
	assert(found && rx_predecessor_name.count == 1);

	targets, found= := HashTable.table_find(*inputs, rx_predecessor_name[0]);
	assert(found);

	for button_presses: 1..1000000 {
		b := HashTable.table_find_pointer(*nodes, initial);
		for b.outputs array_add(*queue, .{it, LOW});

		while queue {
			item := pop(*queue);
			node := HashTable.table_find_pointer(*nodes, item.node);
			if(node == null) continue;

			if !item.signal	&& array_find(targets, item.node) {
				array_add(*counts, button_presses);
				array_unordered_remove_by_value(*targets, item.node);
			}

			if!targets break button_presses;

			if #complete node.type == {
				case .FlipFlop;
					if item.signal == HIGH continue;
					else node.state = !node.state;

				case .Conjunction;
					ins, found := HashTable.table_find(*inputs, item.node);
					assert(found);
					x:=true;
					for ins x &= HashTable.table_find_pointer(*nodes, it).state;
					node.state = !x;

				case .Broadcaster; assert(false);
			}
			for node.outputs array_add(*queue, .{it, node.state});
		}
	}

	return lcm(counts);
}

day :: #run get_day();
valid :: #run test(parta, .[.{example1, 32000000}, .{example2, 11687500}], partb, .[], day);

main :: () {
	execute(parta, partb, valid, day);
}
