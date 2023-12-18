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
operator < :: (a: Step, b: Step) -> bool {
	return a.loss < b.loss;
}

step_smaller :: (a: Step, b: Step) -> bool {
	return a < b;
}

// heapq from https://github.com/python/cpython/blob/3.12/Lib/heapq.py

heappush :: (heap: *[..]$T, item: T) {
	array_add(heap, item);
	_siftdown(heap, 0, heap.count - 1);
}

heappop :: (heap: *[..]$T) -> T {
	last:T = pop(heap);

	if heap.count {
		returnitem:T = (<<heap)[0];
		(<<heap)[0] = last;
		_siftup(heap, 0);
		return returnitem;
	}

	return last;
}

_siftdown :: (heap: *[..]$T, startpos: int, pos: int) {
	newitem:T = (<<heap)[pos];

	while pos > startpos {
		parentpos := (pos - 1) >> 1;
		parent:T = (<<heap)[parentpos];
		if newitem < parent {
			(<<heap)[pos] = parent;
			pos = parentpos;
			continue;
		}
		break;
	}
	(<<heap)[pos] = newitem;
}

_siftup :: (heap: *[..]$T, pos: int) {
	endpos := heap.count;
	startpos := pos;
	newitem := (<<heap)[pos];

	childpos := 2 * pos + 1;
	while childpos < endpos {
		rightpos := childpos + 1;
		if rightpos < endpos && !((<<heap)[childpos] < (<<heap)[rightpos]) childpos = rightpos;
		(<<heap)[pos] = (<<heap)[childpos];
		pos = childpos;
		childpos = 2 * pos + 1;
	}
	(<<heap)[pos] = newitem;
	_siftdown(heap, startpos, pos);
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

	queue : [..]Step;
	heappush(*queue, .{0, .{0,0}, .{0,0}, 0});

	while queue {
		cur := heappop(*queue);
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
			heappush(*queue, .{nloss, npos, ndpos, steps});
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

	queue : [..]Step;
	heappush(*queue, .{0, .{0,0}, .{0,0}, 0});

	while queue.count {
		cur := heappop(*queue);
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
			heappush(*queue, .{nloss, npos, ndpos, steps});
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
