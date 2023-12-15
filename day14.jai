#load "aoc.jai";

example :: #string DONE
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
DONE

parta :: (input: string) -> int {
	lines := to_lines(input);
	height := lines.count-1;
	width := lines[0].count-1;
	sum := 0;

	for x:0..width {
		empty : [..]int;

		for l,y:lines {
			if !l continue;

			c := l[x];
			weight := height - y;

			if c == {
				case #char "#"; array_reset(*empty);
				case #char "."; array_insert_at(*empty, weight, 0);
				case #char "O";
				print ("Found % % -- % %\n", x, y, empty, weight);
					if empty {
						sum += pop(*empty);
						array_insert_at(*empty, weight, 0);
					} else {
						sum += weight;
					}
			}
		}
	}
	return sum;
}

partb :: (input: string) -> int {
	return -1;
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 136}], partb, .[.{example, 64}], day);

main :: () {
	execute(parta, partb, valid, day);
}
