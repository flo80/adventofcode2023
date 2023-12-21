#load "aoc.jai";

example :: #string DONE
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
DONE

neighors:: Position.[.{-1,0},.{1,0},.{0,-1},.{0,1}];

solveA :: (input: string, $iterations: int) -> int {
	lines := to_lines(input);
	starting: Position;
	width := lines[0].count-1;
	height := lines.count-1;
	while !lines[height] height-=1;

	for y: 0..height for x: 0..width if lines[y][x] == #char "S" {
		starting = .{x,y};
		break y;
	}

	p :: (current: PositionSet) #expand {
		for y: 0..height {
			for x: 0..width {
				if HashTable.table_contains(*current, .{x,y}) print("O");
				else print("%", to_string(*lines[y][x], 1));
			}
			print("\n");
		}
		print("\n");
	}

	step :: (current: PositionSet) -> PositionSet #expand {
		new_pos:PositionSet;
		for _, pos: current for d: neighors {
			np := pos + d;
			if np.x < 0 || np.x > width continue;
			if np.y < 0 || np.y > height continue;
			if lines[np.y][np.x] == #char "#" continue;
			HashTable.table_set(*new_pos, np, 0);
		}
		return new_pos;
	}

	positions: PositionSet;
	HashTable.table_set(*positions, starting, 0);
	for i:1..iterations positions = step(positions);
	return positions.count;
}

partb :: (input: string) -> int {
	return -1;
}

parta :: input => solveA(input, 64);
example1A :: input => solveA(input, 6);

day :: #run get_day();
valid :: #run test(example1A, .[.{example, 16}], partb, .[.{example, 0}], day);

main :: () {
	execute(parta, partb, valid, day);
}
