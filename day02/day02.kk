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

fun (==)(a : move, b : move) : bool
  match (a, b)
    (Rock, Rock)         -> True
    (Paper, Paper)       -> True
    (Scissors, Scissors) -> True
    _                    -> False

type outcome
  Win
  Lose
  Draw

fun show(o : outcome) : string
  match o
    Win  -> "Win"
    Lose -> "Lose"
    Draw -> "Draw"


fun parse-opponent-move(c : char) : exn move
  match c
    'A' -> Rock
    'B' -> Paper
    'C' -> Scissors
    _   -> throw("parse: unexpected opponent move")

fun parse-player-move(c : char) : exn move
  match c
    'X' -> Rock
    'Y' -> Paper
    'Z' -> Scissors
    _   -> throw("parse: unexpected player move")

fun parse-round-outcome(c : char) : exn outcome
  match c
    'X' -> Lose
    'Y' -> Draw
    'Z' -> Win
    _   -> throw("parse: unexpected round outcome")


effect<a> fun interpret-column(p : char) : a

fun parse-input() : <io,interpret-column<a>> list<(move, a)>
  val parsed = read-text-file(cwd()/"day02/input.txt").slice.parse
    many
      val column-one = alpha().parse-opponent-move
      char(' ')
      val column-two = alpha().interpret-column
      char('\n')
      (column-one, column-two)
  match parsed.either
    Left(msg)    -> msg.throw
    Right(moves) -> moves

fun winning-move(opponent : move) : move
  match opponent
    Rock     -> Paper
    Paper    -> Scissors
    Scissors -> Rock

fun play-round(opponent : move, player : move) : outcome
  if player == winning-move(opponent) then Win
  else if opponent == winning-move(player) then Lose
  else Draw

fun play-for-outcome(opponent : move, outcome : outcome) : move
  val win-move = winning-move(opponent)
  match outcome
    Draw -> opponent
    Win  -> win-move
    Lose -> win-move.winning-move

fun score-shape(m : move) : int
  match m
    Rock     -> 1
    Paper    -> 2
    Scissors -> 3

fun score-outcome(o : outcome) : int
  match o
    Lose -> 0
    Draw -> 3
    Win  -> 6


fun part1() : io int
  with fun interpret-column(c) c.parse-player-move
  parse-input().map fn((op, pl)) { pl.score-shape + play-round(op, pl).score-outcome }.sum

fun part2() : io int
  with fun interpret-column(c) c.parse-round-outcome
  parse-input().map fn((op, out)) { out.score-outcome + play-for-outcome(op, out).score-shape }.sum
