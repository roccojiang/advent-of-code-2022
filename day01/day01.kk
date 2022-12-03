import std/os/path
import std/os/file
import std/text/parse

fun parse-input() : io list<list<int>>
  val parsed = read-text-file(cwd()/"day01/input.txt").slice.parse
    many
      val elf = many
        val item = pint()
        pstring("\n")
        item
      pstring("\n")
      elf
  match parsed.either
    Left(msg) -> msg.throw
    Right(elfs) -> elfs


fun insert(e: int, sorted: list<int>) : list<int>
  match sorted
    Nil -> Cons(e, Nil)
    Cons(x, xs) -> if e < x then Cons(e, Cons(x, xs)) else Cons(x, e.insert(xs))

fun insertion-sort(es: list<int>) : list<int>
  match es
    Nil -> es
    Cons(x, xs) ->
      val sorted = xs.insertion-sort
      insert(x, sorted)

fun elf-item-sums() : io list<int>
  parse-input().map fn(elf) { elf.sum }


fun part1() : io int
  elf-item-sums().maximum

fun part2() : io int
  elf-item-sums().insertion-sort.reverse.take(3).sum
