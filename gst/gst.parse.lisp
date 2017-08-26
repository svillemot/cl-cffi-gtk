(in-package :gst)

(defcfun ("gst_parse_launch" %gst-parse-launch) (g-object gst-element)
  (pipeline-description :string)
  (error :pointer))

(defun gst-parse-launch (pipeline-description)
  (with-g-error (error)
    (%gst-parse-launch pipeline-description error)))

(export 'gst-parse-launch)
