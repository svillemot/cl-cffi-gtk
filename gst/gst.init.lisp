(in-package :gst)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (pushnew :gst *features*))

(glib::at-init ()
  (eval-when (:compile-toplevel :load-toplevel :execute)
    (define-foreign-library gst
      (t "libgstreamer-1.0.so.0"))
    (define-foreign-library gst-base
      (t "libgstbase-1.0.so.0"))
    (define-foreign-library gst-video
      (t "libgstvideo-1.0.so.0")))
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

(defun %gst-init ()
  (with-g-error (err)
    (%gst-init-check (foreign-alloc :int :initial-element 0)
                     (foreign-alloc :string :initial-contents '("/usr/bin/sbcl"))
                     err)))

(glib::at-init () (%gst-init))
