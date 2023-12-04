#import "Basic";
#import "File";
#import "Compiler";

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
		exit(2);
	}
}

#run build();
