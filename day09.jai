#load "aoc.jai";

example :: #string DONE
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
DONE

parta :: (input: string) -> int {
	next_number :: (numbers: []int) -> int {
		all_zeros := true;
		deltas : [..]int;
		for i: 0..numbers.count-2 {
			delta  := numbers[i+1] - numbers[i];
			all_zeros &= delta == 0;
			array_add(*deltas, delta);
		}
		if all_zeros return numbers[numbers.count - 1];
		return next_number(deltas) + numbers[numbers.count - 1];
	}

	lines := to_lines(input);

	sum := 0;
	for line: lines {
		if !line continue;
		numbers := parse_to_array(line);
		next := next_number(numbers);
		sum += next;
	}

	return sum;
}

partb :: (input: string) -> int {
	previous_number :: (numbers: []int) -> int {
		all_zeros := true;
		deltas : [..]int;
		for i: 0..numbers.count-2 {
			delta  := numbers[i+1] - numbers[i];
			all_zeros &= delta == 0;
			array_add(*deltas, delta);
		}
		if all_zeros return numbers[0];
		return numbers[0] - previous_number(deltas);
	}

	lines := to_lines(input);

	sum := 0;
	for line: lines {
		if !line continue;
		numbers := parse_to_array(line);
		next := previous_number(numbers);
		sum += next;
	}

	return sum;
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 114}], partb, .[.{example, 2}], day);

main :: () {
	execute(parta, partb, valid, day);
}
