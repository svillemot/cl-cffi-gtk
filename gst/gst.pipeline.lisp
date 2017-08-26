(in-package :gst)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (register-object-type "GstPipeline" 'gst-pipeline))

(define-g-object-class "GstPipeline" gst-pipeline
  (:superclass gst-bin
   :export t
   :interfaces nil ;; TODO: GstChildProxy
   :type-initializer "gst_pipeline_get_type")
  ())

(defcfun ("gst_pipeline_get_bus" gst-pipeline-get-bus) (g-object gst-bus)
  (pipeline (g-object gst-pipeline)))

(export 'gst-pipeline-get-bus)
