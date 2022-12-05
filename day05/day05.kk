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

alias crate = char
alias stack = (int, list<crate>)
fun show(s : stack) : string
  val (i, crates) = s
  "stack " ++ i.show ++ ": " ++ crates.string

alias move = (int, int, int)
fun show(m : move) : string
  val (cnt, from, to) = m
  "move " ++ cnt.show ++ " from " ++ from.show ++ " to " ++ to.show

fun parse-crate() : parse crate
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

effect state<a>
  fun get(i : int) : a
  fun put(x : a, i : int) : ()

fun run-state(init : list<a>, action : () -> <state<a>,exn,div|e> b) : <exn,div|e> (b, list<a>)
  var st := init.vector
  with handler
    return(x)     (x, st.list)
    fun get(i)    st[i]
    fun put(x, i) st[i] := x 
  action()

fun push(n : int, c : crate) : state<stack> ()
  val (i, stack) = get(n)
  (i, Cons(c, stack)).put(n)

fun pop(n : int) : <state<stack>,exn> crate
  val (i, stack : list<crate>) = get(n)
  (i, stack.tail).put(n)
  stack.head.from-just

fun exec-move(move : move) : <state<stack>,exn> ()
  val (cnt, from, to) = move
  repeat(cnt)
    val crate = pop(from - 1)
    push(to - 1, crate)

fun exec-moves(moves : list<move>) : <state<stack>,exn> ()
  moves.foreach(exec-move)

fun first-crate(stack : stack) : exn crate
  stack.snd.head.from-just

fun part1()
  val (stacks, instrs) = get-parsed-input()
  val (_, state) = run-state(stacks){instrs.exec-moves}
  state.map(first-crate).string

fun test-st()
  // push(0, 'd')
  pop(0)

fun test()
  val (_, state) = run-state([(0, ['a','b','c'])]){test-st()}
  state
