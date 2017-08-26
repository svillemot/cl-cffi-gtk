(in-package :gst)

(define-g-boxed-cstruct gst-mini-object "GstMiniObject"
  (type g-type)
  (refcount :int)
  (lockstate :int)
  (flags :uint)
  (copy :pointer)
  (dispose :pointer)
  (free :pointer)
  (n-qdata :uint)
  (qdata :pointer))

(defcfun ("gst_mini_object_unref" gst-mini-object-unref) :void
  (mini-object :pointer))

(export 'gst-mini-object-unref)
