(require 'tutorial)

(require 'rx)
(require 'cl-lib)
(require 'outline)
(require 'hi-lock)
(require 'goto-addr)
(require 'cus-edit)
(require 'which-func)

(defgroup my-tutorial nil
  "Fontify TUTORIAL."
  :group 'font-lock)

(defgroup my-tutorial-faces nil
  "Faces used for fontifying TUTORIAL."
  :group 'my-tutorial
  :group 'faces)

(defface my-tutorial-command
  '((t :inherit custom-button))
  "Face for highlighting keys in TUTORIAL.
See `my-tutorial-commands'."
  :group 'my-tutorial-faces)

(defface my-tutorial-modifier-keys
  ;; nil
  ;; '((t :inherit my-tutorial-command))
  '((t :foreground "blue"))
  "Face for highlighting keys in TUTORIAL.
See `my-tutorial-modifier-keys'."
  :group 'my-tutorial-faces)

(defface my-tutorial-important-instructions
  '((t (:foreground "red")))
  "Face for highlighting important instructions in TUTORIAL.
See `my-tutorial--important-note'."
  :group 'my-tutorial-faces)

(defface my-tutorial-instructions
  '((t (:background "yellow")))
  "Face for highlighting instructions in TUTORIAL.
See `my-tutorial--instructions'."
  :group 'my-tutorial-faces)

(defface my-tutorial-table-face
  '((t (:background "light grey")))
  "Face for highlighting summary tables in TUTORIAL.
See `my-tutorial--indented-paras'."
  :group 'my-tutorial-faces)

(defvar my-tutorial--line		`(and (or buffer-start "\n") (one-or-more any)))
(defvar my-tutorial--lines		`(one-or-more ,my-tutorial--line))
(defvar my-tutorial--para		`(and (or buffer-start (one-or-more "\n")) ,my-tutorial--lines))

(defvar my-tutorial--important-note	`(and buffer-start (repeat 2 5 ,my-tutorial--para)))

(defvar my-tutorial--indented-line	`(and "\n" (one-or-more blank) (one-or-more any)))
(defvar my-tutorial--indented-lines	`(one-or-more ,my-tutorial--indented-line))
(defvar my-tutorial--indented-para	`(and "\n" ,my-tutorial--indented-lines))
(defvar my-tutorial--indented-paras	`(and ,my-tutorial--indented-para (zero-or-more ,my-tutorial--indented-para)))

(defvar my-tutorial--instructions	`(and "\n" ">>" (one-or-more any) (zero-or-more ,my-tutorial--indented-lines)))

(defvar my-tutorial-extra-keys
  '(
    "<chr>"
    "<ESC> <ESC> <ESC>"
    "<ESC> C-v"
    "<ESC>v"
    "<SPC>"
    "C-<SPC>"
    "C-<chr>"
    "C-u 8 *"
    "C-u 100"
    "CONTROL-L"
    "CONTROL-h"
    "CONTROL-x"
    "DEL"
    "M-<DEL>"
    "M-<chr>"
    "META Less-than"
    "META-f"
    "META-q"
    "META-x"
    "META\nGreater-than"
    "<Return>"
    ))

(defvar my-tutorial--cmds
  (sort
   (delete-dups
    (append '(apropos-command delete-forward-char delete-frame
			      delete-other-frames describe-function describe-variable
			      help-for-help info info-emacs-manual keyboard-escape-quit
			      kill-buffer make-frame-command )
	    (mapcar 'car tutorial--default-keys)))
   #'string<))

(defvar my-tutorial-keys
  `(or ,@(sort
	  (delete-dups
	   `(,@my-tutorial-extra-keys
	     ,@(apply 'append
		      (cl-loop for cmd in my-tutorial--cmds
			       collect (cl-loop for keydesc in
						(cl-loop for keys in (where-is-internal cmd)
							 collect (key-description keys))
						unless (string-match-p "^<menu-bar>" keydesc)
						collect keydesc)))))
	  #'string<)))

(defvar my-tutorial-keys-with-repeat
  `(and (zero-or-one "C-u " (and (in digit) (zero-or-more (and " " digit))) " ") ,my-tutorial-keys))

(defvar my-tutorial-extended-commands
  '(and (or "M-x" "C-h a" "C-h f" "C-x b" "C-x C-f" "C-x C-s") " " (one-or-more any)  (or "<Return>" "<Tab>")))

(defvar my-tutorial-commands `(or ,my-tutorial-extended-commands ,my-tutorial-keys-with-repeat))

(defvar my-tutorial--modifier-keys
  `(or
    "ALT"
    "CONTROL"
    "CTL"
    "CTRL"
    "DEL"
    "EDIT"
    "ESC"
    "META"
    "Return"
    "SPC"
    "TAB"
    ))

(defvar my-tutorial-modifier-keys `(and
				    (zero-or-one "<")
				    ,my-tutorial--modifier-keys
				    (zero-or-one ">")
				    ))

;; (message (rx-to-string my-tutorial--indented-paras))

;; (message (rx-to-string my-tutorial--indented-lines))

;; (message (rx-to-string my-tutorial-commands))

(define-derived-mode my-tutorial-mode outline-mode
  "Mode for fontified TUTORIAL."

  (outline-mode)
  (which-function-mode 1)
  (hi-lock-mode 1)
  (goto-address-mode 1)

  (let ((case-fold-search nil))
    (highlight-regexp (rx-to-string my-tutorial-modifier-keys) 'my-tutorial-modifier-keys)
    (highlight-regexp (rx-to-string my-tutorial--indented-paras) 'my-tutorial-table-face)
    (highlight-regexp (rx-to-string my-tutorial--instructions) 'my-tutorial-instructions)
    (highlight-regexp (rx-to-string my-tutorial-commands) 'my-tutorial-command)
    (highlight-regexp (rx-to-string my-tutorial--important-note) 'my-tutorial-important-instructions)))

(advice-add 'help-with-tutorial :after #'my-tutorial-mode)

(provide 'my-tutorial)
