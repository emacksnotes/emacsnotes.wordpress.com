(easy-menu-define my-hi-lock-menu nil "Menu for customizing regexp highlighting."
  `("Customize Regexp Highlighting"
    ["Global Hi Lock Mode"
     (progn
       (customize-set-variable 'global-hi-lock-mode
			       (not global-hi-lock-mode))
       (customize-save-variable 'global-hi-lock-mode global-hi-lock-mode))
     :style toggle :selected global-hi-lock-mode :help "Toggle Hi-Lock mode in all buffers"]
    ["Hi Lock Mode" hi-lock-mode :style toggle :selected hi-lock-mode :help "Toggle selective highlighting of patterns"]
    ["Auto Select Face"
     (customize-save-variable 'hi-lock-auto-select-face
			      (not hi-lock-auto-select-face))
     :style toggle :selected hi-lock-auto-select-face :enable
     (featurep 'hi-lock)
     :help "\"Non-nil means highlighting commands do not prompt for the face to use.\nInstead, each hi-lock command will cycle through the faces in\n`hi-lock-face-defaults'.\""]
    "--"
    ["Customize"
     (customize-group 'hi-lock)]))

(easy-menu-add-item menu-bar-edit-menu nil my-hi-lock-menu)

(with-eval-after-load 'hi-lock
  (define-key-after hi-lock-menu
    [unhighlight-regexp-all]
    `(menu-item "Remove All Highlighting"
		(lambda nil
		  (interactive)
		  (unhighlight-regexp t))
		:enable hi-lock-interactive-patterns :help ,(documentation 'unhighlight-regexp))
    'unhighlight-regexp))

(provide 'my-hi-lock-menu)
