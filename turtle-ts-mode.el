;;; turtle-ts-mode.el --- RDF Turtle ts mode -*- lexical-binding: t; -*-

;; Copyright (C) 2024-…  Bruno Cuconato

;; Author: Bruno Cuconato <bcclaro+emacs@gmail.com>
;; Keywords: RDF Turtle ttl semanticweb

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'treesit)

(defvar turtle-indent-offset 2
  "Indentation offset for `turtle-ts-mode'.")

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
      )
    "Font lock rules for RDF Turtle.")

(defvar turtle-ts-indent-rules
  `((turtle
     ((node-is "statement") column-0 0)
     ((match "]" "blank_node_property_list") no-indent 0)
     ((node-is ,(regexp-opt (list "object_list" "property_list"))) parent ,turtle-indent-offset)
     ((parent-is ,(regexp-opt (list "property_list" "object_list")))
      prev-sibling 0)
     ((node-is "object_collection") standalone-parent ,turtle-indent-offset)
     ((parent-is ,(regexp-opt (list "collection"))) prev-sibling 0)

     (catch-all no-indent ,turtle-indent-offset)
     ))
  "Indent rules for RDF Turtle.")

(defun turtle-ts-setup ()
  "Setup treesit for `turtle-ts-mode'."

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

;;;###autoload
(define-derived-mode turtle-ts-mode prog-mode "Turtle[ts]"
  "Major mode for RDF Turtle documents, using tree-sitter."
  (when (treesit-ready-p 'turtle)
    (treesit-parser-create 'turtle)
    (turtle-ts-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ttl\\'" . turtle-ts-mode))

(provide 'turtle-ts-mode)
;;; turtle-ts-mode.el ends here
