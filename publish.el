(require 'ox-publish)

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
         :base-directory "posts/img/"
         :base-extension "svg"
         :publishing-directory "public/img/"
         :recurse t
         :publishing-function org-publish-attachment)

        ("all" :components ("posts" "img"))))
