import std/os/path
import std/os/file
import std/text/parse

fun from-just(mx : maybe<a>) : exn a
  match mx
    Just(x) -> x
    Nothing -> throw("from-just: Nothing encountered")

fun take(s : string, n : int) : string
  s.first(n).string

fun drop(s : string, n : int) : string
  val len = s.slice.count
  s.last(len - n).string

fun substrings-n(s : string, n : int) : div list<string>
  match s
    "" -> Nil
    _  -> Cons( s.take(n), substrings-n(s.drop(n), n) )

// https://hackage.haskell.org/package/base-4.17.0.0/docs/src/Data.OldList.html#transpose
fun transpose(xss' : list<list<a>>) : <div,exn> list<list<a>>
  match xss'
    Nil -> Nil
    Cons(Nil, xss) -> xss.transpose
    Cons( Cons(x, xs), xss ) -> 
      fun combine(y : a, h : list<a>, ys : list<a>, t : list<list<a>>) : <div,exn> list<list<a>>
        Cons( Cons(y, h), Cons(ys, t).transpose )

      val (hds, tls) = xss.map fn(xs') { (xs'.head.from-just, xs'.tail) }.unzip
      combine(x, hds, xs, tls)

fun transpose(ss : list<string>) : <div,exn> list<string>
  ss.map(list).transpose.map(string)

fun get-input() : io (list<string>, list<string>)
  val (raw-stacks, raw-instrs) = read-text-file(cwd()/"day05/input.txt").lines.span fn(s) { s != "" }
  val stacks = raw-stacks.map fn(s) { s.substrings-n(4) }.transpose.map fn(s) { s.reverse.join }
  val instrs = raw-instrs.filter fn(s) { !s.list.all(is-white) }

  (stacks, instrs)

alias stack = (int, list<char>)
fun show(s : stack) : string
  val (i, crates) = s
  "stack " ++ i.show ++ ": " ++ crates.string

alias move = (int, int, int)
fun show(m : move) : string
  val (cnt, from, to) = m
  "move " ++ cnt.show ++ " from " ++ from.show ++ " to " ++ to.show

fun parse-crate() : parse char
  char('[')
  val crate = alpha()
  char(']')
  crate

fun parse-stack() : parse stack
  whitespace()
  val i = pint()
  whitespace()
  val crates = many
    val crate = parse-crate()
    whitespace0()
    crate

  (i, crates.reverse)

fun parse-move() : parse move
  pstring("move")
  whitespace()
  val cnt = pint()
  whitespace()
  pstring("from")
  whitespace()
  val from = pint()
  whitespace()
  pstring("to")
  whitespace()
  val to = pint()

  (cnt, from, to)


fun get-parsed-input()
  val (raw-stacks, raw-instrs) = get-input()

  val stacks = raw-stacks.map fn(s) { s.slice.parse(parse-stack).get-parsed }
  val instrs = raw-instrs.map fn(i) { i.slice.parse(parse-move).get-parsed }

  (stacks, instrs)

fun get-parsed(parsed : parse-error<a>) : exn a
  match parsed.either
    Left(err)      -> err.throw
    Right(success) -> success
