module maybe

pub fun from-just(mx : maybe<a>) : exn a
  match mx
    Just(x) -> x
    Nothing -> throw("from-just: Nothing encountered")
