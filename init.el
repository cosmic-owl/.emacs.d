;; ==========================================
;; FORCE TRUE COLORS IN EMACS
;; ==========================================
(setq xterm-extra-capabilities '(getSelection setSelection))
(unless (display-graphic-p)
  (setq-default custom-enabled-themes '(solarized-dark))
  (setenv "COLORTERM" "truecolor"))

;; ==========================================
;; FONT SETUP & LIGATURES
;; ==========================================
(when (display-graphic-p)
  (set-face-attribute 'default nil :font "Fira Code" :height 120))

(use-package ligature
  :ensure t
  :config
  ;; Enable traditional programming ligatures in programming modes
  (ligature-set-ligatures 'prog-mode 
                          '("|||" "&&&" "===" "==" "=>" "->" "::" "::=" "==" "!=" "!==" 
                            "++" "+++" "<!--" "-->" "||" "&&" ">>=" "<<=" "->" "<-"))
  ;; Activate it globally across all supported buffers
  (global-ligature-mode t))

;; ==========================================
;; PACKAGE MANAGEMENT & EMACS SETUP
;; ==========================================
(require 'package)

;; Use MELPA and MELPA Stable to entirely avoid GNU server connection bugs
(setq package-archives '(("melpa"        . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))

;; Keep network handshakes loose to ensure smooth downloading
(setq package-check-signature nil)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; Activate local packages first using disk cache
(package-initialize)

(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t) ;; Forces use-package to install missing packages

;; ==========================================
;; THEME (Doom Bluloco Dark)
;; ==========================================
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-bluloco-dark t))

;; ==========================================
;; 1. PROJECTILE & INTERACTIVE SEARCH
;; ==========================================
(use-package projectile
  :init
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :config
  (setq projectile-project-search-path '("~/projects/" "~/Development/"))
  (setq projectile-project-search-depth 3)
  (setq projectile-completion-system 'ivy)

  ;; Build & Compilation Enhancements
  (setq projectile-use-git-grep t)                  ; Speeds up project-wide search
  (setq compilation-scroll-output 'first-error)     ; Auto-scrolls compilation logs to the first error
  (setq projectile-compilation-save-buffers t)      ; Auto-saves modified files before compiling
  (setq projectile-remember-window-configs t))      ; Remembers your window layouts across sessions

;; Counsel bridges Ivy with native project search engines
(use-package counsel
  :ensure t
  :after ivy
  :config
  (counsel-mode +1))

(use-package projectile-ripgrep
  :ensure t
  :after projectile)

;; ==========================================
;; 2. MAGIT (The Ultimate Git Interface)
;; ==========================================
(use-package magit
  :bind
  ("C-x g" . magit-status))

;; ==========================================
;; 2b. CUSTOM DEV DASHBOARD (Daemon-Optimized)
;; ==========================================
(use-package dashboard
  :ensure t
  :config
  ;; Welcome headings & aesthetics
  (setq dashboard-banner-logo-title "Welcome Back, Developer Workspace Active")
  (setq dashboard-footer-messages '("Happy Hacking! Code is poetry."))
  (setq dashboard-center-content t)
  (setq dashboard-show-shortcuts t)

  ;; Track workspaces using Projectile
  (setq dashboard-projects-backend 'projectile)

  ;; 1. DEFINE TERMINAL-SAFE CUSTOM LAB WIDGET WITH INTERACTIVE ANCHORS
  (defun dashboard-insert-container-labs (_)
    "Render your isolated development container shortcuts cleanly via terminal text buttons."
    (insert "\n== [ Container Development Labs ] ==\n\n")
    (insert "   ")
    (insert-button "[j] Java Lab"   'action (lambda (&rest _) (open-java-lab))   'follow-link t)
    (insert "     ")
    (insert-button "[c] C Lab"      'action (lambda (&rest _) (open-c-lab))      'follow-link t)
    (insert "     ")
    (insert-button "[+] C++ Lab"    'action (lambda (&rest _) (open-cpp-lab))    'follow-link t)
    (insert "     ")
    (insert-button "[y] Python Lab" 'action (lambda (&rest _) (open-python-lab)) 'follow-link t)
    (insert "     ")
    (insert-button "[n] Node Lab"   'action (lambda (&rest _) (open-node-lab))   'follow-link t)
    (insert "\n"))

  ;; 2. REGISTER THE LABS WIDGET INTO THE GENERATOR REGISTRY
  (setq dashboard-item-generators  
        '((labs     . dashboard-insert-container-labs)
          (recents  . dashboard-insert-recents)
          (projects . dashboard-insert-projects)))

  ;; 3. ARRANGE LAYOUT (Labs custom widget first, then standard lists)
  (setq dashboard-items '((labs     . t)
                          (recents  . 5)
                          (projects . 5)))

  ;; Avoid loading on headless background boot
  (unless (daemonp)
    (dashboard-setup-startup-hook))

  ;; 4. SAFE CLIENT FRAME CONNECTOR
  ;; Switches to the dashboard frame buffer cleanly the exact second a client attaches
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (with-current-buffer (get-buffer-create "*dashboard*")
                (unless (eq major-mode 'dashboard-mode)
                  (dashboard-mode))
                (switch-to-buffer "*dashboard*")
                (ignore-errors (dashboard-refresh-buffer))))))

;; ==========================================
;; 3. EDITORCONFIG (Consistency Across Stacks)
;; ==========================================
(use-package editorconfig
  :config
  (editorconfig-mode 1))

;; ==========================================
;; 4. TREE-SITTER (Modern Syntax Highlighting)
;; ==========================================
;; Maps standard programming modes to use their modern tree-sitter variants
;;  Temporarily disabled while debugging ABI issues
;;(use-package treesit-auto
;;  :ensure t
;;  :custom
;;  (treesit-auto-install 'prompt)
;;  :config
;;  (global-treesit-auto-mode))

(setq treesit-language-source-alist
      '((bash "https://github.com/tree-sitter/tree-sitter-bash" "v0.23.3")
        (c "https://github.com/tree-sitter/tree-sitter-c" "v0.23.0")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.22.0")
        (css "https://github.com/tree-sitter/tree-sitter-css" "v0.23.0")
        (html "https://github.com/tree-sitter/tree-sitter-html" "v0.23.0")
        (java "https://github.com/tree-sitter/tree-sitter-java" "v0.23.0")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "v0.23.0")
        (python "https://github.com/tree-sitter/tree-sitter-python" "v0.23.6")
        ;; TypeScript repo contains two separate grammars in subdirectories
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.0" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.0" "tsx/src")))

;; Optional: Automatically install them if they are missing
(dolist (lang '(bash c cpp css html java javascript python typescript tsx))
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

;; ==========================================
;; 5. LSP & DEVELOPMENT (Eglot & Performance)
;; ==========================================
(use-package eglot
  :ensure nil
  :hook
  ((c-ts-mode . eglot-ensure)
   (c++-ts-mode . eglot-ensure)
   (python-ts-mode . eglot-ensure)
   (js-ts-mode . eglot-ensure)
   (java-ts-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '(java-ts-mode . ("jdtls"))))

;; Tweak performance thresholds for smoother typing with LSP/Eglot
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq gc-cons-threshold 100000000)

;; Silence wrapper script variable warnings
(put 'lsp-clients-clangd-executable 'safe-local-variable #'stringp)
(put 'lsp-pylsp-plugins-executable 'safe-local-variable #'stringp)
(put 'lsp-clients-typescript-server-args 'safe-local-variable #'listp)
(put 'eglot-server-programs 'safe-local-variable #'listp)

;; ==========================================
;; 6. TRAMP & CONTAINERS (Distrobox Setup)
;; ==========================================
(with-eval-after-load 'tramp
  (add-to-list 'tramp-methods
               '("distrobox"
                 (tramp-login-program "distrobox")
                 (tramp-login-args (("enter") ("%h") ("--") ("/bin/sh")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-c")))))

;; ==========================================
;; 7. ORG MODE AGENDA
;; ==========================================
(setq org-agenda-files '("~/org/"))
(global-set-key (key-parse "C-c a") 'org-agenda)

;; ==========================================
;; 8. CODE FORMATTING & INDENTATION
;; ==========================================
(setq-default indent-tabs-mode nil) ; Default to spaces instead of tabs
(setq-default tab-width 4)          ; Default structural tab fallback

;; Language-Specific Indentation Offsets
(setq c-basic-offset 4)
(setq-default c-ts-mode-indent-offset 4)
(setq-default c++-ts-mode-indent-offset 4)
(setq-default java-ts-mode-indent-offset 4)
(setq-default python-ts-mode-indent-offset 4)

;; Front-End & Config Offsets (Strictly require 2 spaces for readability/validity)
(setq-default js-indent-level 2)
(setq-default css-ts-mode-indent-offset 2)
(setq-default html-ts-mode-indent-offset 2)
(setq-default yaml-ts-mode-indent-offset 2) ; YAML strictly outlaws literal tabs

;; Tab Behavior Logic Rule Protection
(setq-default tab-always-indent t)

;; Asynchronous Format-on-Save via Apheleia
(use-package apheleia
  :ensure t
  :init
  (apheleia-global-mode +1))

;; ==========================================
;; 9. CUSTOM INTERACTIVE FUNCTIONS & SERVER
;; ==========================================
(defun open-java-lab ()
  "Jump straight into the javalab Distrobox container workspace."
  (interactive)
  (dired "/podman:javalab:/home/gitoram/projects/java"))

(defun open-c-lab ()
  "Jump straight into the clab Distrobox container workspace for C."
  (interactive)
  (dired "/podman:clab:/home/gitoram/projects/c"))

(defun open-cpp-lab ()
  "Jump straight into the cpplab Distrobox container workspace for C++."
  (interactive)
  (dired "/podman:cpplab:/home/gitoram/projects/cpp"))

(defun open-python-lab ()
  "Jump straight into the pylab Distrobox container workspace for Python."
  (interactive)
  (dired "/podman:pythonlab:/home/gitoram/projects/python"))

(defun open-node-lab ()
  "Jump straight into the nodelab Distrobox container workspace for JS/TS/Express."
  (interactive)
  (dired "/podman:nodelab:/home/gitoram/projects/node"))

;; --- Global Keybindings ---
(global-set-key (kbd "C-c j") 'open-java-lab)   ; Java
(global-set-key (kbd "C-c c") 'open-c-lab)      ; C
(global-set-key (kbd "C-c C") 'open-cpp-lab)    ; C++ (Shift + C)
(global-set-key (kbd "C-c y") 'open-python-lab) ; Python
(global-set-key (kbd "C-c n") 'open-node-lab)   ; Node / TS / Express

;; Start Emacs background daemon server
(server-start)

;; ==========================================
;; CUSTOM GENERATED SETTINGS (Keep at bottom)
;; ==========================================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("9e5e0ff3a81344c9b1e6bfc9b3dcf9b96d5ec6a60d8de6d4c762ee9e2121dfb2"
     "a6920ee8b55c441ada9a19a44e9048be3bfb1338d06fc41bce3819ac22e4b5a1"
     "d481904809c509641a1a1f1b1eb80b94c58c210145effc2631c1a7f2e4a2fdf4"
     "3613617b9953c22fe46ef2b593a2e5bc79ef3cc88770602e7e569bbd71de113b"
     "42a6583a45e0f413e3197907aa5acca3293ef33b4d3b388f54fa44435a494739"
     "f6ea954a9544b0174a876d195387f444da441535ee88c7fb0fc346af08b0d228"
     "c07f072a88bed384e51833e09948a8ab7ca88ad0e8b5352334de6d80e502da8c"
     "fffef514346b2a43900e1c7ea2bc7d84cbdd4aa66c1b51946aade4b8d343b55a"
     "ff24d14f5f7d355f47d53fd016565ed128bf3af30eb7ce8cae307ee4fe7f3fd0"
     "df6dfd55673f40364b1970440f0b0cb8ba7149282cf415b81aaad2d98b0f0290"
     "4990532659bb6a285fee01ede3dfa1b1bdf302c5c3c8de9fad9b6bc63a9252f7"
     "f4d1b183465f2d29b7a2e9dbe87ccc20598e79738e5d29fc52ec8fb8c576fcfd"
     "6963de2ec3f8313bb95505f96bf0cf2025e7b07cefdb93e3d2e348720d401425"
     "dd4582661a1c6b865a33b89312c97a13a3885dc95992e2e5fc57456b4c545176"
     "02d422e5b99f54bd4516d4157060b874d14552fe613ea7047c4a5cfa1288cf4f"
     "c3c135e69890de6a85ebf791017d458d3deb3954f81dcb7ac8c430e1620bb0f1"
     "e1df746a4fa8ab920aafb96c39cd0ab0f1bac558eff34532f453bd32c687b9d6"
     "4b88b7ca61eb48bb22e2a4b589be66ba31ba805860db9ed51b4c484f3ef612a7"
     "a9eeab09d61fef94084a95f82557e147d9630fbbb82a837f971f83e66e21e5ad"
     "b7a09eb77a1e9b98cafba8ef1bd58871f91958538f6671b22976ea38c2580755"
     "f1e8339b04aef8f145dd4782d03499d9d716fdc0361319411ac2efc603249326"
     "8c7e832be864674c220f9a9361c851917a93f921fedb7717b1b5ece47690c098"
     "dfb1c8b5bfa040b042b4ef660d0aab48ef2e89ee719a1f24a4629a0c5ed769e8"
     "13096a9a6e75c7330c1bc500f30a8f4407bd618431c94aeab55c9855731a95e1"
     "7ec8fd456c0c117c99e3a3b16aaf09ed3fb91879f6601b1ea0eeaee9c6def5d9"
     "456697e914823ee45365b843c89fbc79191fdbaff471b29aad9dcbe0ee1d5641"
     "22a0d47fe2e6159e2f15449fcb90bbf2fe1940b185ff143995cc604ead1ea171"
     "9b9d7a851a8e26f294e778e02c8df25c8a3b15170e6f9fd6965ac5f2544ef2a9"
     "599f72b66933ea8ba6fce3ae9e5e0b4e00311c2cbf01a6f46ac789227803dd96"
     "2f7fa7a92119d9ed63703d12723937e8ba87b6f3876c33d237619ccbd60c96b9"
     "f253a920e076213277eb4cbbdf3ef2062e018016018a941df6931b995c6ff6f6"
     "3061706fa92759264751c64950df09b285e3a2d3a9db771e99bcbb2f9b470037"
     "9d5124bef86c2348d7d4774ca384ae7b6027ff7f6eb3c401378e298ce605f83a"
     "0c83e0b50946e39e237769ad368a08f2cd1c854ccbcd1a01d39fdce4d6f86478"
     "f64189544da6f16bab285747d04a92bd57c7e7813d8c24c30f382f087d460a33"
     "7771c8496c10162220af0ca7b7e61459cb42d18c35ce272a63461c0fc1336015"
     "b99ff6bfa13f0273ff8d0d0fd17cc44fab71dfdc293c7a8528280e690f084ef0"
     "7c3d62a64bafb2cc95cd2de70f7e4446de85e40098ad314ba2291fc07501b70c"
     "e4a702e262c3e3501dfe25091621fe12cd63c7845221687e36a79e17cf3a67e0"
     "77fff78cc13a2ff41ad0a8ba2f09e8efd3c7e16be20725606c095f9a19c24d3d"
     "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d"
     "d97ac0baa0b67be4f7523795621ea5096939a47e8b46378f79e78846e0e4ad3d"
     "21d2bf8d4d1df4859ff94422b5e41f6f2eeff14dd12f01428fa3cb4cb50ea0fb"
     "0f1341c0096825b1e5d8f2ed90996025a0d013a0978677956a9e61408fcd2c77"
     "5c7720c63b729140ed88cf35413f36c728ab7c70f8cd8422d9ee1cedeb618de5"
     "0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     "8d3ef5ff6273f2a552152c7febc40eabca26bae05bd12bc85062e2dc224cde9a"
     default))
 '(package-selected-packages
   '(apheleia counsel dashboard doom-themes ligature magit
              projectile-ripgrep)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
