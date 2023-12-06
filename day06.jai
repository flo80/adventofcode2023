#load "aoc.jai";

example :: #string DONE
Time:      7  15   30
Distance:  9  40  200
DONE


calc_options :: (t: int, d: int) -> int {
	s := Math.sqrt(cast(float64)(t * t - 4 * d));
	m1: int = xx Math.floor((t - s) / 2 + 1);
	m2: int = xx Math.ceil((t + s) / 2 - 1);

	options := m2 - m1 + 1;
	// print("% % => %\n", t, d, options);
	return options;
}

parta :: (input: string) -> int {
	fill_array :: (s: *string, a: *[$N]int) {
		if !s return;
		for * <<a {
			<<it = String.parse_int(s);
			if !s break;
		}
	}

	times: [4]int;
	distances: [4]int;

	lines := to_lines(input);
	eat_including_char(*lines[0], #char ":");
	fill_array(*lines[0], *times);

	eat_including_char(*lines[1], #char ":");
	fill_array(*lines[1], *distances);

	prod: int = 1;
	for i: 0..times.count-1 {
		if times[i] == 0 continue;
		options := calc_options(times[i],  distances[i]);
		prod *= options;
	}

	return prod;
}

partb :: (input: string) -> int {
	get_nr :: (line: string) -> int {
		eat_including_char(*line, #char ":");
		nr := 0;
		while line {
			if is_digit(line[0]) nr = nr * 10 + char_to_int(line[0]);
			advance(*line, 1);
		}
		return nr;
	}

	lines := to_lines(input);
	return calc_options(get_nr(lines[0]),get_nr(lines[1]));
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 288}], partb, .[.{example, 71503}], day);

main :: () {
	execute(parta, partb, valid, day);
}
