#import "Basic";
Debug :: #import "Debug";
File :: #import "File";
String :: #import "String";
HashTable :: #import "Hash_Table";
Math :: #import "Math";

Example :: struct($R: Type) {
	input: string;
	expected: R;
}

to_lines :: (input: string) -> []string {
	return String.split(input, "\n");
}

Correct :: enum {
	UNKNOWN;
	NO_TEST;
	PASSED;
	FAILED;
}


test :: (parta: (string) -> $RA, examplesA: []Example(RA), partb: (string) -> $RB, examplesB: []Example(RB), day: int) -> Correct #expand  {
    Debug.init();
	correct: Correct = .UNKNOWN;
	check := true;

	ctx := context;
	ctx.allocator = temp;
	push_context ctx {
		print("EXAMPLES DAY %\n", day);
		for example, i: examplesA {
			r := parta(example.input);
			print("part a (%): % -- %\n", i+1, r, r == example.expected);
			check &&= r == example.expected;
		}
		for example, i: examplesB {
			r := partb(example.input);
			print("part b (%): % -- %\n", i+1, r, r == example.expected);
			check &&= r == example.expected;
		}
		if !examplesA || !examplesB {
			log_error("no examples (for both parts) provided\n");
			correct = .NO_TEST;
		} else {
			correct = ifx check then .PASSED else .FAILED;
		}
	}

	if !check log_error("not all tests passed\n\n");
	else log("all tests passed\n\n");
	return correct;
}

get_day :: (loc := #caller_location) -> int {
	f:= loc.fully_pathed_filename;
	pos := String.find_index_from_left(f, "day");
	if pos < 0 return 0;

	dnr := String.slice(f, pos + 3, 2);
	nr, ok := string_to_int(dnr);
	return ifx ok then nr else 0;
}

execute :: (parta: (string) -> $RA, partb: (string) -> $RB, valid: Correct = .NO_TEST, day: int) #expand  {
    Debug.init();

	ctx := context;
	ctx.allocator = temp;
	push_context ctx {
		args := get_command_line_arguments();
		name: string;

		if args.count > 1 {
			name = args[1];
		} else if day > 0 {
			name = tprint("day%.txt", formatInt(day, minimum_digits=2));
		} else {
			log_error("No input file provided\n");
			exit(1);
		}

		file, ok := File.read_entire_file(name);
		if !ok {
			log_error("Could not read %\n", file);
			exit(1);
		} else {
			print("RESULTS FOR %\n", name);

			a := parta(file);
			print("- part a: % \n", a);

			b := partb(file);
			print("- part b: % \n", b);

			print("Tests: %\n\n", valid);
		}
		// log("Temporary_Storage used % bytes.\n", context.temporary_storage.total_bytes_occupied);
		reset_temporary_storage();
	}
}

// helper functions

char_to_int:: inline (c: u8) -> u8, bool {
	if !is_digit(c) return 0, false;
	return c - #char "0", true;
}

split_by_any :: (s: string, bytes: string, allocator := temp) -> (result: [] string) {
	results: [..] string;
    results.allocator = allocator;

	remainder := s;
    while remainder {
        found, left, right := String.split_from_left_by_any(remainder, bytes);
        if found {
            array_add(*results, left);
        } else {
            array_add(*results, remainder);
            break;
        }

        remainder = right;
    }

    if !remainder array_add(*results, "");  // We want 'split' to return an unambiguous result (was there a match at the end or not?), and to be the inverse of 'join'. For this to happen, if there was a match at the very end, we just add an empty string. Maybe there is a more elegant way to structure the loop to make this happen.

    return results;
}

eat_including_char :: (s: *string, char: u8) {
	while s && (<<s)[0] != char advance(s, 1);
	if s advance(s, 1);
}

reduce :: inline (array: []$T, f: (acc: R, value: T) -> R, start: $R) -> R {
	acc:R = start;
	for array f(acc, it);
	return acc;
}

reduce :: inline (array: []$T, f: (acc: R, value: T) -> $R) -> R {
	acc:R;
	for array acc = f(acc, it);
	return acc;
}

sum_array :: (array: []$T) -> $R
#modify {
	R = T;
	ti := cast(*Type_Info) T;
	if ti.type == {
		case .INTEGER;
			R = int;
			return true;

		case .FLOAT;
			return true;

		case;
			return false, "Needs a numeric array";
	}
}
{
	result : R;
	for array result += it;
	return result;
}
