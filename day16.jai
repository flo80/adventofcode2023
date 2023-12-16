#load "aoc.jai";

example :: #string DONE
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
DONE

Direction :: enum {
	u;d;r;l;
}

Task :: struct {
	x,y:int;
	d:Direction;
}

operator == :: inline (a: Task, b: Task) -> bool { return a.x == b.x && a.y == b.y && a.d == b.d;}

visit :: (lines: []string, tasks: [..]Task) -> int {
	width := lines[0].count-1;
	height := lines.count-1;
	while !lines[height] height-=1;

	visited : [120][120]bool;

	add :: (tasks :*[..] Task, t: Task)  {
		array := <<tasks;
		for array if it == t return;
		array_add(tasks, t);
	}

	follow :: (x:int, y:int, dir: Direction) #expand {
		while true {
			if #complete dir == {
				case Direction.u; y-=1;
				case Direction.d; y+=1;
				case Direction.r; x+=1;
				case Direction.l; x-=1;
			}
			if x < 0 || x > width return;
			if y < 0 || y > height return;

			visited[y][x] = true;
			if lines[y][x] == {
				case #char "."; continue;
				case #char "\\";
					if #complete dir == {
						case Direction.u; dir = .l;;
						case Direction.d; dir = .r;
						case Direction.r; dir = .d;
						case Direction.l; dir = .u;
					}
				case #char "/";
					if #complete dir == {
						case Direction.u; dir = .r;
						case Direction.d; dir = .l;
						case Direction.r; dir = .u;
						case Direction.l; dir = .d;
					}
				case #char "-";
					if #complete dir == {
						case Direction.u; #through;
						case Direction.d;
							add(*tasks, .{x,y,.l});
							add(*tasks, .{x,y,.r});
							return;
						case Direction.r; continue;
						case Direction.l; continue;
					}
				case #char "|";
					if #complete dir == {
						case Direction.u; continue;
						case Direction.d; continue;
						case Direction.r; #through;
						case Direction.l;
							add(*tasks, .{x,y,.u});
							add(*tasks, .{x,y,.d});
							return;
					}
			}
		}
	}

	i := 0;
	while i < tasks.count {
		t:=tasks[i];
		follow(t.x,t.y,t.d);
		i+=1;
	}

	sum:=0;
	for visited for it if it sum+=1;
	return sum;
}


parta :: (input: string) -> int {
	lines := to_lines(input);
	tasks : [..]Task;
	array_add(*tasks, .{-1,0,.r});
	return visit(lines, tasks);
}

partb :: (input: string) -> int {
	lines := to_lines(input);
	width := lines[0].count-1;
	height := lines.count-1;
	while !lines[height] height-=1;

	tasks : [..]Task;

	maximum := 0;

	check :: (x: int, y:int, d:Direction) -> int #expand {
		array_reset(*tasks);
		array_add(*tasks, .{x,y,d});
		r := visit(lines, tasks);
		maximum = max(r, maximum);
	}

	for x: 0..width check(x,-1,Direction.d);
	for x: 0..width check(x,height+1,Direction.u);

	for y: 0..height check(-1, y, Direction.r);
	for y: 0..height check(width+1,y,Direction.l);


	return maximum;
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 46}], partb, .[.{example, 51}], day);

main :: () {
	execute(parta, partb, valid, day);
}
