(in-package :gst)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (register-object-type "GstBin" 'gst-bin))

(define-g-object-class "GstBin" gst-bin
  (:superclass gst-element
   :export t
   :interfaces nil ;; TODO: GstChildProxy
   :type-initializer "gst_bin_get_type")
  ())
