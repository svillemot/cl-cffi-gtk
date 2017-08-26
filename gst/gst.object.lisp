(in-package :gst)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (register-object-type "GstObject" 'gst-object))

(define-g-object-class "GstObject" gst-object
  (:superclass g-initially-unowned
   :export t
   :interfaces nil
   :type-initializer "gst_object_get_type")
  ())
