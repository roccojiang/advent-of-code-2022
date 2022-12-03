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

type outcome
  Win
  Lose
  Draw

fun show(o : outcome) : string
  match o
    Win  -> "Win"
    Lose -> "Lose"
    Draw -> "Draw"


// effect state<a>
//   fun get() : a
//   fun put(x : a) : ()

// fun gets(f)
//   get().f.put


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


fun play-round(opponent : move, player : move) : outcome
  fun wins(pl : move, op : move) : bool
    match (pl, op)
      (Rock, Scissors)  -> True
      (Scissors, Paper) -> True
      (Paper, Rock)     -> True
      _                 -> False
  
  if wins(player, opponent) then Win
  else if wins(opponent, player) then Lose
  else Draw

fun score-shape(m : move) : int
  match m
    Rock     -> 1
    Paper    -> 2
    Scissors -> 3

fun score-outcome(o : outcome) : int
  match o
    Lose -> 0
    Draw -> 3
    Win   -> 6


fun part1() : io int
  parse-input().map fn((op, pl)) { pl.score-shape + play-round(op, pl).score-outcome }.sum
