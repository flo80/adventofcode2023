#import "Basic";
Debug :: #import "Debug";
File :: #import "File";
String :: #import "String";
HashTable :: #import "Hash_Table";

Example :: struct {
	input: string;
	expected: int;
}

execute :: (parta: ([]string) -> int, partb: ([]string) -> int, examples: .. Example) #expand  {
    Debug.init();

	args := get_command_line_arguments();

	if args.count > 1 {
		name := args[1];
		file, ok := File.read_entire_file(name);
		if !ok {
			print("Could not read %\n", file);
			exit(1);
		} else {
			print("RESULTS FOR %\n", name);

			lines := String.split(file, "\n");

			a := parta(lines);
			print("part a: % \n", a);

			b := partb(lines);
			print("part b: % \n", b);
		}
	} else {
		print("EXAMPLES\n");
		if examples.count == 0 {
			print("no examples provided\n");
			exit(1);
		} else if examples.count == 1 {
			a := parta(String.split(examples[0].input, "\n"));
			print("part a: % -- %\n", a, a == examples[0].expected);
		} else {
			a := parta(String.split(examples[0].input, "\n"));
			b := partb(String.split(examples[1].input, "\n"));
			print("part a: % -- %\n", a, a == examples[0].expected);
			print("part b: % -- %\n", b, b == examples[1].expected);
		}
	}
}

// helper functions

char_to_int:: (c: u8) -> u8, bool {
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
