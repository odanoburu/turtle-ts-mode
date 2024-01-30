;; https://www.masteringemacs.org/article/lets-write-a-treesitter-major-mode
; https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/turtle/highlights.scm

(defvar turtle-indent-offset 2)

(defvar turtle-ts-font-lock-rules
    '(:language turtle
      :override t
      :feature comment
      ((comment) @font-lock-comment-face)

      :language turtle
      :override t
      :feature string
      ((string) @font-lock-string-face)

      :language turtle
      :override t
      :feature boolean
      ((boolean_literal _) @font-lock-constant-face)

      :language turtle
      :override t
      :feature number
      ([(integer) (decimal) (double)] @font-lock-number-face)

      :language turtle
      :override t
      :feature keyword
      ([(base _ @font-lock-keyword-face _ _)
        (prefix_id _ @font-lock-keyword-face _ _ _)
        (sparql_base _ @font-lock-keyword-face _)
        (sparql_prefix _ @font-lock-keyword-face _ _)])

      :language turtle
      :override t
      :feature built-ins
      ((predicate "a") @font-lock-builtin-face)

      :language turtle
      :override append
      :feature identifier
      ([(iri_reference) (prefixed_name) (blank_node_label)] @font-lock-variable-use-face)

      :language turtle
      :override t
      :feature identifier-prefix
      ((namespace :anchor (pn_prefix)) @font-lock-preprocessor-face)

      :language turtle
      :override t
      :feature literal-type
      ((rdf_literal value: _ [(lang_tag) datatype: _] @font-lock-type-face))

      :language turtle
      :override t
      :feature escape-char
      ((echar) @font-lock-escape-face)

      :language turtle
      :override t
      :feature punctuation
      ([(property_list ";" @font-lock-delimiter-face :anchor (property))
        (object_list "," @font-lock-delimiter-face)
        (statement "." @font-lock-delimiter-face :anchor)
        ])

      :language turtle
      :override t
      :feature punctuation-brackets
      ([(blank_node_property_list :anchor "[" @font-lock-bracket-face "]" @font-lock-bracket-face :anchor)
       (collection :anchor "(" @font-lock-bracket-face ")" @font-lock-bracket-face :anchor)])
      ))

(defvar turtle-ts-indent-rules
  `((turtle
     ((node-is "property_list") parent ,turtle-indent-offset)
     ((parent-is ,(regexp-opt '("property_list" "object_list")))
      first-sibling 0)
     ((node-is "object_collection") standalone-parent ,turtle-indent-offset)
     ((parent-is ,(regexp-opt '("collection")))
      first-sibling 0)
     (catch-all no-indent ,turtle-indent-offset)
     )))



;;;###autoload
(define-derived-mode turtle-ts-mode prog-mode "N3/Turtle mode"
  "Major mode for Turtle RDF documents, using tree-sitter."
  (when (treesit-ready-p 'turtle)
    (treesit-parser-create 'turtle)
    (turtle-ts-setup)))


(defun turtle-ts-setup ()
  "Setup treesit for turtle-ts-mode."

  ;; font locking
  (setq-local font-lock-defaults nil)
  (setq-local treesit-font-lock-settings
               (apply #'treesit-font-lock-rules
                      turtle-ts-font-lock-rules))
  (setq-local treesit-font-lock-level 5)
  ;; UPDATE
  (setq-local treesit-font-lock-feature-list
              '((comment)
                (string boolean number keyword identifier identifier-prefix
                        built-ins)
                (literal-type escape-char punctuation punctuation-brackets)
                ))

  ;; indentation
  (setq-local treesit-simple-indent-rules turtle-ts-indent-rules)

  (setq-local comment-start "# ")


  (treesit-major-mode-setup))
