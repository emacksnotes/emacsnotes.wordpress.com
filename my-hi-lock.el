(require 'hi-lock)

(defun my-highlight-regexp-with-string (&optional regexp string face)
  "Display each match of REGEXP as STRING with face FACE.
With a prefix arg, remove all such highlights."
  (interactive
   (unless current-prefix-arg
     (let* ((regexp (read-regexp "Regexp: "))
	    (string (read-string (format "Display %s as : " (propertize regexp 'face 'fixed-pitch-serif)))))
       (list regexp string  (hi-lock-read-face-name)))))
  (if current-prefix-arg  (remove-overlays nil nil 'my-overlay t)
    (save-excursion
      (goto-char (point-min))
      (let ((case-fold-search nil))
	(while (re-search-forward regexp nil t)
	  (let ((ov (make-overlay (match-beginning 0) (match-end 0))))
	    (overlay-put ov 'my-overlay t)
	    (overlay-put ov 'display string)
	    (overlay-put ov 'face face)))))))

(defun my-remove-all-string-highlights ()
  "Remove all highlights created with `my-highlight-regexp-with-string'."
  (interactive)
  (remove-overlays nil nil 'my-overlay t))

(unless (lookup-key global-map [menu-bar extra-tools])
  (define-key-after global-map
    [menu-bar extra-tools]
    (cons "Extra Tools"
	  (easy-menu-create-menu "Extra Tools" nil))
    'tools))

(global-set-key (kbd "C-x w o") 'my-highlight-regexp-with-string)

(dolist (item '("--"
		["Highlight Regexp With String" my-highlight-regexp-with-string :help "(my-highlight-regexp-with-string &optional REGEXP STRING FACE)\n\nDisplay each match of REGEXP as STRING with face FACE.\nWith a prefix arg, remove all such highlights."]
		["Remove All String Highlights" my-remove-all-string-highlights :help "(my-remove-all-string-highlights)\n\nRemove all highlights created with `my-highlight-regexp-with-string'."]))
  (easy-menu-add-item global-map '("menu-bar" "extra-tools") item nil))

(provide 'my-hi-lock)
