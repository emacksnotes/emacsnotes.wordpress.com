(defun my-delimits-column-region
    (orig-fun &rest args)
  (let
      ((delimit-columns-separator
	(read-regexp
	 (format "%s (%s): " "Specify the regexp which separates each column" delimit-columns-separator)
	 (list delimit-columns-separator)))
       (delimit-columns-before
	(read-string
	 (format "%s (%s): " "Specify a string to be inserted before each column" delimit-columns-before)
	 nil nil delimit-columns-before))
       (delimit-columns-after
	(read-string
	 (format "%s (%s): " "Specify a string to be inserted after each column" delimit-columns-after)
	 nil nil delimit-columns-after))
       (delimit-columns-str-separator
	(read-string
	 (format "%s (%s): " "Specify a string to be inserted between each column" delimit-columns-str-separator)
	 nil nil delimit-columns-str-separator))
       (delimit-columns-str-before
	(read-string
	 (format "%s (%s): " "Specify a string to be inserted before all columns" delimit-columns-str-before)
	 nil nil delimit-columns-str-before))
       (delimit-columns-str-after
	(read-string
	 (format "%s (%s): " "Specify a string to be inserted after all columns" delimit-columns-str-after)
	 nil nil delimit-columns-str-after))
       (delimit-columns-format
	(let*
	    ((choices
	      '(("Align Columns" . t)
		("No Formatting")
		("Align Separators" . separator)
		("Pad Columns" . padding)))
	     (default-choice
	       (car
		(rassoc delimit-columns-format choices)))
	     (choice
	      (completing-read
	       (format "%s (%s): " "Specify how to format columns" default-choice)
	       choices nil t nil nil default-choice)))
	  (message "%s" choice)
	  (assoc-default choice choices))))
    (apply orig-fun args)))

(advice-add 'delimit-columns-region :around #'my-delimits-column-region)
(advice-add 'delimit-columns-rectangle :around #'my-delimits-column-region)

(define-key-after global-map
  [menu-bar extra-tools]
  (cons "Extra Tools"
	(easy-menu-create-menu "Extra Tools" nil))
  'tools)

(easy-menu-define my-delim-col-menu nil "Menu for Delim Col"
  '("Delimit Columns in ..."
    ["Region" delimit-columns-region :help "Prettify all columns in a text region"]
    ["Rectangle" delimit-columns-rectangle :help "Prettify all columns in a text rectangle"]
    "---"
    ["Customize" delimit-columns-customize :help "Customization of `columns' group"]))

(easy-menu-add-item (current-global-map) '("menu-bar" "extra-tools") my-delim-col-menu)

(provide 'my-delim-col-menu.el)
