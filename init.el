;;; init.el --- GOEDEV personal emacs configuration file  -*- lexical-binding: t -*-

;; Copyright (c) 2010-2021 Gökmen Görgen
;;
;; Author: Gökmen Görgen <gkmngrgn@gmail.com>
;; URL: https://github.com/gkmngrgn/emacs.d/

;;; Commentary:

;; Take a look at README.md file for more information.

;;; Code:

(menu-bar-mode 0)
(global-hl-line-mode)
(global-auto-revert-mode)
(delete-selection-mode 1)
(temp-buffer-resize-mode t)

;; UTF-8
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-language-environment   'utf-8)

;; KEYMAPS
(global-set-key (kbd "C-c SPC") 'comment-line)

(defun prev-window ()
  "Switch to previous window."
  (interactive)
  (other-window -1))

(defalias 'yes-or-no-p 'y-or-n-p)

;; HOOKS
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'text-mode-hook   'visual-line-mode)

;; PACKAGE MANAGER
(defvar bootstrap-version)

(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; PACKAGES

;; theme
(straight-use-package 'modus-themes)
(setq modus-themes-slanted-constructs t)
(setq modus-themes-bold-constructs nil)

(modus-themes-load-vivendi)

(if (display-graphic-p)
    (require 'init-gui))

;; make gui look like in the terminal.
(global-set-key (kbd "<f5>")
                (lambda ()
                  (interactive)
                  (modus-themes-toggle)
                  (if (display-graphic-p) (my-gui-change))))

(straight-use-package 'all-the-icons)

;; navigation
(straight-use-package 'avy)

(avy-setup-default)
(global-set-key (kbd "M-g g") 'avy-goto-char-2)
(global-set-key (kbd "M-g f") 'avy-goto-line)

;; code auto-complete
(straight-use-package 'company)

(setq company-dabbrev-ignore-case t)
(setq company-dabbrev-code-ignore-case t)
(setq company-idle-delay 0.5)
(setq company-minimum-prefix-length 2)
(setq company-require-match 'never)
(setq company-show-numbers nil)
(setq company-tooltip-align-annotations t)
(setq company-tooltip-flip-when-above nil)
(setq company-tooltip-limit 10)

(global-company-mode)

(global-set-key (kbd "TAB") 'company-indent-or-complete-common)

(push 'company-capf company-backends)

;; flycheck
(straight-use-package 'flycheck)
(straight-use-package 'flycheck-rust)

(global-flycheck-mode)

(add-hook 'flycheck-mode-hook #'flycheck-rust-setup)

;; command completion
(straight-use-package 'ivy)
(straight-use-package 'counsel)
(straight-use-package 'swiper)
(straight-use-package 'which-key)

(ivy-mode)
(which-key-mode)

(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers nil)
(setq search-default-mode #'char-fold-to-regexp)

(global-set-key (kbd "C-s")     'swiper)
(global-set-key (kbd "C-x C-b") 'counsel-ibuffer)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "M-x")     'counsel-M-x)
(global-set-key (kbd "C-c e")   'counsel-flycheck)
(global-set-key (kbd "C-c g")   'counsel-git)
(global-set-key (kbd "C-c j")   'counsel-git-grep)
(global-set-key (kbd "C-c k")   'counsel-rg)

(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

;; lsp
(straight-use-package 'lsp-mode)
(straight-use-package 'lsp-ui)
(straight-use-package 'lsp-dart)
(straight-use-package 'lsp-ivy)
(straight-use-package 'lsp-pyright)

(setq lsp-completion-provider :capf)
(setq lsp-rust-server 'rust-analyzer)
(setq lsp-prefer-flymake nil)  ; flycheck is better
(setq lsp-modeline-code-actions-segments '(name))
(setq lsp-keymap-prefix "C-c l")
(setq lsp-idle-delay 0.500)
(setq lsp-enable-snippet nil)  ; company is better
(setq lsp-log-io nil)  ; if set to true can cause a performance hit
(setq lsp-signature-doc-lines 10)
(setq lsp-signature-auto-activate nil)
(setq lsp-ui-doc-enable nil)

(add-hook 'lsp-mode-hook        #'lsp-enable-which-key-integration)
(add-hook 'c-mode-hook          #'lsp-deferred)
(add-hook 'dart-mode-hook       #'lsp-deferred)
(add-hook 'gdscript-mode-hook   #'lsp-deferred)
(add-hook 'go-mode-hook         #'lsp-deferred)
(add-hook 'javascript-mode-hook #'lsp-deferred)
(add-hook 'python-mode-hook (lambda ()
                              (require 'lsp-pyright)
                              (lsp-deferred)))
(add-hook 'rust-mode-hook       #'lsp-deferred)
(add-hook 'yaml-mode-hook       #'lsp-deferred)

(with-eval-after-load 'lsp-ui
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references]  #'lsp-ui-peek-find-references)
  (define-key lsp-ui-mode-map (kbd "C-c u")                 #'lsp-ui-imenu))

;; git
(straight-use-package 'diff-hl)
(straight-use-package 'magit)

(global-diff-hl-mode)
(diff-hl-margin-mode)

(add-hook 'magit-pre-refresh-hook  'diff-hl-magit-pre-refresh)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

;; org-mode customizations
(setq org-todo-keywords '((sequence "TODO" "INPROGRESS" "|" "DONE")))
(setq org-log-done t)

;; editing
(straight-use-package 'expand-region)
(straight-use-package 'rainbow-delimiters)
(straight-use-package 'smartparens)
(straight-use-package 'undo-fu)
(straight-use-package 'unfill)
(straight-use-package 'multiple-cursors)

(with-eval-after-load (require 'smartparens-config))

(smartparens-global-mode t)
(show-smartparens-global-mode t)
(sp-local-pair 'web-mode "{" "}" :actions nil)

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-_"))
(global-set-key   (kbd "C-z")         'undo-fu-only-undo)
(global-set-key   (kbd "C-M-z")       'undo-fu-only-redo)

(global-set-key   (kbd "C-M-q")       'unfill-paragraph)
(global-set-key   (kbd "C-M-w")       'er/expand-region)
(global-set-key   (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key   (kbd "C->")         'mc/mark-next-like-this)
(global-set-key   (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key   (kbd "C-c C-<")     'mc/mark-all-like-this)

;; web
(straight-use-package 'web-mode)
(setq web-mode-markup-indent-offset 2)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

;; window auto-resize
(straight-use-package 'golden-ratio)

(global-set-key (kbd "C-c f") 'golden-ratio)

;; python
(straight-use-package 'poetry)

;; FILE MODES
(straight-use-package 'bazel)
(straight-use-package 'csv-mode)
(straight-use-package 'dart-mode)
(straight-use-package 'dockerfile-mode)
(straight-use-package 'gdscript-mode)
(straight-use-package 'go-mode)
(straight-use-package 'json-mode)
(straight-use-package 'kotlin-mode)
(straight-use-package 'markdown-mode)
(straight-use-package 'powershell)
(straight-use-package 'rust-mode)
(straight-use-package 'typescript-mode)
(straight-use-package 'vue-mode)
(straight-use-package 'yaml-mode)

(setq markdown-command "multimarkdown")
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'"       . markdown-mode))

(setq mmm-submode-decoration-level 0)
(add-hook 'vue-mode-hook (lambda () (setq syntax-ppss-table nil)))

(setq js-indent-level 2)

;;; init.el ends here

;; Local Variables:
;; coding: utf-8
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
