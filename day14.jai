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
	lines := to_lines(input);

	height := lines.count-1;
	while !lines[height] height-=1;
	width := lines[0].count-1;
	assert(width == height);
	assert(width <= 100);

	grid :[100][100]u8;
	for y:0..height {
		for x:0..width {
			grid[y][x] = lines[y][x];
		}
	}

	score :: () -> int #expand {
		sum := 0;
		for x:0..width for y:0..height if grid[y][x] == #char "O" sum += height - y + 1;
		return sum;
	}

	roll :: () #expand {
		for x:0..width {
			for dest:0..height {
				if grid[dest][x] != #char"." continue;

				for y:dest..height {
					if grid[y][x]==#char"O" {
						grid[dest][x]=#char"O";
						grid[y][x]=#char".";
						continue dest;
					}
					if grid[y][x]==#char"#" {
						dest = y;
						continue dest;
					}
				}
			}
		}
	}

	rotate :: () #expand {
		temp:[100][100]u8;
		for x:0..width for y:0..height temp[x][height-y] = grid[y][x];
		grid = temp;
	}

	cycle :: inline () #expand {
		for i:1..4 {
			roll();
			rotate();
		}
	}

	need_cycle:=true;
	seen : [..][100][100]u8;
	array_add(*seen, grid);

	cmp_grid :: (a: [100][100]u8, b:[100][100]u8) -> bool #expand {
		for i:0..width for j:0..height if a[i][j] != b[i][j] return false;
		return true;
	}

	c := 0;
	target :: 1000000000;
	while c < target {
		c+=1;

		cycle();
		array_add(*seen, grid);

		exists:= false;
		index := 0;
		if need_cycle while index < c {
			same := cmp_grid(grid, seen[index]);
			if same {
				exists = true;
				break;
			}
			index += 1;
		}

		if exists {
			cycle_length := c-index;
			skip_count := (target-c)/cycle_length;
			c += skip_count * cycle_length;

			need_cycle = false;
		}
	}

	return score();
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 136}], partb, .[.{example, 64}], day);

main :: () {
	execute(parta, partb, valid, day);
}
