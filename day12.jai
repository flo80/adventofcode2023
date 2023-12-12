#load "aoc.jai";

// # is damaged
// . is operational
// numbers are count of #
example :: #string DONE
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
DONE

Cache :: HashTable.Table(s64, int);

advance :: inline (array: []int) -> []int {
	new := array;
	new.data += 1;
	new.count -= 1;
	return new;
}

process_line :: (line: string) -> string, []int {
	counts :[..]int;
	data := String.split(line, " ");
	conditions, s := data[0], data[1];
	while s {
		nr, ok := String.parse_int(*s, spaces=",");
		assert(ok);
		array_add(*counts, nr);
	}
	return conditions, counts;
}

count :: (cache: *Cache, conditions: string, groups: []int, curr:= 0) -> int #expand {
	hash := conditions.count << 48 + curr << 32 + groups.count;
	res, found := HashTable.table_find(cache, hash);
	if found return res;

	res = count_uncached(cache, conditions, groups, curr);
	HashTable.table_add(cache, hash, res);
	return res;
}

count_uncached :: (cache: *Cache, conditions: string, groups: []int, curr:= 0) -> int {
	continue_run :: () -> int #expand {
		return count(cache, advance(conditions), groups, curr+1);
	}

	end_run :: () -> int #expand {
		if !curr return count(cache, advance(conditions), groups, 0);
		if (curr && !groups) || curr != groups[0] return 0;
        return count(cache, advance(conditions), advance(groups), 0);
	}

	if !conditions {
		if groups.count >= 2          return 0;
        if groups.count == 0 &&  curr return 0;
        if groups.count == 0 && !curr return 1;
        if curr == groups[0]          return 1;
        else                          return 0;
	}

	if curr > groups[0] return 0;

	if conditions[0] == {
		case #char "#"; return continue_run();
		case #char "."; return end_run();
		case; return continue_run() + end_run();
	}
}

count_all_lines :: (input: string, copies: int = 1) -> int {
	cache : Cache;

	lines := to_lines(input);
	sum := 0;

	for line: lines {
		if !line continue;
		cond_part, counts := process_line(line);

		builder : String_Builder;
		amounts : [..]s64;
		for 1..copies
		{
			append(*builder, ifx it < copies tprint("%?", cond_part) else cond_part);
			array_add(*amounts, ..counts);
		}

		conditions := builder_to_string(*builder);
		sum += count(*cache, conditions, amounts);

		// avoid false positives
		HashTable.table_reset(*cache);
	}
	return sum;
}


parta :: (input: string) -> int {
	return count_all_lines(input);
}

partb :: (input: string) -> int {
	return count_all_lines(input, 5);
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 21}], partb, .[.{example, 525152}], day);

main :: () {
	execute(parta, partb, valid, day);
}
