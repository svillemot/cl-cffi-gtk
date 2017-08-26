(defsystem :cl-cffi-gtk-gst
  :name :cl-cffi-gtk-gst
  :version "1.10.4"                     ; Version of the library
  :author "Olof-Joachim Frahm"
  :license "LLGPL"
  :description "A Lisp binding to GTK 3"
  :serial t
  :components
  ((:file "gst.package")
   (:file "gst.init")

   (:file "gst.version")
   (:file "gst.element")
   (:file "gst.bin")
   (:file "gst.object")
   (:file "gst.bus")
   (:file "gst.pipeline")

   (:file "gst.mini-object")
   (:file "gst.message")

   (:file "gst.factory")
   (:file "gst.video-overlay")

   (:file "gst.parse")
   )
  :depends-on (:cl-cffi-gtk-glib
               :cl-cffi-gtk-gobject
               :cffi
               :bordeaux-threads
               :alexandria
               :iterate
               :trivial-features))
