(in-package :gst)

(define-g-interface "GstVideoOverlay" gst-video-overlay
  (:export t
   :type-initializer "gst_video_overlay_get_type"))

(defcfun ("gst_video_overlay_set_window_handle" gst-video-overlay-set-window-handle) :void
  (overlay (g-object gst-video-overlay))
  (handle :pointer))

(export 'gst-video-overlay-set-window-handle)
