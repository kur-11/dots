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

(leaf whitespace
  :hook (before-save-hook . whitespace-cleanup)
  :custom
  (whitespace-space-regexp . "\\(\u3000+\\)")
  (whitespace-style . '(face trailing spaces empty space-mark tab-mark))
  (whitespace-display-mappings . '((space-mark ?\u3000 [?\u25a1])
                                   (tab-mark ?\t [?\u00bb ?\t] [?\\ ?\t])))
  (whitespace-action . '(auto-cleanup))
  :global-minor-mode global-whitespace-mode)
