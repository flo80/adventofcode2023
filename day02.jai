#load "aoc.jai";

example :: #string DONE
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
DONE


parta :: (input: string) -> int {
	lines := to_lines(input);

	maximums :: (c: string) -> int {
		if c == {
			case "red"; return 12;
			case "green"; return 13;
			case "blue"; return 14;
			case; assert(false); return 0;
		}
	}

	sum : int = 0;
	for lines {
		if !it continue;

		tokens := split_by_any(it, " :,;");

		impossible := false;
		id := string_to_int(tokens[1]);

		i := 3;
		while i < tokens.count {
			nr := string_to_int(tokens[i]);
			color := tokens[i+1];
			i += 3;

			impossible |= nr > maximums(color);
		}
		if !impossible sum+= id;
	}
	return sum;
}

partb :: (input: string) -> int {
	lines := to_lines(input);
	sum : int = 0;
	for lines {
		if !it continue;

		tokens := split_by_any(it, " :,;");
		required := int.[1,1,1];

		i := 3;
		while i < tokens.count {
			nr := string_to_int(tokens[i]);
			color := tokens[i+1];
			i += 3;

			index : int;
			if color == {
				case "red"; index = 0;
				case "green"; index = 1;
				case "blue"; index = 2;
				case; assert(false); index = -1;
			}
			required[index] = max(required[index], nr);
		}
		power := 1;
		for required power *= it;
		sum += power;
	}
	return sum;
}


day :: #run get_day();
valid :: #run test(parta, .[.{example, 8}], partb, .[.{example, 2286}], day);

main :: () {
	execute(parta, partb, valid, day);
}
