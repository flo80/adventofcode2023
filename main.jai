#import "Basic";
#import "File";
#import "File_Utilities";
#import "Compiler";
#import "String";

build :: () {
	options := get_build_options();
    args := options.compile_time_command_line;

	set_build_options_dc(.{do_output=false});
	if args {
		day, ok := string_to_int(args[0]);
		if !ok {
			log_error("Could not parse day");
			exit(1);
		}
		if day < 0 || day > 25 {
			log_error("Invalid day");
			exit(1);
		}

		w := compiler_create_workspace();
        set_build_options(options, w);

		log("Building day %", day);
		filename := tprint("day%.jai", formatInt(day, minimum_digits=2));
		add_build_file(filename, w);

	} else {
		log("Building all days");


		program : String_Builder;
		main: String_Builder;

		append(*main, tprint("main :: () {\n"));
		append(*main, tprint("#load \"../aoc.jai\";\n"));

		for day: 1..25 {
			d := tprint("day%", formatInt(day, minimum_digits=2));

			filename := tprint("%.jai", d);
			content, exists := read_entire_file(filename, log_errors = false);
 			if !exists continue;

			log("Adding %", d);
			lines := split(content, "\n");
			for l, i: lines {
				if starts_with(l, "#load") lines[i] = tprint("// %", l);
				if starts_with(l, "day") lines[i] = tprint("day :: %;", day);
			}
			content = join(..lines,"\n");

			append(*program, tprint("% :: () {\n", d));
			append(*program, tprint("%", content));
			append(*program, tprint("\nmain();\n}\n\n"));

			append(*main, tprint("%();\n", d));
		}
		append(*main, tprint("}\n"));

		append(*program, builder_to_string(*main));
		code := builder_to_string(*program);

		w := compiler_create_workspace();
		set_optimization(*options, .VERY_OPTIMIZED, false);
        set_build_options(options, w);
		add_build_string(code, w);
	}
}

#run build();
