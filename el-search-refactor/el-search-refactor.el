;;;; el-search-refactor --- El Search Refactor -*- lexical-binding: t; coding: utf-8-emacs; -*-

;; Copyright (C) 2023 Emacks Notes

;; Author: Emacks Notes <emacksnotes@gmail.com>
;; Version: 
;; Homepage: https://github.com/emacksnotes/emacsnotes.wordpress.com/
;; Keywords: 
;; Package-Requires: ((emacs "24"))

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

;;; Code:

(require 'el-search)
(require 'el-search-x)

(eval-and-compile
  (defun esr--indent-string (s &optional n)
    (with-temp-buffer
      (insert s)
      (untabify (point-min) (point-max))
      (cl-loop for i from 1 to (or n 1)
               do (indent-rigidly-right (point-min) (point-max)))
      (untabify (point-min) (point-max))
      (buffer-substring-no-properties (point-min) (point-max)))))

(cl-defmacro esr--defun-with-sample-invocation (name arglist
                                                     (&key sample-invocation) &rest body)
  (declare  (indent defun))
  `(progn
     (defun ,name ,arglist
       ,(let* ((result (eval `(cl-labels ((,name ,arglist ,@body))
                                ,sample-invocation))))
          (help--docstring-quote
           (concat
            (format "\n%s" (pp-to-string sample-invocation))
            "\n" (let ((prefix "=>"))
                   (format "%s\n%s" prefix (esr--indent-string (pp-to-string result)
                                                               (1+ (length "=>"))))))))
       ,@body)))

(cl-defmacro esr-defpattern (name arglist
                                  (&key sample-invocation) &rest body)
  (declare  (indent defun))
  `(eval-and-compile
     (progn (el-search-defpattern ,name ,arglist
              ,@body)
            ,`(esr--defun-with-sample-invocation ,name (input-expression)
                (:sample-invocation ,sample-invocation)
                (let* ((f (el-search-make-matcher '(,name new) 'new)))
                  (funcall f input-expression))))))

(esr-defpattern define-key->key-and-command (new)
  (:sample-invocation (define-key->key-and-command '(define-key map [mouse-2] 'occur-mode-mouse-goto)))
  (cl-with-gensyms (keys command map)
    `(and `(define-key ,,map ,,keys ,,command)
          (let ,new
            `(,(key-description ,keys) ,@(eval ,command))))))

(esr-defpattern define-key->bind-key (new)
  (:sample-invocation (define-key->bind-key '(define-key esc-map "%" 'query-replace)))
  (cl-with-gensyms (keys command map)
    `(and `(define-key ,,map ,,keys ,,command)
          (let ,new
            `(bind-key ,(key-description ,keys) ,,command ,,map)))))

(esr-defpattern global-set-key->bind-key (new)
  (:sample-invocation (global-set-key->bind-key '(global-set-key (kbd "C-c C-c") 'some-command)))
  (cl-with-gensyms (key-name command)
    `(and `(global-set-key (kbd ,,key-name) ,,command)
          (let ,new
            `(bind-key ,,key-name ,,command)))))

(esr-defpattern global-unset-key->bind-key (new)
  (:sample-invocation (global-unset-key->bind-key
                       '(global-unset-key (kbd "C-c C-c"))))
  (cl-with-gensyms (key-name)
    `(and `(global-unset-key (kbd ,,key-name))
          (let ,new `(bind-key ,,key-name nil)))))

(esr-defpattern legacy-keymap-definition->bind-keys (new)
  (:sample-invocation (legacy-keymap-definition->bind-keys
                       '(defvar demo-map
                          (let ((map (make-sparse-keymap)))
                            (define-key map [mouse-2] 'occur-mode-mouse-goto)
                            (define-key map "\C-c\C-c" 'occur-cease-edit)
                            (define-key map "\C-o" 'occur-mode-display-occurrence)
                            (define-key map "\C-c\C-f" 'next-error-follow-minor-mode)
                            map)
                          "Keymap for `occur-edit-mode'.")))
  (cl-with-gensyms (bindings map)
    `(and `(defvar ,,map ,(append '(let) '(((map (make-sparse-keymap)))) ,bindings '(map)) ,doc)
          (let ,new
            `(bind-keys :map ,,map
                        ,@(let* ((f (el-search-make-matcher '(define-key->key-and-command new) 'new)))
                            (seq-map
                             (lambda (it)
                               (or (funcall f it)
                                   it))
                             ,bindings)))))))

(eval-and-compile
  (defcustom esr-replacement-rules
    '((-map-indexed
       `(-map-indexed ,(append '(lambda) `((,i ,elt)) body))
       `(seq-map-indexed (lambda (,elt ,i)
                           ,@body)))
      (--map
       `(--map ,tag)
       `(seq-map (lambda (it) ,tag)))
      (s-split-or-s-join
       `(,(and (or 's-split 's-join) f) ,x ,y)
       `(,(alist-get f `((s-join . string-join)
                         (s-split . string-split)))
         ,y ,x))
      define-key->key-and-command
      define-key->bind-key
      global-set-key->bind-key
      global-unset-key->bind-key
      legacy-keymap-definition->bind-keys
      mapc->dolist
      )
    "El Search Refactor Replacement Rules."
    :group 'el-search-refactor
    :type '(choice
            (repeat (choice
                     (list :tag "Pcase Rule"
                           (symbol  :tag "Tag        ")
                           (sexp    :tag "Pattern    ")
                           (sexp    :tag "Replacement"))
                     (symbol :tag "El Search Defpattern"))))))

(defmacro esr-rules->commands ()
  (let ((rules (seq-map
                (lambda (it)
                  (pcase it
                    ((pred symbolp)
                     (list it `(,it new) `new))
                    (`(,_tag ,_pattern ,_replacement)
                     it)))
                esr-replacement-rules)))
    (cons 'list (seq-map
                 (pcase-lambda (`(,tag ,pattern ,replacement))
                   (let* ((fname (intern (format "esr-rewrite:%s" tag)))
                          (f `(defun ,fname ()
                                (interactive)
                                (goto-char (point-min))
                                (el-search-query-replace
                                 ',pattern
                                 ',replacement))))
                     `(progn ,f ',fname)))
                 rules))))

(esr-rules->commands)

(provide 'el-search-refactor)
;;; el-search-refactor.el ends here
