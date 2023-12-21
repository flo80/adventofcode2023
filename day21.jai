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

Point :: struct
{
    x, y: s16;
    #place x;
    hash: u32;
}

neighors:: Point.[.{-1,0},.{1,0},.{0,-1},.{0,1}];

solve_multiple :: (input: string, iterations: []int) -> []int {
	#import "Hash_Table";

	mod :: inline (val: int) -> int #expand {
		res := val % size;
		return ifx res < 0 then res + size else res;
	}

	lines := to_lines(input);
    size := lines[0].count;

	results: [..]int;
	current_target := *iterations[0];

	s1, s2 : Table(u32, u8);
    q1, q2 : Table(u32, u8);

	for y: 0..size-1 for x: 0..size-1 {
		if lines[y][x] == #char "S" {
		    table_set(*q1, Point.{xx x,xx y}.hash, 0);
			break y;
		}
	}

	for 0..Math.S64_MAX {
        seen_curr  := ifx it % 2 == 0 then *s1 else *s2;
        seen_prev  := ifx it % 2 == 1 then *s1 else *s2;
        queue_curr := ifx it % 2 == 0 then *q1 else *q2;
        queue_next := ifx it % 2 == 1 then *q1 else *q2;

        for _, curr: queue_curr
        {
            table_set(seen_curr, curr, 0);

            for dir: neighors
            {
                p := Point.{hash = curr};
                p.x += dir.x;
                p.y += dir.y;
                if lines[mod(p.y)][mod(p.x)] == #char "#" continue;
                if table_contains(seen_prev, p.hash) continue;
                table_set(queue_next, p.hash, 0);
            }
        }

        table_reset(queue_curr);

        if it == <<current_target {
			array_add(*results, seen_curr.count);
			if results.count == iterations.count break;
			current_target += 1;
		}
    }

	return results;
}


solveA :: (input: string, iteration: int) -> int {
	return solve_multiple(input, .[iteration])[0];
}

solveB :: (input: string, $iterations: int) -> int {
	simplifiedLagrange :: (v: []int) -> (a: s64, b: s64, c: s64) {
		a := (v[0] / 2 - v[1] + v[2] / 2);
		b := (-3 * (v[0] / 2) + 2 * v[1] - v[2] / 2);
		c := v[0];

		return a, b, c;
	}


	values := solve_multiple(input, .[65, 65 + 131, 65 + 131 * 2]);
	a, b, c := simplifiedLagrange(values);
	target := (iterations - 65) / 131;
	return a * target * target + b * target + c;
}

parta :: input => solveA(input, 64);
exampleA1 :: input => solveA(input, 6);
exampleB1 :: input => solveA(input, 50);

partb :: input => solveB(input, 26501365);

day :: #run get_day();
valid :: #run test(exampleA1, .[.{example, 16}], exampleB1, .[.{example, 1594}], day);

main :: () {
	execute(parta, partb, valid, day);
}
