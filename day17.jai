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


Priority_Queue :: struct {
	List_Entry :: struct {
		value: Step;
		next : *List_Entry = null;
		prev : *List_Entry = null;
	}

	head:*List_Entry = null;
	tail:*List_Entry = null;
	count := 0;
}

add :: (list: *Priority_Queue, new: Step) {
	entry := cast(*Priority_Queue.List_Entry)alloc(size_of(Priority_Queue.List_Entry));
	entry.value = new;

	if list.head == null {
		list.head = entry;
		list.tail = entry;
	} else if(new.loss < list.tail.value.loss) {
		list.tail.next = entry;
		entry.prev = list.tail;
		list.tail = entry;
	} else {
		c := list.head;
		while c.next != null && new.loss < c.value.loss c = c.next;

		entry.prev = c.prev;
		entry.next = c;

		if entry.prev == null list.head = entry;
		else entry.prev.next = entry;

		if entry.next == null list.tail = entry;
		else entry.next.prev = entry;
	}
	list.count += 1;
}

pop :: (list: *Priority_Queue) -> Step {
	assert(list.tail != null);
	entry:= list.tail;
	val := entry.value;
	list.tail = entry.prev;

	list.count -= 1;
	if list.count == 0 {
		list.head = null;
		list.tail = null;
	} else {
		list.tail.next = null;
	}
	return val;
}

dirs :: Position.[.{-1,0},.{1,0},.{0,-1},.{0,1}];
pos_to_dir :: inline (pos: Position) -> u8 {
	if pos == .{-1,0} return 0;
	if pos == .{1,0} return 1;
	if pos == .{0,-1} return 2;
	if pos == .{0,1} return 3;

	assert(false, "Unknown pos %", pos);
	return 4;
}

parta :: (input: string) -> int {
	map := parse_input(input);
	w := map[0].count-1;
	h := map.count-1;
	dest:Position = .{w, h};

	history : [200][200][4][4]bool;

	known :: (s: Step) -> bool #expand {
		if s.pos == .{0,0} return false;
		d := pos_to_dir(s.dpos);
		return history[s.pos.y][s.pos.x][s.steps][d];
	}

	add_history :: (s: Step) #expand {
		if s.pos == .{0,0} return;
		d := pos_to_dir(s.dpos);
		history[s.pos.y][s.pos.x][s.steps][d] = true;
	}

	queue : Priority_Queue;
	add(*queue, .{0, .{0,0}, .{0,0}, 0});

	while queue.count {
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

	history : [200][200][11][4]bool;

	known :: (s: Step) -> bool #expand {
		if s.pos == .{0,0} return false;
		d := pos_to_dir(s.dpos);
		return history[s.pos.y][s.pos.x][s.steps][d];
	}

	add_history :: (s: Step) #expand {
		if s.pos == .{0,0} return;
		d := pos_to_dir(s.dpos);
		history[s.pos.y][s.pos.x][s.steps][d] = true;
	}

	queue : Priority_Queue;
	add(*queue, .{0, .{0,0}, .{0,0}, 0});

	while queue.count {
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
