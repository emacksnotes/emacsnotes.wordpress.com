(with-eval-after-load 'outline

  (define-key outline-minor-mode-map [(control tab)] 'org-cycle)
  (define-key outline-minor-mode-map [backtab] 'org-global-cycle)

  (let* ((show-items (mapcar 'car (cdr (reverse (cdddr (assq 'show (cdr outline-mode-menu-bar-map)))))))
	 (hide-items (mapcar 'car (cdr (reverse (cdddr (assq 'hide (cdr outline-mode-menu-bar-map)))))))
	 (all-items (append show-items hide-items)))
    (dolist (item all-items)
      (define-key outline-minor-mode-map (vector 'menu-bar 'outline item) 'undefined)))
  
  ;; (outline-show-subtree outline-show-children outline-show-branches outline-show-entry outline-show-all)
  ;; (outline-hide-other outline-hide-sublevels outline-hide-subtree outline-hide-entry outline-hide-body outline-hide-leaves)
  
  (easy-menu-define my-outline-minor-mode-menu outline-minor-mode-map "My Outline Minor Mode Menu"
    '("Outline Cycle"
      ["Cycle Visibility" org-cycle]
      ["Cycle Global Visibility" org-global-cycle]
      ["Show All" outline-show-all t]))


  (define-key outline-mode-map [menu-bar hide] 'undefined)
  (define-key outline-mode-map [menu-bar show] 'undefined)

  (define-key outline-mode-map [(tab)] 'org-cycle)
  (define-key outline-mode-map [backtab] 'org-global-cycle)

  (easy-menu-define my-outline-mode-menu outline-mode-map "My Outline Mode Menu"
    '("Outline Cycle"  :active (not (eq major-mode 'org-mode))
      ["Cycle Visibility" org-cycle]
      ["Cycle Global Visibility" org-global-cycle]
      ;; ["Show All" outline-show-all t]
      ))

  )

(add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)

(provide 'my-outline-menu)
