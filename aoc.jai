#import "Basic";
#import "Print_Color";
Debug :: #import "Debug";
File :: #import "File";
String :: #import "String";
using,only(for_expansion) HashTable :: #import "Hash_Table";
Math :: #import "Math";
Sort :: #import "Sort";

Example :: struct($R: Type) {
	input: string;
	expected: R;
}

to_lines :: (input: string) -> []string {
	return String.split(String.trim(input), "\n");
}

parse_to_array :: (s: string) -> [..]int {
	result : [..]int;
	i:=0;
	while s {
		nr, ok := String.parse_int(*s);
		assert(ok);
		array_add(*result, nr);
	}
	return result;
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
			print_color("RESULTS FOR %\n", name, day, color=.HI_BLACK, style=.BOLD);
			print_color("https://adventofcode.com/2023/day/%\n", name, day, color=.BLUE, style=.UNDERLINE);

			start := current_time_monotonic();
			a := parta(file);
			endA := current_time_monotonic() ;
			b := partb(file);
			endB := current_time_monotonic() ;

			print("- part a:  %\n", a);
			print("- part b:  %\n", b);

			print("---\nRuntime:   %ms (%ms, %ms)\n",
				formatFloat(0.001 * to_microseconds(endB - start), trailing_width=3, zero_removal=.NO),
				formatFloat(0.001 * to_microseconds(endA - start), trailing_width=3, zero_removal=.NO),
				formatFloat(0.001 * to_microseconds(endB - endA), trailing_width=3, zero_removal=.NO)
			);
			print_color("Tests:     %\n", valid, color=ifx valid then .GREEN else .RED);
		}
		log("Allocated: % bytes.\n---\n\n", context.temporary_storage.total_bytes_occupied);
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


gcd :: (a: $T, b: T) -> T
#modify {
	ti := cast(*Type_Info) T;
	if ti.type == {
		case .INTEGER;
			return true;

		case;
			return false, "Needs integers";
	}
}
{
	if b == 0 return a;
	return gcd(b, a%b);
}

lcm :: (arr : []$T) -> T
#modify {
	ti := cast(*Type_Info) T;
	if ti.type == {
		case .INTEGER;
			return true;
		case;
			return false, "Needs an integer array";
	}
}{
	ans := arr[0];
	for i: 1..arr.count-1 ans = arr[i] / gcd(arr[i], ans) * ans;
	return ans;
}

// Common data structures

Position :: struct {
	x,y: s64;
}

operator == :: inline (a: Position, b: Position) -> bool {
	return a.x == b.x && a.y == b.y;
}

operator + :: inline (a: Position, b: Position) -> Position {
	return .{a.x + b.x, a.y + b.y};
}

hash:: (a: Position) -> u32 { return xx (a.x << 16) | (a.y & 0xffff); }
PositionSet :: HashTable.Table(Position,u8, given_hash_function=hash, given_compare_function=(a,b) => a == b);

manhattan_distance :: inline (pa: Position, pb: Position) -> int {
	return Math.abs(pa.x-pb.x) + Math.abs(pa.y-pb.y);
}


// heapq from https://github.com/python/cpython/blob/3.12/Lib/heapq.py
HeapQueue :: struct(Value_Type: Type, given_lt_compare_function: (Value_Type, Value_Type) -> bool = null) {
	data: [..]Value_Type;
	#if given_lt_compare_function {
        lt :: given_lt_compare_function;
    } else {
        lt :: (a: Value_Type, b: Value_Type) -> bool { return a < b; };
    }
}

heappush :: (heap: *HeapQueue, item: heap.Value_Type) {
	array_add(*(heap.data), item);
	sift_down(heap, 0, heap.data.count - 1);
}

heappop :: (heap: *HeapQueue) -> heap.Value_Type {
	last:heap.Value_Type = pop(*heap.data);

	if heap.data.count {
		returnitem:heap.Value_Type = heap.data[0];
		heap.data[0] = last;
		sift_up(heap, 0);
		return returnitem;
	}

	return last;
}

#scope_file

sift_down :: (heap: *HeapQueue, startpos: int, pos: int) {
	newitem:heap.Value_Type = heap.data[pos];

	while pos > startpos {
		parentpos := (pos - 1) >> 1;
		parent:heap.Value_Type = heap.data[parentpos];

		if heap.lt(newitem, parent) {
			heap.data[pos] = parent;
			pos = parentpos;
			continue;
		}
		break;
	}
	heap.data[pos] = newitem;
}

sift_up :: (heap: *HeapQueue, pos: int) {
	endpos := heap.data.count;
	startpos := pos;
	newitem := heap.data[pos];

	childpos := 2 * pos + 1;
	while childpos < endpos {
		rightpos := childpos + 1;
		if rightpos < endpos && !heap.lt(heap.data[childpos], heap.data[rightpos]) childpos = rightpos;
		heap.data[pos] = heap.data[childpos];
		pos = childpos;
		childpos = 2 * pos + 1;
	}
	heap.data[pos] = newitem;
	sift_down(heap, startpos, pos);
}
