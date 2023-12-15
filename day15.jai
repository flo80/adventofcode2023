#load "aoc.jai";

example :: #string DONE
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
DONE

hash :: (input: string) -> int {
	h:u8= 0;

	while input {
		c := input[0];
		if c != #char "\n" && c != #char "," {
			h += c;
			h *= 17;
		}
		advance(*input);
	}
	return h;
}

parta :: (input: string) -> int {
	parts := String.split(input, ",");
	sum := 0;
	for p: parts sum += hash(p);
	return sum;
}

lens :: struct {
	name: string;
	val: u8;
}

partb :: (input: string) -> int {
	parts := String.split(String.trim(input), ",");

	boxes : [256][..]lens;
	find_lens :: (lenses: []lens, name: string) -> int, found: bool #must {
		for lenses if it.name == name return it_index, true;
		return 0, false;
	}

	for p: parts {
		char_index := 0;
		while is_alpha(p[char_index]) char_index+=1;

		name := String.slice(p, 0, char_index);
		boxnr := hash(name);
		box := *boxes[boxnr];

		existing_index, exists := find_lens(<<box, name);

		if p[char_index] == #char "-" {
			if exists array_ordered_remove_by_index(box, existing_index);
		} else {
			val := p[char_index+1] - #char "0";
			if exists { (<<box)[existing_index].val = val; }
			else array_add(box, .{name, val});
		}
	}
	print("%\n", boxes);

	sum := 0;
	for box, b:boxes for slot, s:box sum += (b+1) * (s+1) * cast(s64)(slot.val);
	return sum;
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 1320}], partb, .[.{example, 145}], day);

main :: () {
	execute(parta, partb, valid, day);
}
