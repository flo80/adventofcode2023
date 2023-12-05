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
	destination: s64;
	source: s64;
	range: s64;
}

SeedRange :: struct {
	start: s64;
	length: s64;
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
		dest := String.parse_int(*line, s64);
		source := String.parse_int(*line, s64);
		range := String.parse_int(*line, s64);

		array_add(*maps[current_map], .{dest, source, range});
		i += 1;
	}
	return maps;
}


parta :: (input: string) -> int {
	get :: (map: []Mapping, source: s64) -> s64 {
		dest: s64 = source;
		for s: map {
			if source >= s.source && source <= s.source + s.range {
				offset := source - s.source;
				dest = s.destination + offset;
				break;
			}
		}
		return dest;
	}

	get_chain :: (maps: [7][..]Mapping, source: s64) -> s64 {
		dest := source;
		for maps dest = get(it, dest);
		return dest;
	}


	lines := to_lines(input);

	// seeds
	seeds : [..]s64;
	seed_line := lines[0];
	eat_including_char(*seed_line, #char ":");
	while seed_line {
		nr : s64;
		nr=, ok := String.parse_int(*seed_line, s64);
		if !ok { log_error("parse error %", seed_line); exit(1); }
		array_add(*seeds, nr);
	}

	maps:=parse_maps(lines);

	minimum: s64 = -1;
	for seed: seeds {
		location: s64 = get_chain(maps, seed);
		minimum = ifx minimum < 0 then location else min(location, minimum);
	}

	return minimum;
}


partb :: (input: string) -> int {
	get_reverse :: (map: []Mapping, dest: s64) -> s64 {
		source: s64 = dest;
		for s: map {
			if dest >= s.destination && dest <= s.destination + s.range {
				offset := dest - s.destination;
				source = s.source + offset;
				break;
			}
		}
		return source;
	}

	get_reverse_chain :: (maps: [7][..]Mapping, dest: s64) -> s64 {
		source := dest;
		for <maps source = get_reverse(it, source);
		return source;
	}


	has_seed :: (seeds: []SeedRange, seed: s64) -> bool {
		for s: seeds {
			if seed >= s.start && seed < s.start + s.length return true;
		}
		return false;
	}

	lines := to_lines(input);
	maps := parse_maps(lines);


	seeds : [..]SeedRange;
	seed_line := lines[0];
	eat_including_char(*seed_line, #char ":");
	while seed_line {
		start := String.parse_int(*seed_line, s64);
		length := String.parse_int(*seed_line, s64);
		array_add(*seeds, .{start, length});
	}

	for location : 1..1_000_000_000 {
		seed := get_reverse_chain(maps, location);
		if has_seed(seeds, seed) return location;
	}

	return -1;
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 35}], partb, .[.{example, 46}], day);

main :: () {
	execute(parta, partb, valid, day);
}
