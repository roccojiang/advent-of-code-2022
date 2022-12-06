// Modelling the Ord typeclass using an effect
module ord

pub effect ord<a>
  fun cmp(x : a, y : a) : order

pub fun (==!)(x : a, y : a) : ord<a> bool
  cmp(x, y).is-eq

pub fun (!=!)(x : a, y : a) : ord<a> bool
  !cmp(x, y).is-eq

pub fun (<!)(x : a, y : a) : ord<a> bool
  cmp(x, y).is-lt

pub fun (<=!)(x : a, y : a) : ord<a> bool
  cmp(x, y).is-lt && cmp(x, y).is-eq

pub fun (>!)(x : a, y : a) : ord<a> bool
  cmp(x, y).is-gt

pub fun(>=!)(x : a, y : a) : ord<a> bool
  cmp(x, y).is-gt && cmp(x, y).is-eq


pub fun show(ord : order) : string
  match ord
    Eq -> "Eq"
    Lt -> "Lt"
    Gt -> "Gt"


pub fun ord-int(action : () -> <ord<int>|e> a) : e a
  with fun cmp(x : int, y : int) compare(x, y)
  action()

pub fun ord-char(action : () -> <ord<char>|e> a) : e a
  with fun cmp(x : char, y : char) compare(x, y)
  action()

pub fun ord-bool(action : () -> <ord<bool>|e> a) : e a
  with fun cmp(x : bool, y : bool) compare(x, y)
  action()

pub fun ord-string(action : () -> <ord<string>|e> a) : e a
  with fun cmp(x : string, y : string) compare(x, y)
  action()

pub fun ord-pair(action : () -> <ord<(a, a)>,ord<a>|e> b) : <ord<a>|e> b
  with fun cmp(x, y)
    val ((xl, xr), (yl, yr)) = (x, y)
    match cmp(xl, yl)
      Eq  -> cmp(xr, yr)
      ord -> ord
  
  action()

pub fun ord-list(action : () -> <ord<list<a>>,ord<a>|e> b) : <ord<a>|e> b
  fun cmp-list(xs' : list<a>, ys' : list<a>) : <ord<a>> order
    match (xs', ys')
      (Nil, Nil) -> Eq
      (Nil, _)   -> Lt
      (_, Nil)   -> Gt
      (Cons(x, xs), Cons(y, ys)) -> match cmp(x, y)
        // Suppress div effect, we know the list sizes will be decreasing
        Eq  -> cmp-list(xs.unsafe-decreasing, ys.unsafe-decreasing)
        ord -> ord

  with fun cmp(xs, ys) cmp-list(xs, ys)
  action()
