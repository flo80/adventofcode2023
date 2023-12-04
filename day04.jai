#load "aoc.jai";

example :: #string DONE
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
DONE

check_scratchcard :: (card: string) -> count: int {
	fill_array :: (s: *string, a: *[$N]int) {
		if !s return;
		for * <<a {
			<<it = String.parse_int(s);
			if !s break;
		}
	}

	count_wins :: (wins : [$A]int, nums : [$B]int) -> int {
		cnt := 0;
		for w: wins {
			if w == 0 break;
			for n: nums {
				if n == 0 break;
				if w == n cnt += 1;
			}
		}
		return cnt;
	}

	wins : [10]int;
	nums : [25]int;

	parts := split_by_any(card, ":|");
	fill_array(*parts[1], *wins);
	fill_array(*parts[2], *nums);

	return count_wins(wins, nums);
}


parta :: (input: string) -> int {
	lines := to_lines(input);

	sum : int = 0;
	for line: lines {
		if !line continue;

		cnt := check_scratchcard(line);
		if cnt > 1 cnt = 1 << (cnt-1);
		sum += cnt;
	}
	return sum;
}


partb :: (input: string) -> int {
	lines := to_lines(input);

	copies : [300]int;

	for line, i: lines {
		if !line continue;
		copies[i] += 1;

		cnt := check_scratchcard(line);
		for 1..cnt copies[i+it] += copies[i];
	}

	return sum_array(copies);
}

main :: () {
	execute(parta, partb, valid, day);
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 13}], partb, .[.{example, 30}]);
