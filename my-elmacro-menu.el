(require 'elmacro)

(with-eval-after-load 'elmacro

  (define-key-after global-map
    [menu-bar extra-tools]
    (cons "Extra Tools"
	  (easy-menu-create-menu "Extra Tools" nil))
    'tools)

  (easy-menu-define my-elmacro-menu global-map "Menu for Elmacro."
    '("Elmacro"
      ["Elmacro Mode" (customize-save-variable 'elmacro-mode (not elmacro-mode)) :style toggle :selected elmacro-mode :help "(elmacro-mode &optional ARG)\n\nToggle emacs activity recording (elmacro mode).\nWith a prefix argument ARG, enable elmacro mode if ARG is\npositive, and disable it otherwise. If called from Lisp, enable\nthe mode if ARG is omitted or nil."]
      "--"
      ["Show Last Commands" elmacro-show-last-commands :active elmacro-mode :help "(elmacro-show-last-commands &optional COUNT)\n\nTake the latest COUNT commands and show them as emacs lisp.\n\nThis is basically a better version of `kmacro-edit-lossage'.\n\nThe default number of commands shown is modifiable in variable\n`elmacro-show-last-commands-default'.\n\nYou can also modify this number by using a numeric prefix argument or\nby using the universal argument, in which case it'll ask for how many\nin the minibuffer."]
      ["Show Last Macro" elmacro-show-last-macro :active elmacro-mode :help "(elmacro-show-last-macro NAME)\n\nShow the last macro as emacs lisp with NAME."]
      "--"
      ["Clear Command History" elmacro-clear-command-history :active elmacro-mode :help "(elmacro-clear-command-history)\n\nClear the list of recorded commands."]))

  (easy-menu-add-item
   (current-global-map)
   '("menu-bar" "extra-tools")
   my-elmacro-menu))

(provide 'my-elmacro-menu)
