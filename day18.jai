#load "aoc.jai";

example :: #string DONE
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
DONE

parta :: (input: string) -> int {
	previous, current: Position;
	sum, outline, count : s64;

	lines := to_lines(input);

	for lines {
		if !it continue;

		dir := it[0];
		advance(*it, 2);
		nr := String.parse_int(*it);

		if dir == {
			case #char "U"; current.y -= nr;
			case #char "D"; current.y += nr;
			case #char "L"; current.x -= nr;
			case #char "R"; current.x += nr;
		}
		sum += previous.x * current.y - current.x * previous.y;
		outline += nr;
		count +=1 ;

		previous = current;
	}

	assert(current == .{0,0}, "did not make it back %", current);

	interior_area := sum/2 ;
	interior_points := interior_area + 1 - outline / 2;

	return outline + interior_points;
}

partb :: (input: string) -> int {
	previous, current: Position;
	sum, outline, count : s64;

	lines := to_lines(input);

	for lines {
		if !it continue;

		eat_including_char(*it, #char "#");

		dir := it[5];
		nr := string_to_int(String.slice(it, 0,5), base = 16);

		if dir == {
			case #char "0"; current.x += nr;
			case #char "1"; current.y += nr;
			case #char "2"; current.x -= nr;
			case #char "3"; current.y -= nr;
		}
		sum += previous.x * current.y - current.x * previous.y;
		outline += nr;
		count +=1 ;

		previous = current;
	}

	assert(current == .{0,0}, "did not make it back %", current);

	interior_area := sum/2 ;
	interior_points := interior_area + 1 - outline / 2;

	return outline + interior_points;
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 62}], partb, .[.{example, 952408144115}], day);

main :: () {
	execute(parta, partb, valid, day);
}
