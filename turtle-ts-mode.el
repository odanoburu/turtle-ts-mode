;; https://www.masteringemacs.org/article/lets-write-a-treesitter-major-mode

(defvar turtle-ts-font-lock-rules
    '(:language turtle
      :override t
      :feature delimiter
      (["<" ">" "/>" "</"] @font-lock-bracket-face)

      :language turtle
      :override t
      :feature comment
      ((comment) @font-lock-comment-face)
      )

;;;###autoload
(define-derived-mode turtle-ts-mode prog-mode "N3/Turtle mode"
  "Major mode for Turtle RDF documents, using tree-sitter."

  ;; Comments syntax
  (set (make-local-variable 'comment-start) " # ")
  (modify-syntax-entry ?\n "> " turtle-mode-syntax-table)
  (modify-syntax-entry ?\' "\"" turtle-mode-syntax-table)
  ;; fontification
  (setq-local font-lock-defaults nil)
  (when (treesit-ready-p 'turtle)
    (treesit-parser-create 'turtle)
    (turtle-ts-setup))

  ;; indentation
  (set (make-local-variable 'indent-line-function) 'turtle-indent-line)
  (set (make-local-variable 'indent-tabs-mode) nil)
  (set (make-local-variable 'syntax-propertize-function) 'turtle-propertize-comments)
  (setq show-trailing-whitespace t)
  (if (and turtle-indent-on-idle-timer (not turtle-indent-idle-timer))
      (setq turtle-indent-idle-timer (run-with-idle-timer turtle-indent-idle-timer-period t 'turtle-idle-indent))
    (when turtle-indent-idle-timer
      (setq turtle-indent-idle-timer (cancel-timer turtle-indent-idle-timer)))))


(defun turtle-ts-setup ()
  "Setup treesit for turtle-ts-mode."

  ;; font locking
  (setq-local treesit-font-lock-settings
               (apply #'treesit-font-lock-rules
                      turtle-ts-font-lock-rules))

  ;; UPDATE
  (setq-local treesit-font-lock-feature-list
              '((comment)
                (constant tag attribute)
                (declaration)
                (delimiter)))

  ;; indentation
  (setq-local treesit-simple-indent-rules turtle-ts-indent-rules)


  (treesit-major-mode-setup))
