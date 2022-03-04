{:map (fn [f tbl]
        (var t {})
        (each [key val (pairs tbl)]
          (tset t key (f val)))
        t)}
