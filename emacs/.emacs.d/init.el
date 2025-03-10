;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; emacs
(setq inhibit-startup-message t)  ; don't show the startup message
(setq visible-bell t)  ; flash when the bell rings
(setq use-dialog-box nil)  ; don't use dialog boxes

;; disable the menu bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; make emacs remember recently opened files
;; (recentf-open-files)
(recentf-mode 1)

;; save minibuffer history (m-x commands, ...)
(savehist-mode 1)

;; remember the last location in a file
(save-place-mode 1)

;; enable mouse
(xterm-mouse-mode 1)

;; disable auto-save-mode
(auto-save-mode 0)

;; reload files when they change on disk
(setq global-auto-revert-non-file-buffers t)
(global-auto-revert-mode 1)

;; highlight current line
(global-hl-line-mode 1)

;; move customization variables to a separate file
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage) ; Load the custom variable file

;; my secrets
(load-file (locate-user-emacs-file "sean.el"))

;; initialize package
;; refresh -> (package-refresh-contents)
(require 'package)
(add-to-list 'package-archives
	     '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; straight.el bootstrap
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; load theme
(load-theme 'gruvbox)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dired mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; with human-readable size
(setq dired-listing-switches "-alh")

;; Suggest the directory in another Dired buffer as target destination when copying/moving files
(setq dired-dwim-target t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; exec-path-from-shell
;; bring my shell environment to emacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless (package-installed-p 'exec-path-from-shell)
  (package-install 'exec-path-from-shell))

;; set $PATH, ... when running in GUI
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; when running as a daemon
(when (daemonp)
  (exec-path-from-shell-initialize))

;; copy environment variables from shell
(exec-path-from-shell-copy-env "PKM_DIR")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tree-sitter
;; ts-fold
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(unless (package-installed-p 'tree-sitter)
  (package-install 'tree-sitter))
(unless (package-installed-p 'tree-sitter-langs)
  (package-install 'tree-sitter-langs))

;; enable whenever tree-sitter is supporting the current major mode
;; https://emacs-tree-sitter.github.io/syntax-highlighting/
(global-tree-sitter-mode)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)

;; install ts-fold with straight.el
(use-package ts-fold
  :straight (ts-fold :type git :host github :repo "emacs-tree-sitter/ts-fold"))

;; enable whenever tree-sitter is turned on
(global-ts-fold-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; evil & extensions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ensure evil is installed
(unless (package-installed-p 'evil)
  (package-install 'evil))

;; open new window on the right & bottom
(setq evil-vsplit-window-right t)
(setq evil-split-window-below t)

;; fix <TAB> in the org-mode
;; conflict w/ (org-cycle)
(setq evil-want-C-i-jump nil)

;; enable C-u
(setq evil-want-C-u-scroll t)

;; set shiftwidth
(setq evil-shift-width 2)

;; enable evil-mode
(require 'evil)
(evil-mode 1)

;; enable evil-leader-mode

(unless (package-installed-p 'evil-leader)
  (package-install 'evil-leader))
(require 'evil-leader)
(global-evil-leader-mode)

;; key bindings - leader key
(evil-leader/set-leader ",")
(evil-set-leader 'normal "," t)

;; make <RET> follow org-mode links by disabling evil mode's binding (org-return-follow-link)
;; https://emacs.stackexchange.com/questions/46371/how-can-i-get-ret-to-follow-org-mode-links-when-using-evil-mode
(with-eval-after-load 'evil-maps
  ;(define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil)
  (define-key evil-motion-state-map (kbd "RET") nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dw/org-mode-setup ()
  (org-indent-mode)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil))

(use-package org
  :hook (org-mode . dw/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
	org-hide-emphasis-markers t))

;; my org-files directory
(setq org-directory (concat (getenv "PKM_DIR") "/org"))

;; enable struture template
(require 'org-tempo)

;; setup org-capture
(setq org-default-notes-file (concat org-directory "/notes.org"))

;; close all the other windows when opening org-capture
(add-hook 'org-capture-mode-hook 'delete-other-windows)

;; show agenda in the current window
(setq org-agenda-window-setup 'current-window)

;; make <RET> follow links
(setq org-return-follows-link t)

;; setup #+STARTUP globally
(setq org-startup-folded 'content)

;; list markers
(font-lock-add-keywords 'org-mode
			'(("^ *\\([-]\\) "
			    (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; ensure mixed-pitch-mode is installed
;; `mixed-pitchW-mode` fixes `variable-pitch-mode`'s indentation issue with org-indent-mode
(unless (package-installed-p 'mixed-pitch)
  (package-install 'mixed-pitch))

(add-hook 'org-mode-hook 'mixed-pitch-mode)

;; insert when a item was marked as done
(setq org-log-done 'time)

;; enable log-mode on the agenda
(setq org-agenda-start-with-log-mode t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-roam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ensure org-roam is installed
(unless (package-installed-p 'org-roam)
  (package-install 'org-roam))

;; tell note directory to org-roam
(setq org-roam-directory
  ;; resolve symbolic links
  (file-truename
   (concat (getenv "PKM_DIR") "/org")))

;; run (org-roam-db-sync) automatically
(org-roam-db-autosync-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-bullets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ensure marginalia is installed
(unless (package-installed-p 'org-bullets)
  (package-install 'org-bullets))

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-download
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ensure marginalia is installed
(unless (package-installed-p 'org-download)
  (package-install 'org-download))

(require 'org-download)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; consult
;; adds search and navigation commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq consult-fd-args "fd --hidden")
(setq consult-async-min-input 0)

;; ensure marginalia is installed
(unless (package-installed-p 'marginalia)
  (package-install 'marginalia))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

;; consult-org-roam.el
(unless (package-installed-p 'consult-org-roam)
  (package-install 'consult-org-roam))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-roam-ui
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(unless (package-installed-p 'org-roam-ui)
  (package-install 'org-roam-ui))
(use-package org-roam-ui
    :after org-roam ;; or :after org
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vertico
;; vertical completion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ensure vertico is installed
(unless (package-installed-p 'vertico)
  (package-install 'vertico))
(unless (package-installed-p 'orderless)
  (package-install 'orderless))

;; Enable vertico
(use-package vertico
  :custom
  (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 30) ;; Show more candidates
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom

  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; elfeed
;; RSS manager
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ensure vertico is installed
(unless (package-installed-p 'elfeed)
  (package-install 'elfeed))

;; default filter
;; https://github.com/skeeto/elfeed?tab=readme-ov-file#filter-syntax
(setq-default elfeed-search-filter "@1-week-ago ")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; visual-fill-column
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ensure visual-fill-column is installed
;; (unless (package-installed-p 'visual-fill-column)
;;   (package-install 'visual-fill-column))

;; (setq-default fill-column 120)
;; (visual-fill-column-mode 1)
;; (add-hook 'visual-line-mode-hook #'visual-fill-column-mode)
;; (setq-default visual-fill-column-center-text t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lsp-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; suppress warnings
;; e.g. semgrep/rulesRefreshed
;; https://emacs.stackexchange.com/questions/81247/with-lsp-mode-why-do-i-get-an-unknown-notification-about-refreshed-rules-from-s
;(add-to-list 'warning-suppress-log-types '(lsp-mode))
;(add-to-list 'warning-suppress-types '(lsp-mode))
;
;(unless (package-installed-p 'company)
;  (package-install 'company))
;
;;; completion UI
;(company-mode 1)
;
;;; adjust gc-cons-threshold
;(setq gc-cons-threshold 100000000)
;
;;; increase the amount of data which emacs can read from the process
;(setq read-process-output-max (* 1024 1024)) ;; 1mb
;
;;; performance - off logging
;(setq lsp-log-io nil) ; if set to true can cause a performance hit
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; lsp-pyright
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;(setq lsp-keymap-prefix "")
;(require 'lsp-mode)
;
;(use-package lsp-pyright
;  :ensure t
;  :custom (lsp-pyright-langserver-command "pyright") ;; or basedpyright
;  :hook (python-mode . (lambda ()
;                          (require 'lsp-pyright)
;                          (lsp))))  ; or lsp-deferred
;
;(add-hook 'python-mode-hook 'eglot-ensure)
;(with-eval-after-load 'eglot
;  (add-to-list 'eglot-server-programs
;               '(python-mode . ("ruff" "server")))
;  (add-hook 'after-save-hook 'eglot-format))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; key bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; org-agenda
(evil-leader/set-key "a" 'org-agenda)

;; org-capture
(evil-leader/set-key "c" 'org-capture)

;; consult
(evil-leader/set-key "ff" 'consult-fd)
(evil-leader/set-key "fr" 'consult-ripgrep)
(evil-leader/set-key "fb" 'consult-buffer)

;; org-roam & consult-org-roam
(evil-leader/set-key "zf" 'consult-org-roam-file-find)
(evil-leader/set-key "zz" 'org-roam-capture)
(evil-leader/set-key "zr" 'consult-org-roam-search)
(evil-leader/set-key "zb" 'consult-org-roam-backlinks)

;; treemacs
(evil-define-key 'normal 'global (kbd "gR") 'lsp-treemacs-find-references)
(evil-define-key 'normal 'global (kbd "C-n") 'treemacs)

;; dictionary
(evil-leader/set-key "dl" 'dictionary-lookup-definition)

; remap :q, :wq for org-capture-mode
(evil-define-key nil org-capture-mode-map
  [remap evil-save-and-close] #'org-capture-finalize
  [remap evil-save-modified-and-close] #'org-capture-finalize
  [remap evil-quit] #'org-capture-finalize)
