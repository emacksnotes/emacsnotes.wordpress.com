;;;; el-search-demo --- El Search Demo -*- lexical-binding: t; coding: utf-8-emacs; -*-

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

(require 'dash)
(require 's)

(eval-when-compile
  (defvar esd-bg-colors
    '("#fed9df" "#70f5ff" "#fed6f4" "#80ff26" "#cde5ff" "#f5e600" "#e9ddff" "#28ffcb" "#fedbc7")))

(defmacro esd-define-faces ()
  `(progn
     ,@(->>
        esd-bg-colors
        (-map-indexed
         (lambda (i x)
           (list (format "esd-bg-face-%02d" (1+ i))
                 `(:background ,x :inherit esd-bg-base-face))))
        (--map
         `(defface ,(intern (nth 0 it))
            '((t ,(nth 1 it)))
            ,(s-join " " (mapcar #'capitalize (s-split "-" (nth 0 it))))
            :group 'esd-hi-lock-faces)))))

(esd-define-faces)

(provide 'el-search-demo)
;;; el-search-demo.el ends here
