#load "aoc.jai";

example :: #string DONE
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
DONE

parse_input :: (input: string) -> []Position, empty_lines: []int, empty_rows: []int {
	galaxies : [..]Position;
	empty_lines, empty_rows: [..]int;

	lines := to_lines(input);

	for line, y: lines {
		for x: 0..line.count-1 {
			if line[x] == #char "#" array_add(*galaxies, .{x,y});
		}
	}

	for x: 0..lines[0].count-1 {
		for p: galaxies if p.x == x continue x;
		array_add(*empty_rows, x);
	}

	for y: 0..lines.count-1 {
		for p: galaxies if p.y == y continue y;
		array_add(*empty_lines, y);
	}

	return galaxies, empty_lines, empty_rows;
}

solve :: (input: string, increase: int = 1) -> int {
	delta := ifx increase == 1 then 1 else increase-1;
	galaxies, empty_lines, empty_rows := parse_input(input);

	for <y: empty_lines {
		for *p: galaxies {
			if (<<p).y > y then (<<p).y += delta;
		}
	}

	for <x: empty_rows {
		for *p: galaxies {
			if (<<p).x > x then (<<p).x += delta;
		}
	}

	sum := 0;
	for a: 0..galaxies.count-1 {
		for b: a..galaxies.count-1 {
			sum += manhattan_distance(galaxies[a], galaxies[b]);
		}
	}

	return sum;
}

parta :: (input: string) -> int {
	return solve(input);
}

partb :: (input: string) -> int {
	return solve(input, 1000000);
}

solveB1 :: (input: string) -> int { return solve(input, 100); }

day :: #run get_day();
valid :: #run test(parta, .[.{example, 374}], solveB1, .[.{example, 8410}], day);

main :: () {
	execute(parta, partb, valid, day);
}
