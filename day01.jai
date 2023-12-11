#load "aoc.jai";

example1 :: #string DONE
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
DONE

example2 :: #string DONE
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
DONE


parta :: (input: string) -> int {
	lines := to_lines(input);
	sum : int = 0;
	for lines {
		first, last := 0, 0;

		if !it continue;
		for i: 0..it.count-1 {
			nr, ok := char_to_int(it[i]);
			if !ok continue;

			if first == 0 first = nr;
			last = nr;
		}

		sum += first * 10 + last;
		// print("Checking line '%': % % \n", it, first, last);

	}
	return sum;
}

partb :: (input: string) -> int {
	words :: string.["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];
	lines := to_lines(input);
	sum : int = 0;

	for lines {
		first, last := 0, 0;

		if !it continue;
		for i: 0..it.count-1 {
			nr, ok := char_to_int(it[i]);
			if !ok {
				substr := String.slice(it, i, it.count - 1);
				for w: 0..words.count-1 {
					if String.starts_with(substr, words[w]) {
						nr, ok = cast(u8) (w + 1), true;
						break;
					}
				}
			}

			if !ok continue;
			if first == 0 {first = nr; break i;}
		}

		for <i: it.count-1..0 {
			nr, ok := char_to_int(it[i]);
			if !ok {
				substr := String.slice(it, i, it.count - 1);
				for w: 0..words.count-1 {
					if String.starts_with(substr, words[w]) {
						nr, ok = cast(u8) (w + 1), true;
						break;
					}
				}
			}

			if !ok continue;
			if last == 0 {last = nr; break i;}
		}

		sum += first * 10 + last;
		// print("Checking line '%': % % \n", it, first, last);

	}
	return sum;
}


day :: #run get_day();
valid :: #run test(parta, .[.{example1, 142}], partb, .[.{example2, 281}], day);

main :: () {
	execute(parta, partb, valid, day);
}
