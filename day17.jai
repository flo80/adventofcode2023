#load "aoc.jai";

example :: #string DONE
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
DONE

parse_input :: (input: string) -> [..][..]u8 {
	result : [..][..]u8;
	line : [..]u8;
	while input {
		c := input[0];
		if c == #char "\n" {
			array_add(*result, line);
			array_reset(*line);
		} else {
			array_add(*line, c - #char "0");
		}
		advance(*input);
	}

	if line array_add(*result, line);

	return result;
}

Step :: struct {
	loss: u32;
	pos, dpos: Position;
	steps: u8;
}

// note: not comparing the loss, only to check if we have been there
operator == :: (a: Step, b: Step) -> bool {
	return a.pos == b.pos && a.dpos == b.dpos && a.steps == b.steps;
}

add :: (list: *[..]Step, new: Step) {
	i:=0;
	while i < list.count && new.loss < list.data[i].loss i+=1;
	array_insert_at(list, new, i);
}

dirs :: Position.[.{-1,0},.{1,0},.{0,-1},.{0,1}];

parta :: (input: string) -> int {
	map := parse_input(input);
	w := map[0].count-1;
	h := map.count-1;
	dest:Position = .{w, h};

	history : [200][200][..]Step;

	known :: (s: Step) -> bool #expand {
		h := history[s.pos.y][s.pos.x];
		for h if it == s return true;
		return false;
	}

	add_history :: (s: Step) #expand {
		h := *history[s.pos.y][s.pos.x];
		array_add(h, s);
	}

	queue : [..]Step;
	add(*queue, .{0, .{0,0}, .{0,0}, 0});

	while queue {
		cur := pop(*queue);
		if known(cur) continue;
		add_history(cur);

		if cur.pos == dest { return cur.loss; }

		for ndpos: dirs {
			npos: Position = ---;
			steps: u8 = 1;

			if ndpos.x == -cur.dpos.x && ndpos.y == -cur.dpos.y continue; // stepping back
			if ndpos == cur.dpos {
				if cur.steps >= 3 continue; // too many steps in a row
				else steps = cur.steps + 1;
			}

			npos = cur.pos + ndpos;
			if npos.x < 0 || npos.x > w continue;
			if npos.y < 0 || npos.y > h continue;

			nloss := cur.loss + map[npos.y][npos.x];
			add(*queue, .{nloss, npos, ndpos, steps});
		}
	}

	assert(false);
	return -1;
}

partb :: (input: string) -> int {
	map := parse_input(input);
	w := map[0].count-1;
	h := map.count-1;
	dest:Position = .{w, h};

	history : [200][200][..]Step;

	known :: (s: Step) -> bool #expand {
		h := history[s.pos.y][s.pos.x];
		for h if it == s return true;
		return false;
	}

	add_history :: (s: Step) #expand {
		h := *history[s.pos.y][s.pos.x];
		array_add(h, s);
	}

	queue : [..]Step;
	add(*queue, .{0, .{0,0}, .{0,0}, 0});

	while queue {
		cur := pop(*queue);
		if known(cur) continue;
		add_history(cur);

		if cur.pos == dest && cur.steps >= 4 { return cur.loss; }

		for ndpos: dirs {
			npos: Position = ---;
			steps: u8 = 1;

			if ndpos.x == -cur.dpos.x && ndpos.y == -cur.dpos.y continue; // stepping back
			if ndpos == cur.dpos {
				if cur.steps >= 10 continue; // too many steps in a row
				else steps = cur.steps + 1;
			} else {
				if cur.dpos != .{0,0} && cur.steps < 4 continue;
			}

			npos = cur.pos + ndpos;
			if npos.x < 0 || npos.x > w continue;
			if npos.y < 0 || npos.y > h continue;

			nloss := cur.loss + map[npos.y][npos.x];
			add(*queue, .{nloss, npos, ndpos, steps});
		}
	}

	assert(false);
	return -1;
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 102}], partb, .[.{example, 94}], day);

main :: () {
	execute(parta, partb, valid, day);
}
