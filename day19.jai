#load "aoc.jai";

example :: #string DONE
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
DONE

Rule :: struct {
	element, op: u8;
	nr: int;
	next: string;
}

starting_rule :: "in";

Workflow :: struct {
	rules: [..]Rule;
	default: string;
}

Range :: struct {
	start: int;
	end: int;
}

XMAS :: struct {
	xmas: [4]Range;
	next: string;
}

parse_worflows :: (text: string) ->  HashTable.Table(string, Workflow) {
	workflows: HashTable.Table(string, Workflow);

	for to_lines(text) {
		if !it continue;
		tokens := split_by_any(it, "{,}");
		name := tokens[0];

		rules :[..]Rule;
		for i:1..tokens.count-3 {
			rule := tokens[i];
			element := rule[0];
			op := rule[1];

			advance(*rule, 2);
			nr := String.parse_int(*rule, delimiters=":");
			next := String.slice(rule, 1, rule.count);

			array_add(*rules, .{element, op, nr, next});
		}

		default := tokens[tokens.count-2];
		HashTable.table_add(*workflows, name, .{rules, default});
	}

	return workflows;
}


parta :: (input: string) -> int {
	parts := String.split(input, "\n\n");
	assert(parts.count == 2);
	workflows := parse_worflows(parts[0]);

	sum := 0;
	for line: to_lines(parts[1]) {
		if !line continue;

		tokens := split_by_any(line, "{=,}");
		x := string_to_int(tokens[2]);
		m := string_to_int(tokens[4]);
		a := string_to_int(tokens[6]);
		s := string_to_int(tokens[8]);

		current_workflow := starting_rule;
		workflow, found := HashTable.table_find(*workflows, current_workflow);
		assert(found, "Could not find workflow %", current_workflow);

		while found {
			follow:bool;

			for r: workflow.rules {
				val:int;

				if r.element == {
					case #char "x"; val = x;
					case #char "m"; val = m;
					case #char "a"; val = a;
					case #char "s"; val = s;
					case; assert(false);
				}

				if r.op == #char ">" follow = val > r.nr;
				else if r.op == #char "<" follow = val < r.nr;
				else assert(false);

				if follow {
					current_workflow = r.next;
					break r;
				}
			}

			if !follow current_workflow = workflow.default;

			if current_workflow == "R" continue line;
			if current_workflow == "A" {
				sum += x + m + a + s;
				continue line;
			}
			workflow, found = HashTable.table_find(*workflows, current_workflow);
			assert(found, "Could not find workflow %", current_workflow);
		}
	}

	return sum;
}

process_xmas :: (xmas: []XMAS, workflows: *HashTable.Table(string, Workflow)) -> []XMAS {
	ranges, accepted: [..] XMAS;
	array_add(*ranges, ..xmas);

	while ranges {
		range := pop(*ranges);
		if range.next == "R" continue;
		if range.next == "A" {
			array_add(*accepted, range);
			continue;
		}

		workflow, found := HashTable.table_find(workflows, range.next);
		assert(found, "Could not find workflow %", range.next);

		for r: workflow.rules {
			idx:int;
			if r.element == {
				case #char "x"; idx = 0;
				case #char "m"; idx = 1;
				case #char "a"; idx = 2;
				case #char "s"; idx = 3;
				case; assert(false);
			}

			if r.op == #char ">" {
				if range.xmas[idx].end > r.nr {
					new := array_add(*ranges);
					new.xmas = range.xmas;
					new.xmas[idx].start = r.nr + 1;
					range.xmas[idx].end = r.nr;
					new.next = r.next;
				}
			}
			else if r.op == #char "<" {
				if range.xmas[idx].start < r.nr {
					new := array_add(*ranges);
					new.xmas = range.xmas;
					range.xmas[idx].start = r.nr;
					new.xmas[idx].end = r.nr - 1;
					new.next = r.next;
				}

			}
			else assert(false);
		}

		default := true;
		for range.xmas if it.start > it.end default = false;
		if default {
			new := array_add(*ranges);
			new.xmas = range.xmas;
			new.next = workflow.default;
		}
	}

	return accepted;
}


partb :: (input: string) -> s64 {
	parts := String.split(input, "\n\n");
	assert(parts.count == 2);
	workflows := parse_worflows(parts[0]);

	start_range :: Range.{1,4000};
	xmas:[]XMAS = .[.{.[start_range, start_range, start_range, start_range], starting_rule}];

	accepted := process_xmas(xmas, *workflows);

	sum :s64= 0;
	for accepted {
		prod := 1;
		for it.xmas prod *= (it.end-it.start+1);
		sum += prod;
	}

	return sum;
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 19114}], partb, .[.{example, 167409079868000}], day);

main :: () {
	execute(parta, partb, valid, day);
}
