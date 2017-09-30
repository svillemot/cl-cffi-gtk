(in-package :gst)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (pushnew :gst *features*))

(glib::at-init ()
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (define-foreign-library gst
      (t "libgstreamer-1.0.so"))
    (define-foreign-library gst-base
      (t "libgstbase-1.0.so"))
    (define-foreign-library gst-video
      (t "libgstvideo-1.0.so")))
  (unless (foreign-library-loaded-p 'gst)
    (use-foreign-library gst))
  (unless (foreign-library-loaded-p 'gst-base)
    (use-foreign-library gst-base))
  (unless (foreign-library-loaded-p 'gst-video)
    (use-foreign-library gst-video)))

(defcfun ("gst_init_check" %gst-init-check) :boolean
  (argc (:pointer :int))
  (argv (:pointer (:pointer :string)))
  (err :pointer))

;; TODO: this should possibly have an option to pass arguments that will
;; influence GStreamer behaviour, but will require to defer the
;; initialisation call to after all of that is known
(defun %gst-init ()
  (let* ((binary #+ccl (car ccl:*command-line-argument-list*)
                 #+sbcl (car sb-ext:*posix-argv*)
                 ;; TODO: better fallback option, or error out
                 #-(or ccl sbcl) "/usr/bin/sbcl")
         (args `(,binary "--gst-disable-segtrap" "--gst-disable-registry-fork")))
    (with-g-error (err)
      (%gst-init-check
       (foreign-alloc :int :initial-element 3)
       (foreign-alloc :pointer :initial-element
                      (foreign-alloc :string :initial-contents args))
       err))))

(glib::at-init () (%gst-init))
