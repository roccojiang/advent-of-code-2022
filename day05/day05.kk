import std/os/path
import std/os/file
import std/text/parse

fun get-input() : io (list<string>, list<string>)
  read-text-file(cwd()/"day05/input.txt").lines.span fn(s) { s != "" }

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

fun process-input()
  val (raw-stacks, instrs) = get-input()
  val stacks = raw-stacks.map fn(s) { s.substrings-n(4) }.transpose.map fn(s) { s.reverse.join }

  (stacks, instrs)

alias stack = (int, list<char>)

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

// process-input().fst.map fn(i) { i.get-parsed(parse-stack).show-tuple(show, fn(cs) { cs.string } ) }
fun get-parsed(input : string, parser : () -> <io,parse|e> a) : <io|e> a
  val parsed = input.slice.parse(parser)
  match parsed.either
    Left(err)      -> err.throw
    Right(success) -> success
