import std/os/path
import std/os/file
import std/text/parse

fun parse-input() : _e list<list<int>>
  val parsed = read-text-file(cwd()/"day01/input.txt").slice.parse
    many
      val elf = many
        val item = pint()
        pstring("\n")
        item
      pstring("\n")
      elf
  match parsed.maybe
    Nothing -> [[]]
    Just(elfs) -> elfs

fun part1() : _e int
  parse-input().map fn(elf) { elf.sum }.maximum
