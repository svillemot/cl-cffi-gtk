(in-package :gst)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (register-object-type "GstElement" 'gst-element))

(define-g-object-class "GstElement" gst-element
  (:superclass gst-object
   :export t
   :interfaces nil
   :type-initializer "gst_element_get_type")
  ())

(defcenum gst-state-change-return
  :failure
  :success
  :async
  :no-preroll)

(defcenum gst-state
  :void-pending
  :null
  :ready
  :paused
  :playing)

(defcfun ("gst_element_set_state" gst-element-set-state) gst-state-change-return
  (element (g-object gst-element))
  (state gst-state))

(export 'gst-element-set-state)
