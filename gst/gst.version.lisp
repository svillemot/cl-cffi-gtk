(in-package :gst)

(defcfun ("gst_version_string" gst-version-string) (:string :free-from-foreign t))

(export 'gst-version-string)
