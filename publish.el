;; ox-publish ships with emacs
(require 'ox-publish)

;; below taken from systemcrafters
;; https://systemcrafters.net/publishing-websites-with-org-mode/building-the-site/
;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)
(require 'htmlize)

(setq org-publish-project-alist
      '(("posts"
          :base-directory "posts/"
          :base-extension "org"
          :publishing-directory "public/"
          :recursive t
          :publishing-function org-html-publish-to-html
          :headline-levels 1
          :auto-sitemap t                ; Generate sitemap.org automagically...
          :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
          :sitemap-title "Sitemap"
          :author "Eric Neer"
          :with-creator t
          :htmlized-source t)

        ("img"
         :base-directory "posts/"
         :base-extension "svg"
         :publishing-directory "public/"
         :recursive t
         :publishing-function org-publish-attachment)

        ("all" :components ("posts" "img"))))
