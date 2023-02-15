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

;; Install use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; Install other dependencies
(use-package htmlize
  :ensure t)

;; Load the publishing system
(require 'ox-publish)

(setq ejneer/site-url "https://www.ejneer.com")
(setq ejneer/site-title   "Eric Neer")
(setq ejneer/site-tagline "")

;;(setq org-publish-use-timestamps-flag t
;;      org-publish-timestamp-directory "./.org-cache/"
;;      org-export-with-section-numbers nil
;;      org-export-use-babel nil
;;      org-export-with-smart-quotes t
;;      org-export-with-sub-superscripts nil
;;      org-export-with-tags 'not-in-toc
;;      org-export-with-toc t)
;;
(setq make-backup-files nil)


(defun ejneer/site-header (info)
  (shr-dom-to-xml
   `(nav ((class . "nav-menu navbar"))
     (a ((href . "/")) "Home"))))

(defun ejneer/site-footer (info)
  (shr-dom-to-xml
   `(div ((class . "footer"))
     (p () "Made with " ,(plist-get info :creator)))))

(defun ejneer/site-head ()
  (shr-dom-to-xml
   `(head ()
     (meta ((charset . "utf-8")
            (author . "Eric Neer")
            (name . "viewport")
            (content . "width=device-width, initial-scale=1")))
     (title () ,(concat (org-export-data (plist-get info :title) info)) " - Eric Neer")
     (link ((href . "/static/styles.css")
            (rel . "stylesheet")))
     (link ((href . "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.3.0/css/all.min.css")
           (rel . "stylesheet"))))))

(defun ejneer/site-sidebar (info)
  (shr-dom-to-xml
   `(div ((class . "sidebar"))
     (div ((class . "header"))
          (a ((href . "/"))
             (img ((src . "/static/pic.jpeg")
                   (width . "150")
                   (style . "border-radius: 50%;"))))
          (p ((class . "lead"))
             "Data Scientist & Engineer")
          ,(ejneer/site-sidebar-nav-link "fab fa-github" "https://github.com/ejneer" "GitHub")
          ,(ejneer/site-sidebar-nav-link "fab fa-linkedin" "https://www.linkedin.com/in/eric-neer/" "LinkedIn")
          ,(ejneer/site-footer info)))))


(defun ejneer/site-sidebar-nav-link (icon link text)
  (shr-dom-to-xml
   `(div ((class . "sidebar-nav-item"))
     (i ((class . ,icon)))
     (a ((href . ,link)) ,text))))

(defun ejneer/site-body (contents info)
  (shr-dom-to-xml
   `(body ()
     (div ()
          ,(ejneer/site-sidebar info)
          (div ((class . "content"))
               ,contents)))))

(defun ejneer/org-html-template (contents info)
  (concat
   "<!DOCTYPE html>"
   (shr-dom-to-xml
    `(html ((lang . "en"))
      ,(ejneer/site-head)
      ,(ejneer/site-body contents info)))))

(org-export-define-derived-backend 'ejneer-html
    'html
  :translate-alist '((template . ejneer/org-html-template)))

(defun ejneer/org-html-publish-to-html (plist filename pub-dir)
  (org-publish-org-to 'ejneer-html
                      filename
                      (concat "." (or (plist-get plist :html-extension)
                                      "html"))
                      plist
                      pub-dir))

(setq org-publish-project-alist
      (list
       (list "ejneer:main"
             :recursive t
             :base-directory (expand-file-name "posts/")
             :publishing-function 'ejneer/org-html-publish-to-html
             :publishing-directory (expand-file-name "public/")
             :with-author nil
             :with-creator nil
             :with-toc nil
             :section-numbers nil
             :time-stamp-file nil)

       (list "ejneer:static"
             :recursive t
             :base-directory (expand-file-name "posts/")
             :publishing-directory (expand-file-name "public/")
             :publishing-function 'org-publish-attachment
             :base-extension "\\(gif\\|svg\\|css\\|jpeg\\)")

       (list "ejneer:all"
             :components '("ejneer:main" "ejneer:static"))))

(defun ejneer/publish ()
  (interactive)
  (org-publish-all t))
