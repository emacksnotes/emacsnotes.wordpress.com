;;;; elisp-examples --- Elisp Examples -*- lexical-binding: t; coding: utf-8-emacs; -*-

;; Copyright (C) 2023 Emacks Notes

;; Author: Emacks Notes <emacksnotes@gmail.com>
;; Version: 
;; Homepage: https://github.com/emacksnotes/elisp-examples
;; Keywords: 
;; Package-Requires: 

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

(eval-when-compile
  (require 'subr-x))

(defgroup elisp-examples nil
  "Options for Elisp Examples."
  :tag "Elisp Examples"
  :group 'help)

(defcustom elisp-examples
  (eval-when-compile
    `(,@'((cons
           (cons 1 '(2))
           (cons 1 '())
           (cons 1 2))
          (car (car '(a b c)))
          (cdr (cdr '(a b c)))
          (list
           (list 1 2 3 4 5)
           (list 1 2 '(3 4 5) 'foo)
           (list))
          (nth (nth 2 '(1 2 3 4)))
          (append
           (progn
             (setq trees '(pine oak))
             (setq more-trees (append '(maple birch) trees))))
          (flatten-tree
           (flatten-tree '(1 (2 . 3) nil (4 5 (6)) 7)))
          (number-sequence
           (number-sequence 4 9)
           (number-sequence 9 4 -1)
           (number-sequence 9 4 -2)))
      ,@(when-let* (((locate-library "dash"))
                    ((file-exists-p (concat
                                     (file-name-directory (locate-library "dash"))
                                     "dev/examples.el"))))
          (load
           (concat
            (file-name-directory (locate-library "dash"))
            "dev/examples.el"))
          (defvar dash--groups)
          (thread-last dash--groups
                       (seq-keep
                        (lambda (it)
                          (pcase it
                            (`(,(and (pred stringp)) . ,_doc)
                             (ignore))
                            ((and `(,fn . ,examples))
                             (cons fn (mapcar #'car (-take 3 examples)))))))))))
  "Alist of Function and Examples."
  :type `(repeat
          (cons (symbol :tag "Function")
                (repeat (sexp :tag "Example")))))

(defun elisp-examples--indent-string (s &optional n)
  (with-temp-buffer
    (insert s)
    (cl-loop for i from 1 to (or n 1)
             do (indent-rigidly-right (point-min) (point-max)))
    (untabify (point-min) (point-max))
    (buffer-string)))

(add-hook 'help-fns-describe-function-functions
          #'elisp-examples--inject-example)

(defun elisp-examples--inject-example (fn)
  (let* ((fns (pcase (symbol-name fn)
                ((rx (and bos "-"))
                 (list fn (intern (substring (symbol-name fn) 1))))
                (_ (list fn (intern (format "-%s" fn))))))
         (i 0))
    (dolist (fn fns)
      (pcase-dolist (sample-invocation (alist-get fn elisp-examples))
        (when sample-invocation
          (cl-incf i)
          (insert
           (elisp-examples--indent-string
            (concat
             (propertize (format "Example %s" i) 'font-lock-face 'underline)
             "\n\n" (elisp-examples--indent-string
                     (concat (format "%s" (pp-to-string sample-invocation))
                             "\n"
                             (let ((prefix "=>"))
                               (format "%s\n%s" prefix
                                       (elisp-examples--indent-string
                                        (pp-to-string (eval sample-invocation))
                                        (1+ (length prefix))))))
                     2))
            2)
           "\n"))))))

(provide 'elisp-examples)
;;; elisp-examples.el ends here
