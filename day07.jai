#load "aoc.jai";

example :: #string DONE
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
DONE


Hand :: struct {
	str: string;
	cards: [5]s8;
	bid: int;
	rank: int;
}

to_hand :: (input: string, to_card: (char: u8) -> s8, rank_hand: (hand: Hand) -> int) -> []Hand {
	lines := to_lines(input);
	hands : [..]Hand;
	for line: lines {
		if !line continue;
		hand := array_add(*hands);
		hand.str = String.slice(line, 0, 5);
		hand.bid = String.parse_int(*String.slice(line, 5, line.count));

		for i: 0..4 hand.cards[i] = to_card(line[i]);
		hand.rank = rank_hand(hand);
	}
	return hands;
}

sort :: (hands: []Hand) {
	sort_fct :: (a: Hand, b: Hand) -> s64 {
		diff: s64 = a.rank - b.rank;
		if diff != 0 return diff;
		for i: 0..4 if a.cards[i] != b.cards[i] return a.cards[i] - b.cards[i];
		return 0;
	}
	Sort.quick_sort(hands, sort_fct);
}

sum_bids :: (hands: []Hand) -> int {
	sum := 0;
	for h, i: hands sum += (i+1) * h.bid;
	return sum;
}

get_rank :: inline (cards: [15]int) -> int {
	cnt : [6]int;
	for i: 1..cards.count-1 cnt[cards[i]] += 1;

	if cnt[5] return 7; // five of a kind
	if cnt[4] return 6; // four of a kind
	if cnt[3] && cnt[2] return 5; // full house
	if cnt[3] return 4; // three of a kind
	if cnt[2] == 2 return 3; // two pair
	if cnt[2]  return 2; // one pair
	return 1;
}

parta :: (input: string) -> int {
	to_card :: inline (char: u8) -> s8 {
		if is_digit(char) return xx(char - #char "0");
		if char == {
			case #char "T"; return 10;
			case #char "J"; return 11;
			case #char "Q"; return 12;
			case #char "K"; return 13;
			case #char "A"; return 14;
			case; assert(false);
		}
		return 0;
	}

	rank_hand :: (hand: Hand) -> int {
		cards : [15]int;

		for h: hand.cards cards[h] += 1;
		return get_rank(cards);
	}


	hands := to_hand(input, to_card, rank_hand);
	sort(hands);
	return sum_bids(hands);
}

partb :: (input: string) -> int {
	to_card :: inline (char: u8) -> s8 {
		if is_digit(char) return xx(char - #char "0");
		if char == {
			case #char "T"; return 10;
			case #char "J"; return 0;
			case #char "Q"; return 12;
			case #char "K"; return 13;
			case #char "A"; return 14;
			case; assert(false);
		}
		return 0;
	}

	rank_hand :: (hand: Hand) -> int {
		cards : [15]int;
		for h: hand.cards cards[h] += 1;

		max_rank := 0;
		for i: 1..cards.count - 1 {
			t := cards;
			t[i] += cards[0]; // pretend joker is this card
			max_rank = max(max_rank, get_rank(t));
		}

		return max_rank;
	}


	hands := to_hand(input, to_card, rank_hand);
	sort(hands);
	return sum_bids(hands);
}

day :: #run get_day();
valid :: #run test(parta, .[.{example, 6440}], partb, .[.{example, 5905}], day);

main :: () {
	execute(parta, partb, valid, day);
}
