(require 'loccur)

(with-eval-after-load 'loccur
  ;; defines shortcut for loccur of the current word
  (define-key global-map [(control o)] 'loccur-current)
  ;; defines shortcut for the interactive loccur command
  (define-key global-map [(control meta o)] 'loccur)
  ;; defines shortcut for the loccur of the previously found word
  (define-key global-map [(control shift o)] 'loccur-previous-match)

  (define-key-after global-map
    [menu-bar extra-tools]
    (cons "Extra Tools"
	  (easy-menu-create-menu "Extra Tools" nil))
    'tools)

  (easy-menu-define my-loccur-menu nil "Menu for Loccur."
    '("Loccur" :visible (featurep 'loccur)
      ["Loccur Current Word" loccur-current :help "Call `loccur' for the current word."]
      "--"
      ["Loccur" loccur :help "Perform a simple grep in current buffer.\n\nThis command hides all lines from the current buffer except those\ncontaining the regular expression REGEX.  A second call of the function\nunhides lines again.\n\nWhen called interactively, either prompts the user for REGEXP or,\nwhen called with an active region, uses the content of the\nregion.\n\n(fn REGEX)"]
      ["Loccur, but Don't Highlight" loccur-no-highlight :help "Perform search like loccur, but temporary removing match highlight.\nREGEX is regexp to search\n\n(fn REGEX)"]
      "--"
      ["Loccur Previous Match" loccur-previous-match :help "Call `loccur' for the previously found word."]
      "--"
      ["Highlight Matches" loccur-toggle-highlight :style toggle :selected loccur-highlight-matching-regexp :help "Toggle the highlighting of the match."]
      ;; ["Loccur Mode" loccur-mode :style toggle :selected loccur-mode :help "Minor mode for navigating through the file.\nHides all lines without matches like `occur' does, but without opening\na new window.\n\n(fn &optional ARG)"]
      ))

  (easy-menu-add-item (current-global-map) '("menu-bar" "extra-tools") my-loccur-menu))

(provide 'my-loccur-menu)
