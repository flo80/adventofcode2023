#load "aoc.jai";

DEBUG_PRINT :: false;

exampleA1 :: #string DONE
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
DONE

exampleA2 :: #string DONE
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
DONE

exampleB1a :: #string DONE
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
DONE

exampleB1b :: #string DONE
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........
DONE

exampleB2 :: #string DONE
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
DONE

exampleB3 :: #string DONE
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
DONE


/*
	| is a vertical pipe connecting north and south.
	- is a horizontal pipe connecting east and west.
	L is a 90-degree bend connecting north and east.
	J is a 90-degree bend connecting north and west.
	7 is a 90-degree bend connecting south and west.
	F is a 90-degree bend connecting south and east.
	. is ground; there is no pipe in this tile.
	S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
*/

neighors :: inline (current: Position) -> N: Position, S: Position, E: Position, W: Position {
	cx, cy := current.x, current.y;

	N := Position.{cx,cy-1};
	S := Position.{cx,cy+1};
	E := Position.{cx+1,cy};
	W := Position.{cx-1,cy};
	return N, S, E, W;
}

possible_N_chars :: u8.[#char "|", #char "7", #char "F"];
possible_S_chars :: u8.[#char "|", #char "L", #char "J"];
possible_E_chars :: u8.[#char "-", #char "J", #char "7"];
possible_W_chars :: u8.[#char "-", #char "L", #char "F"];

step :: (lines: []string, previous: Position, current: Position) -> new_previous: Position, new_current: Position {
	options:[2]Position;
	N, S, E, W := neighors(current);
	c := lines[current.y][current.x];

	if c == {
		case #char "|"; options[0] = N; options[1] = S;
		case #char "-"; options[0] = E; options[1] = W;
		case #char "L"; options[0] = N; options[1] = E;
		case #char "J"; options[0] = N; options[1] = W;
		case #char "7"; options[0] = S; options[1] = W;
		case #char "F"; options[0] = S; options[1] = E;
		case; assert(false, "unknown character");
	}

	if options[0] == previous return current, options[1];
	else return current, options[0];
}

follow_until :: (lines: []string, start: Position, current: Position) -> int, []Position {
	history : [..]Position;
	array_add(*history, start);

	count := 1;
	previous, curr := start, current;
	while curr != start {
		array_add(*history, curr);
		previous, curr = step(lines, previous, curr);
		count += 1;
	}
	return count, history;
}


find_loop :: (input: string) -> int, PositionSet, []string, start:Position, start_char: u8 {
	lines := to_lines(input);

	start : Position;
	for l, y: lines  {
		if !l continue;
		for x: 0..l.count-1 {
			if l[x] == #char "S" {
				start = .{x, y};
				break l;
			}
		}
	}

	N, S, E, W := neighors(start);

	possible :: (lines: []string, start: Position, current: Position, options: []u8) -> bool {
		if current.y < 0 || current.y > lines.count return false;
		if current.x < 0 || current.x > lines[current.y].count return false;

		c := lines[current.y][current.x];
		for o: options if o == c return true;
		return false;
	}

	try :: (lines: []string, start: Position, current: Position, options: []u8) -> int, []Position {
		if !possible(lines, start, current, options) return -1, Position.[];

		count, history := follow_until(lines, start, current);
		return count, history;
	}

	start_char: u8;
	cnt: int;
	history : []Position;

	possible_N := possible(lines, start, N, possible_N_chars);
	possible_S := possible(lines, start, S, possible_S_chars);
	possible_E := possible(lines, start, E, possible_E_chars);
	possible_W := possible(lines, start, W, possible_W_chars);

	if possible_N && possible_S {
		start_char = #char "|";
		assert(!possible_W && !possible_E);
		cnt, history = try(lines, start, N, possible_N_chars);
	}
	if possible_W && possible_E {
		start_char = #char "-";
		assert(!possible_N && !possible_S);
		cnt, history = try(lines, start, E, possible_E_chars);
	}
	if possible_N && possible_E {
		start_char = #char "L";
		assert(!possible_S && !possible_W);
		cnt, history = try(lines, start, N, possible_N_chars);
	}
	if possible_N && possible_E {
		start_char = #char "J";
		assert(!possible_S && !possible_E);
		cnt, history = try(lines, start, N, possible_N_chars);
	}
	if possible_S && possible_W {
		start_char = #char "7";
		assert(!possible_N && !possible_E);
		cnt, history = try(lines, start, S, possible_S_chars);
	}
	if possible_S && possible_E {
		start_char = #char "F";
		assert(!possible_N && !possible_W);
		cnt, history = try(lines, start, S, possible_S_chars);
	}

	assert(cnt > 0);

	ht: PositionSet;
	for p: history HashTable.table_add(*ht,p,0);

	return cnt, ht, lines, start, start_char;
}

parta :: (input: string) -> int {
	cnt := find_loop(input);
	return cnt/2;
}

partb :: (input: string) -> int {
	cnt, loop, lines, start, start_char := find_loop(input);
	lines[start.y][start.x] = start_char;

	contains :: inline (pos: Position, loop: PositionSet) -> bool {
		return HashTable.table_contains(*loop, pos);
	}


	cnt = 0;
    is_region := false;
    previous_edge := #char " ";

	for l, y: lines {
		for x:0..l.count-1 {
			loop_tile := contains(.{x,y}, loop);
			c := l[x];

			// if the cell is not a pipe of the loop and we are in a region
            if !loop_tile && is_region {
				#if DEBUG_PRINT	l[x] = #char "I";
				cnt += 1;
				continue;
			}

            // if the cell is a pipe of the loop
			// a pipe down always switches the region
			// a pipe right doesn't affect the region
			//
			// a pipe edge pointing to the right
			// will begin a series of 0..n "-" pipes ending with either J or 7
			// we count each L----J or F----7 as non existent
			// and each L----7 or F----J as existent region boundary
			//
			// a pipe edge pointing to the left
			// if previous edge wasn't pointing up switch region
            //
			// a pipe edge pointing to the right
			// if previous edge wasn't pointing down switch region
            if loop_tile {
                if c == #char "|" is_region = !is_region;
                else if c == #char "-" continue;
                else if c == #char "L" || c == #char "F" previous_edge = c;
                else if c == #char "J" {
                    if previous_edge == #char "F" is_region = !is_region;
                    previous_edge = #char " ";
				}
                else if c == #char "7" {
                    if previous_edge == #char "L" is_region = !is_region;
                    previous_edge =  #char " ";
				}
			}
		}
	}

	print_loop :: (lines: []string, loop: PositionSet) {
		print("\n");
		for l, y: lines {
			o := l;
			for x:0..l.count-1 {
				if l[x] == #char "I" continue;
				else if l[x] == #char "." o[x] = #char "O";
				else if contains(.{x,y}, loop) o[x] = #char "+";
				else o[x] = #char " ";
			}
			print("%\n", o);
		}
		print("\n");
	}

	#if DEBUG_PRINT print_loop(lines, loop);

	return cnt;
}

day :: #run get_day();
valid :: #run test(parta, .[.{exampleA1, 4}, .{exampleA2, 8}], partb, .[.{exampleB1a, 4}, .{exampleB1b, 4}, .{exampleB2, 8}, .{exampleB3, 10}], day);

main :: () {
	execute(parta, partb, valid, day);
}
