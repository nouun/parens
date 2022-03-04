(import-macros {: opts} :macros)

(opts g
  :conjure
  {:client
   {:scheme
    {:stdio
     {:command        "gosh"
      :prompt_pattern "gosh>"}}}})
