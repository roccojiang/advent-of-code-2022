import std/os/path
import std/os/file
import std/text/parse

type move
  Rock
  Paper
  Scissors

fun show(m : move) : string
  match m
    Rock     -> "Rock"
    Paper    -> "Paper"
    Scissors -> "Scissors"

fun parse-opponent-move(c : char) : <exn,parse> move
  match c
    'A' -> Rock
    'B' -> Paper
    'C' -> Scissors
    _   -> throw("parse: unexpected opponent move")

fun parse-player-move(c : char) : <exn,parse> move
  match c
    'X' -> Rock
    'Y' -> Paper
    'Z' -> Scissors
    _   -> throw("parse: unexpected player move")

// parse-input().map fn(move-pair) { move-pair.show-tuple(show, show) }
fun parse-input() : io list<(move, move)>
  val parsed = read-text-file(cwd()/"day02/input.txt").slice.parse
    many
      val opponent-move = alpha().parse-opponent-move
      char(' ')
      val player-move = alpha().parse-player-move
      char('\n')
      (opponent-move, player-move)
  match parsed.either
    Left(msg)    -> msg.throw
    Right(moves) -> moves
