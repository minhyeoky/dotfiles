(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(consult-org-roam pbcopy)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq-default fill-column 80)
(add-hook 'visual-line-mode-hook #'visual-fill-column-mode)
(setq-default visual-fill-column-center-text t)
(add-to-list 'term-file-aliases '("alacritty" . "xterm"))

;; (require 'pbcopy)
;; (turn-on-pbcopy)
