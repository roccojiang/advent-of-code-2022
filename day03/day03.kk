import std/os/path
import std/os/file
import std/text/parse

fun parse-input() : io list<list<char>>
  val parsed = read-text-file(cwd()/"day03/input.txt").slice.parse
    many
      val rucksack = many
        alpha()
      pstring("\n")
      rucksack
  match parsed.either
    Left(msg)        -> msg.throw
    Right(rucksacks) -> rucksacks


fun compartments(rucksack : list<char>) : (list<char>, list<char>)
  val i = rucksack.length / 2
  rucksack.split(i)

fun priority(c : char) : exn int
  if c.is-lower      then c.int - 'a'.int + 1
  else if c.is-upper then c.int - ('A'.int - 1) + ('Z'.int - 'A'.int + 1)
  else                    throw("priority: non-alphabetical character")

fun common-items(rucksack : list<char>) : list<char>
  // how to have polymorphic (==) so that elem can also be polymorphic?
  fun elem(x : char, xs : list<char>) : bool
    match xs.find fn(i) { i == x }
      Just(_) -> True
      Nothing -> False

  val (c1, c2) = rucksack.compartments
  c1.filter fn(i) { i.elem(c2) }

fun common-item(rucksack : list<char>) : exn char
  // Pre: only one item is in common
  match rucksack.common-items.head
    Just(item) -> item
    Nothing    -> throw("common-item: no common item found in " ++ rucksack.string)


fun part1()
  parse-input().map fn(rucksack) { rucksack.common-item.priority }.sum
