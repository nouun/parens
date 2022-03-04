(import-macros {: opts : bind : group : key} "macros")

(let [sign vim.fn.sign_define]
  (sign "LspDiagnosticsSignError"       {:text ""})
  (sign "LspDiagnosticsSignWarning"     {:text ""})
  (sign "LspDiagnosticsSignInformation" {:text ""})
  (sign "LspDiagnosticsSignHint"        {:text ""}))

(local capabilities
  (vim.lsp.protocol.make_client_capabilities))

(local handlers
  {:textDocument/publishDiagnostics
   (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
                 {:severity_sort    true
                  :update_in_insert false
                  :underline        true
                  :virtual_text     false})
   :textDocument/hover
   (vim.lsp.with vim.lsp.handlers.hover
                 {:border :single})
   :textDocument/signatureHelp
   (vim.lsp.with vim.lsp.handlers.signature_help
                 {:border :single})})


(fn on_attach [_ bufnr]
  (bind
    [{:prefix :<Leader>
      :buffer bufnr}
     (group
       :l :LSP

       (group
         :g :Goto
         (key :D "<cmd>lua vim.lsp.buf.declaration()<CR>" "Go to declaration")
         (key :d "<cmd>lua vim.lsp.buf.definition()<CR>"  "Go to definition")
         (key :i "<cmd>lua require('telescope.builtin').lsp_implementations()<CR>"                                      "View implementations")
         (key :r "<cmd>lua require('telescope.builtin').lsp_code_actions(require('telescope.themes').get_cursor())<CR>" "View references"))

       (group
         :d :Diagnostics
         (key :a "<cmd>require('telescope.builtin').lsp_workspace_diagnostics()<CR>" "View workspace diagnostics")
         (key :e "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>"           "View line diagnostics")
         (key :h "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>"                       "Go to previous diagostic")
         (key :l "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>"                       "Go to next diagostic"))

       (key :a "<cmd>lua require('telescope.builtin').lsp_code_actions(require('telescope.themes').get_cursor())<CR>" "View code actions")
       (key :f "<cmd>lua vim.lsp.buf.formatting()<CR>"  "Format buffer")
       (key :n "<cmd>lua vim.lsp.buf.rename()<CR>"      "Rename current context"))]
    [{:buffer bufnr}
     (key :K "<cmd>lua vim.lsp.buf.hover()<CR>" "Show LSP hover menu")]))

;; - Reqs (Nix)
;; nodePackages.markdownlint-cli
;; shellcheck
;; nodePackages.eslint_d
;; nixfmt
;; rPackages.statix
;; codespell

(let [nl (require :null-ls)
      coq (require :coq)
      b nl.builtins
      d b.diagnostics
      f b.formatting
      a b.code_actions]
  (nl.setup
    (coq.lsp_ensure_capabilities
     {:on_attach    on_attach
      :handlers     handlers
      :capabilities capabilities
      :sources
      [;; Shell
       d.shellcheck

       ;; JS/TS
       d.eslint_d
       f.eslint_d

       ;; Py
       f.black

       ;; Nix
       f.nixfmt
       ; d.statix
       ; a.statix

       ;; JSON
       f.fixjson

       ;; Fennel
       f.fnlfmt

       ;; Other shit
       d.codespell
       f.trim_whitespace
       a.gitsigns]})))

;; - Reqs (Nix)
;; nodePackages.typescript-language-server
;; nodePackages.bash-language-server
;; clojure-lsp
;; rnix-lsp

(let [lsp (require :lspconfig)
      coq (require :coq)
      map (-> (require :util)
              (. :map))
      lsps [:bashls :clojure_lsp :rnix :tsserver :rust_analyzer :rnix :pylsp]]
  (each [_ name (ipairs lsps)]
    ((. lsp name :setup)
     (coq.lsp_ensure_capabilities
       {:on_attach    on_attach
        :handlers     handlers
        :capabilities capabilities})))

  (let [pid (. vim :fn :getpid)]
    ((. lsp :omnisharp :setup)
     (coq.lsp_ensure_capabilities
       {:on_attach    on_attach
        :handlers     handlers
        :capabilities capabilities
        :cmd 
        [:omnisharp :--languageserver :--hostPID (tostring pid)]}))))

