import std/os/file
import std/os/path

import utils/list
import utils/ord

fun get-input() : io string
  read-text-file(cwd()/"day06/input.txt").trim

fun test(cs : list<char>)
  with ord-char
  cs.nub

fun unique-chars(s : string) : div bool
  with ord-string
  with ord-list
  with ord-char
  val cs = s.list
  // cs ==! cs.nub
  cs ==! cs.nub-by fn(a, b) { a == b }

fun look-for-marker(buffer : string, n : int) : <exn,div> int
  fun go(remaining : list<char>, pos : int) : <exn,div> int
    val candidate = remaining.take(n)
    if candidate.length < n               then throw("marker never found")
    else if candidate.string.unique-chars then pos
    else                                  go(remaining.drop(1), pos + 1)
  
  go(buffer.list, n)

fun part1() : io int
  get-input().look-for-marker(4)

fun part2() : io int
  get-input().look-for-marker(14)
