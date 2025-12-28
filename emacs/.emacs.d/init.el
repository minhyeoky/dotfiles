;; -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; emacs
(setq inhibit-startup-message t)  ; don't show the startup message
(setq visible-bell t)  ; flash when the bell rings
(setq use-dialog-box nil)  ; don't use dialog boxes

;; make emacs remember recently opened files
;; (recentf-open-files)
(recentf-mode 1)

;; save minibuffer history (m-x commands, ...)
(savehist-mode 1)

;; remember the last location in a file
(save-place-mode 1)

;; enable mouse
(xterm-mouse-mode 1)

;; reload files when they change on disk
(setq global-auto-revert-non-file-buffers t)
(global-auto-revert-mode 1)

;; highlight current line
(global-hl-line-mode 1)

;; move customization variables to a separate file
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage) ; Load the custom variable file

;; my secrets
(let ((org-secrets-file (locate-user-emacs-file "org.el")))
  (when (file-exists-p org-secrets-file)
    (load-file org-secrets-file)))

;; initialize package
;; refresh -> (package-refresh-contents)
(require 'package)
(add-to-list 'package-archives
	     '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless (package-installed-p 'gruvbox-theme)
  (package-install 'gruvbox-theme))
(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox t))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Font configuration
(set-face-attribute 'default nil
                    :family "JetBrainsMono Nerd Font"
                    :height 120  ; 12pt (height is in 1/10pt units)
                    :weight 'extra-light)

;; Set font for new frames
(add-to-list 'default-frame-alist
             '(font . "JetBrainsMono Nerd Font-12:weight=extralight"))

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
(exec-path-from-shell-copy-env "ORG_DIR")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tree-sitter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(unless (package-installed-p 'tree-sitter)
  (package-install 'tree-sitter))
(unless (package-installed-p 'tree-sitter-langs)
  (package-install 'tree-sitter-langs))

;; enable whenever tree-sitter is supporting the current major mode
;; https://emacs-tree-sitter.github.io/syntax-highlighting/
(global-tree-sitter-mode)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Evil Mode & Extensions
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
  (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
  (define-key evil-visual-state-map (kbd "C-u") 'evil-scroll-up)
  (define-key evil-motion-state-map (kbd "C-u") 'evil-scroll-up)
  (define-key evil-motion-state-map (kbd "TAB") nil)
  (define-key evil-motion-state-map (kbd "RET") nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dw/org-mode-setup ()
  (org-indent-mode)
  ; (auto-fill-mode 0)
  ; (visual-line-mode 1)
  (setq evil-auto-indent nil))

(use-package org
  :hook (org-mode . dw/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
	org-hide-emphasis-markers t))

;; my org-files directory
(setq org-directory (concat (getenv "ORG_DIR") "/org"))


;; close all the other windows when opening org-capture
(add-hook 'org-capture-mode-hook 'delete-other-windows)

;; show agenda in the current window
(setq org-agenda-window-setup 'current-window)

;; make <RET> follow links
(setq org-return-follows-link t)

;; setup #+STARTUP globally
(setq org-startup-folded 'content)

;; auto-update checkbox statistics cookies
(defun my/org-auto-update-checkbox-cookies ()
  "Add [/] to headings with checkboxes, remove from those without."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward org-heading-regexp nil t)
      (let* ((heading-start (line-beginning-position))
             (heading-end (line-end-position))
             (element (org-element-at-point))
             (has-checkboxes nil)
             (has-cookie nil))
        ;; Check if heading already has a statistics cookie
        (save-excursion
          (goto-char heading-start)
          (setq has-cookie (re-search-forward "\\[\\([0-9]*%\\|[0-9]*/[0-9]*\\)\\]" heading-end t)))
        ;; Check if subtree has checkboxes
        (save-excursion
          (org-back-to-heading t)
          (let ((subtree-end (save-excursion (org-end-of-subtree t t))))
            (setq has-checkboxes (re-search-forward "^[ \t]*- \\[[ X-]\\]" subtree-end t))))
        ;; Add or remove cookie
        (cond
         ((and has-checkboxes (not has-cookie))
          ;; Add [/] at the end of heading
          (goto-char heading-end)
          (insert " [/]"))
         ((and (not has-checkboxes) has-cookie)
          ;; Remove the cookie
          (goto-char heading-start)
          (when (re-search-forward "\\[\\([0-9]*%\\|[0-9]*/[0-9]*\\)\\]" heading-end t)
            (replace-match "")))))))
  ;; Update all statistics cookies
  (org-update-checkbox-count 'all))

;; auto-update checkbox heading on save
(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'my/org-auto-update-checkbox-cookies nil 'local)))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-bullets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ensure org-bullets is installed
(unless (package-installed-p 'org-bullets)
  (package-install 'org-bullets))

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

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
;; Key Bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; org-mode
(evil-leader/set-key "t" 'org-toggle-narrow-to-subtree)

;; org-agenda
(evil-leader/set-key "a" 'org-agenda)

;; consult
(evil-leader/set-key "ff" 'consult-fd)
(evil-leader/set-key "fr" 'consult-ripgrep)
(evil-leader/set-key "fb" 'consult-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Misc 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; load local config file
(let ((local-file (expand-file-name "local.el" user-emacs-directory)))
  (when (file-exists-p local-file)
    (print (concat "Loading local.el at: " local-file))
    (load local-file)))
