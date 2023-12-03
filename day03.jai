#load "aoc.jai";

example :: #string DONE
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
DONE


parta :: (lines: []string) -> int {
	sum : int = 0;

	maxX := lines[0].count - 1;

	check :: (lines: []string, x: int, y: int) -> bool {
		if x < 0 || x >= lines[0].count || y < 0 || y >= lines.count-1 return false;
		c := lines[y][x];
		if c == #char "." || is_digit(c) return false;
		return true;
	}

	current_number:int;
	in_number:bool = false;
	counts:bool = false;
	for line, y: lines  {
		if !line continue;

		for x: 0..maxX {
			char := line[x];

			if is_digit(char) {
				if !in_number  {
					// started new number
					in_number = true;
					current_number = 0;
					counts = check(lines, x-1, y-1)
						   | check(lines, x-1, y)
						   | check(lines, x-1, y+1);
				}
				counts |= check(lines, x, y-1)
				        | check(lines, x, y+1);

				current_number = current_number * 10 + char_to_int(char);
			} else {
				if !in_number continue;
				counts |= check(lines, x, y-1)
						| check(lines, x, y)
						| check(lines, x, y+1);

				if counts sum += current_number;
				in_number = false;
			}
		}
	}
	return sum;
}


partb :: (lines: []string) -> int {
	sum : int = 0;
	maxX := lines[0].count - 1;

	find_num :: (lines: []string, x: int, y: int) -> found: bool, nr: int {
		if y < 0 || y > lines.count return false, 0;
		line := lines[y];

		if !is_digit(line[x]) return false, 0;

		nr : int = 0;
		while x >= 0 && is_digit(line[x]) x -= 1;
		x += 1;
		while x < line.count && is_digit(line[x]) {
			nr = nr * 10 + char_to_int(line[x]);
			x += 1;
		}
		return true, nr;
	}


	for line, y: lines  {
		if !line continue;

		for x: 0..maxX {
			char := line[x];

			if char == #char "*" {
				options: [2]int;

				for dx: -1..1 {
					for dy: -1..1 {
						found, nr := find_num(lines, x+dx, y+dy);
						if found {
							if options[0] == nr || options[1] == nr continue;
							else if options[0] == 0 options[0] = nr;
							else if options[1] == 0 options[1] = nr;
							else assert(false);
						}
					}
				}
				ratio := options[0] * options[1];
				sum += ratio;
			}
		}
	}

	return sum;
}

main ::() {
	execute(parta, partb, .{example, 4361}, .{example, 467835});
}
