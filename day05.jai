#load "aoc.jai";

example :: #string DONE
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
DONE

Mapping :: struct {
	start: s64;
	end: s64;
	offset: s64;
}

Range :: struct {
	start: s64;
	end: s64;
}

parse_maps :: (lines: []string) -> [7][..]Mapping {
	maps : [7][..]Mapping;
	current_map := 0;
	i := 3;
	while i < lines.count {
		line := lines[i];
		if !line {
			current_map += 1;
			i += 2;
			continue;
		}
		destination := String.parse_int(*line, s64);
		source := String.parse_int(*line, s64);
		range := String.parse_int(*line, s64);

		array_add(*maps[current_map], .{start = source, end = source + range-1, offset = destination - source});
		i += 1;
	}
	return maps;
}

process_mapping :: (previous : []Range, maps: []Mapping) -> []Range {
	ranges : [..]Range;
	next : [..]Range;

	array_add(*ranges, ..previous);

	while ranges {
		range := pop(*ranges);
		found := false;

		for mapping: maps {
			if range.start > mapping.end || range.end < mapping.start continue;
			found = true;

			new := array_add(*next);
			new.start = max(range.start, mapping.start) + mapping.offset;
			new.end = min(range.end, mapping.end) + mapping.offset;

			if range.start < mapping.start {
				before := array_add(*ranges);
				before.start = range.start;
				before.end = mapping.start - 1;
			}

			if range.end > mapping.end {
				after := array_add(*ranges);
				after.start = mapping.end + 1;
				after.end = range.end;
			}

			break;
		}

		if !found array_add(*next, range);
	}
	return next;
}

find_lowest_location :: (seeds: []Range, maps: [][..]Mapping) -> s64 {
	ranges : []Range = seeds;
	for maps ranges = process_mapping(ranges, it);

	minimum := ranges[0].start;
	for ranges minimum = min(minimum, it.start);

	return minimum;
}

parta :: (input: string) -> int {
	lines := to_lines(input);
	seeds : [..]Range;

	seed_line := lines[0];
	eat_including_char(*seed_line, #char ":");
	while seed_line {
		start := String.parse_int(*seed_line, s64);
		array_add(*seeds, .{start, start});
	}

	maps := parse_maps(lines);
	return find_lowest_location(seeds, maps);
}

partb :: (input: string) -> int {
	lines := to_lines(input);
	seeds : [..]Range;

	seed_line := lines[0];
	eat_including_char(*seed_line, #char ":");
	while seed_line {
		start := String.parse_int(*seed_line, s64);
		length := String.parse_int(*seed_line, s64);
		array_add(*seeds, .{start, start + length - 1});
	}

	maps := parse_maps(lines);
	return find_lowest_location(seeds, maps);
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 35}], partb, .[.{example, 46}], day);

main :: () {
	execute(parta, partb, valid, day);
}
