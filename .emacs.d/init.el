(custom-set-variables
 '(custom-file (locate-user-emacs-file (format "emacs-%d.el" (emacs-pid))))
 '(ffap-bindings t)
 '(find-file-visit-truename t)
 '(global-auto-revert-mode t)
 '(indent-tabs-mode nil)
 '(inhibit-splash-screen t)
 '(inhibit-startup-screen t)
 '(initial-scratch-message nil)
 '(package-enable-at-startup t)
 '(pop-up-windows nil)
 '(require-final-newline 'visit-save)
 '(scroll-step 1)
 '(set-mark-command-repeat-pop t)
 '(split-width-threshold 0)
 '(system-time-locale "C")
 '(show-paren-mode t)
 '(vc-follow-symlinks nil)
 '(view-read-only t)
 '(viper-mode nil))

(load-theme 'anticolor t)

(eval-and-compile
  (customize-set-variable
   'package-archives '(("melpa" . "https://melpa.org/packages/")
                       ;; ("gnu" . "https://elpa.gnu.org/packages/")
                       ))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)
    :config
    (leaf-keywords-init)))

(leaf eshell
  :bind ("C-c #" . eshell)
  :custom (eshell-path-env . `,(string-join exec-path ":"))
  :config
  (defun eshell/hello ()
    (message "hello world")))

(leaf whitespace
  :hook (before-save-hook . whitespace-cleanup)
  :custom
  (whitespace-space-regexp . "\\(\u3000+\\)")
  (whitespace-style . '(face trailing spaces empty space-mark tab-mark))
  (whitespace-display-mappings . '((space-mark ?\u3000 [?\u25a1])
                                   (tab-mark ?\t [?\u00bb ?\t] [?\\ ?\t])))
  (whitespace-action . '(auto-cleanup))
  :global-minor-mode global-whitespace-mode)

;;;

(leaf ddskk
  :ensure t
  :hook (after-init-hook . my/ddskk-skk-get)
  :init
  (setq default-input-method "japanese-skk")
  (setq skk-status-indicator 'minor-mode)
  (setq skk-egg-like-newline t)
  (setq skk-latin-mode-string "a")
  (setq skk-hiragana-mode-string "あ")
  (setq skk-katakana-mode-string "ア")
  (setq skk-jisx0208-latin-mode-string "Ａ")
  (setq my/ddskk-jisyo-directory (locate-user-emacs-file "jisyo"))
  (defun my/ddskk-skk-get ()
    (unless (file-directory-p my/ddskk-jisyo-directory)
            (skk-get my/ddskk-jisyo-directory))))

(leaf open-junk-file
  :ensure t
  :hook (kill-emacs-hook . my/open-junk-file-delete-files)
  :bind ("C-c j" . open-junk-file)
  :init
  (setq my/open-junk-file-directory (locate-user-emacs-file "junk/"))
  (setq open-junk-file-format (concat my/open-junk-file-directory "%s."))
  (defun my/open-junk-file-delete-files ()
    (interactive)
    (let ((junk-files (directory-files my/open-junk-file-directory t "^\\([^.]\\|\\.[^.]\\|\\.\\..\\)")))
      (dolist (x junk-files) (delete-file x)))))
