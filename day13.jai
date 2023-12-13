#load "aoc.jai";

DEBUG_PRINT :: false;

example :: #string DONE
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
DONE

analyze :: (block : string, expected_delta := 0) -> int {
	pattern := to_lines(block);
	width := pattern[0].count-1;
	height := pattern.count-1;
	while !pattern[height] height -= 1; // correct some empty lines from split

	#if DEBUG_PRINT print("++++\nchecking % x %\n===\n%\n===\n", width, height, block);

	for y: 1..height {
		diffs := 0;
		above, below := y, y - 1;

		while above <= height && below >= 0 {
			#if DEBUG_PRINT print(" -- % comparing lines % with % --\n%\n%\n", y, above, below, pattern[above], pattern[below]);

			for x: 0..width {
				if pattern[above][x] != pattern[below][x] diffs += 1;
			}
			above += 1;
			below -= 1;
		}
		if diffs == expected_delta {
			#if DEBUG_PRINT print(" -- found line % \n\n", y);
			return 100 * y;
		}
	}

	for x: 1..width {
		diffs := 0;
		left, right := x-1, x;

		while right <= width && left >= 0 {
			#if DEBUG_PRINT print(" -- % comparing columns % with % \n", x, left, right);

			for y: 0..height {
				#if DEBUG_PRINT print ("% %\n", to_string(*pattern[y][left],1), to_string(*pattern[y][right],1));
				if pattern[y][left] != pattern[y][right] diffs += 1;
			}

			left -= 1;
			right += 1;
		}
		if diffs == expected_delta {
			#if DEBUG_PRINT print(" -- found column % \n\n", x);
			return x;
		}
	}

	assert(false);
	return 0;
}

parta :: (input: string) -> int {
	blocks := String.split(input, "\n\n");;
	sum:=0;
	for blocks sum += analyze(it);
	return sum;
}

partb :: (input: string) -> int {
	blocks := String.split(input, "\n\n");;
	sum:=0;
	for blocks sum += analyze(it, 1);
	return sum;
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 405}], partb, .[.{example, 400}], day);

main :: () {
	execute(parta, partb, valid, day);
}
