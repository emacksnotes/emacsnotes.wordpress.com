(add-hook 'tabulated-list-mode-hook 'tablist-minor-mode)

(with-eval-after-load 'tablist
  (easy-menu-define my-tablist-minor-mode-map-misc-menu tablist-minor-mode-map "Menu for Tablist Minor Mode Map."
    '("Tablist Misc"
      ["Sort" tablist-sort :help "(tablist-sort &optional COLUMN)\n\nSort the tabulated-list by COLUMN.\n\nCOLUMN may be either a name or an index.  The default compare\nfunction is given by the `tabulated-list-format', which see.\n\nThis function saves the current sort column and the inverse\nsort-direction in the variable `tabulated-list-sort-key', which\nalso determines the default COLUMN and direction.\n\nThe main difference to `tabulated-list-sort' is, that this\nfunction sorts the buffer in-place and it ignores a nil sort\nentry in `tabulated-list-format' and sorts on the column\nanyway (why not ?)."]
      ["Do Kill Lines" tablist-do-kill-lines :help "(tablist-do-kill-lines &optional ARG INTERACTIVE)\n\nRemove ARG lines from the display."]
      "--"
      ["Export Csv" tablist-export-csv :help "(tablist-export-csv &optional SEPARATOR ALWAYS-QUOTE-P INVISIBLE-P OUT-BUFFER DISPLAY-P)\n\nExport a tabulated list to a CSV format.\n\nUse SEPARATOR (or ;) and quote if necessary (or always if\nALWAYS-QUOTE-P is non-nil).  Only consider non-filtered entries,\nunless invisible-p is non-nil.  Create a buffer for the output or\ninsert it after point in OUT-BUFFER.  Finally if DISPLAY-P is\nnon-nil, display this buffer.\n\nReturn the output buffer."]
      "--"
      ["Previous Line" tablist-previous-line :help "(tablist-previous-line &optional N)"]
      ["Next Line" tablist-next-line :help "(tablist-next-line &optional N)"]
      "--"
      ["Revert" tablist-revert :help "(tablist-revert)\n\nRevert the list with marks preserved, position kept."]
      ["Quit" tablist-quit :help "(tablist-quit)"]))

  (easy-menu-define my-tablist-minor-mode-map-mark-menu tablist-minor-mode-map "Menu for Tablist Minor Mode Map."
    '("Tablist Mark"
      ["Mark Items Regexp" tablist-mark-items-regexp :help "(tablist-mark-items-regexp COLUMN-NAME REGEXP)\n\nMark entries matching REGEXP in column COLUMN-NAME."]
      ["Mark Items Numeric" tablist-mark-items-numeric :help "(tablist-mark-items-numeric BINOP COLUMN-NAME OPERAND)\n\nMark items fulfilling BINOP with arg OPERAND in column COLUMN-NAME.\n\nFirst the column's value is coerced to a number N.  Then the test\nproceeds as (BINOP N OPERAND)."]
      "--"
      ["Mark Forward" tablist-mark-forward :help "(tablist-mark-forward &optional ARG INTERACTIVE)\n\nMark ARG entries forward.\n\nARG is interpreted as a prefix-arg.  If interactive is non-nil,\nmaybe use the active region instead of ARG.\n\nSee `tablist-put-mark' for how entries are marked."]
      ["Unmark Forward" tablist-unmark-forward :help "(tablist-unmark-forward &optional ARG INTERACTIVE)\n\nUnmark ARG entries forward.\n\nSee `tablist-mark-forward'."]
      ["Unmark Backward" tablist-unmark-backward :help "(tablist-unmark-backward &optional ARG INTERACTIVE)\n\nUnmark ARG entries backward.\n\nSee `tablist-mark-forward'."]
      "--"
      ["Change Marks" tablist-change-marks :help "(tablist-change-marks OLD NEW)\n\nChange all OLD marks to NEW marks.\n\nOLD and NEW are both characters used to mark files."]
      "--"
      ["Toggle Marks" tablist-toggle-marks :help "(tablist-toggle-marks)\n\nUnmark all marked and mark all unmarked entries.\n\nSee `tablist-put-mark'."]
      ["Unmark All Marks" tablist-unmark-all-marks :help "(tablist-unmark-all-marks &optional MARKS INTERACTIVE)\n\nRemove alls marks in MARKS.\n\nMARKS should be a string of mark characters to match and defaults\nto all marks.  Interactively, remove all marks, unless a prefix\narg was given, in which case ask about which ones to remove.\nGive a message, if interactive is non-nil.\n\nReturns the number of unmarked marks."]))

  (easy-menu-define my-tablist-minor-mode-map-filter-menu tablist-minor-mode-map "Menu for Tablist Minor Mode Map."
    '("Tablist Filter"
      ["Push Regexp Filter" tablist-push-regexp-filter :help "(tablist-push-regexp-filter COLUMN-NAME REGEXP)\n\nAdd a new filter matching REGEXP in COLUMN-NAME.\n\nThe filter is and'ed with the current filter.  Use\n`tablist-toggle-first-filter-logic' to change this."]
      ["Push Equal Filter" tablist-push-equal-filter :help "(tablist-push-equal-filter COLUMN-NAME STRING)\n\nAdd a new filter whre string equals COLUMN-NAME's value.\n\nThe filter is and'ed with the current filter.  Use\n`tablist-toggle-first-filter-logic' to change this."]
      ["Push Numeric Filter" tablist-push-numeric-filter :help "(tablist-push-numeric-filter OP COLUMN-NAME 2ND-ARG)\n\nAdd a new filter matching a numeric predicate.\n\nThe filter is and'ed with the current filter.  Use\n`tablist-toggle-first-filter-logic' to change this."]
      ["Pop Filter" tablist-pop-filter :help "(tablist-pop-filter &optional N INTERACTIVE)\n\nRemove the first N filter components."]
      "--"
      ["Negate Filter" tablist-negate-filter :help "(tablist-negate-filter &optional INTERACTIVE)\n\nNegate the current filter."]
      ["Suspend Filter" tablist-suspend-filter :style toggle :selected tablist-filter-suspended :help "(tablist-suspend-filter &optional FLAG)\n\nTemporarily disable filtering according to FLAG.\n\nInteractively, this command toggles filtering."]
      ["Clear Filter" tablist-clear-filter :help "(tablist-clear-filter)"]
      ["Toggle First Filter Logic" tablist-toggle-first-filter-logic :help "(tablist-toggle-first-filter-logic)\n\nToggle between and/or for the first filter operand."]
      ["Display Filter" tablist-display-filter :style toggle :selected (assq 'tablist-display-filter-mode-line-tag mode-line-format) :help "(tablist-display-filter &optional FLAG)\n\nDisplay the current filter according to FLAG.\n\nIf FLAG has the value 'toggle, toggle it's visibility.\nIf FLAG has the 'state, then do nothing but return the current\nvisibility."]
      ["Edit Filter" tablist-edit-filter :help "(tablist-edit-filter)"]
      "--"
      ["Name Current Filter" tablist-name-current-filter :help "(tablist-name-current-filter NAME)"]
      ["Push Named Filter" tablist-push-named-filter :help "(tablist-push-named-filter NAME)\n\nAdd a named filter called NAME.\n\nNamed filter are saved in the variable `tablist-named-filter'."]
      ["Delete Named Filter" tablist-delete-named-filter :help "(tablist-delete-named-filter NAME &optional MODE)"]
      ["Deconstruct Named Filter" tablist-deconstruct-named-filter :help "(tablist-deconstruct-named-filter)"]))

  (easy-menu-define my-tablist-minor-mode-map-column-menu tablist-minor-mode-map "Menu for Tablist Minor Mode Map."
    '("Tablist Column"
      ["Forward Column" tablist-forward-column :help "(tablist-forward-column N)\n\nMove n columns forward, while wrapping around."]
      ["Backward Column" tablist-backward-column :help "(tablist-backward-column N)\n\nMove n columns backward, while wrapping around."]
      "--"
      ["Move To Major Column" tablist-move-to-major-column :help "(tablist-move-to-major-column &optional FIRST-SKIP-INVISIBLE-P)\n\nMove to the first major column."]
      "--"
      ["Shrink Column" tablist-shrink-column :help "(tablist-shrink-column &optional COLUMN WIDTH)"]
      ["Enlarge Column" tablist-enlarge-column :help "(tablist-enlarge-column &optional COLUMN WIDTH)\n\nEnlarge column COLUMN by WIDTH.\n\nThis function is lazy and therfore pretty slow."])))

(provide 'my-tablist-minor-mode-menu)
