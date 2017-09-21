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

(defcfun ("gst_element_get_state" %gst-element-get-state) gst-state-change-return
  (element (g-object gst-element))
  (state (:pointer gst-state))
  (pending (:pointer gst-state))
  (timeout :uint64))

(defun gst-element-get-state (element timeout)
  (with-foreign-objects ((state 'gst-state)
                         (pending 'gst-state))
    (let* ((return (%gst-element-get-state element state pending timeout))
           (available (not (eq return :async))))
      (values
       return
       (and available (mem-ref state 'gst-state))
       (and available (mem-ref pending 'gst-state))))))

(export 'gst-element-get-state)

(defcenum gst-format
  :undefined
  :default
  :bytes
  :time
  :buffers
  :percent)

(defconstant +gst-seek-flag-none+ (ash 0 0))
(defconstant +gst-seek-flag-flush+ (ash 1 0))
(defconstant +gst-seek-flag-accurate+ (ash 1 1))
(defconstant +gst-seek-flag-key-unit+ (ash 1 2))
(defconstant +gst-seek-flag-segment+ (ash 1 3))
(defconstant +gst-seek-flag-trickmode+ (ash 1 4))
(defconstant +gst-seek-flag-skip+ (ash 1 4))
(defconstant +gst-seek-flag-snap-before+ (ash 1 5))
(defconstant +gst-seek-flag-snap-after+ (ash 1 6))
(defconstant +gst-seek-flag-snap-nearest+ (logior +gst-seek-flag-snap-before+ +gst-seek-flag-snap-after+))
(defconstant +gst-seek-flag-trickmode-key-units+ (ash 1 7))
(defconstant +gst-seek-flag-trickmode-no-audio+ (ash 1 8))

(defcfun ("gst_element_seek_simple" gst-element-seek-simple) :boolean
  (element (g-object gst-element))
  (format gst-format)
  (seek-flags :int)
  (seek-pos :int64))

(export 'gst-element-seek-simple)

(defcfun ("gst_element_query_position" %gst-element-query-position) :boolean
  (element (g-object gst-element))
  (format gst-format)
  (cur (:pointer :int64)))

(defun gst-element-query-position (element format)
  (with-foreign-object (cur :int64)
    (when (%gst-element-query-position element format cur)
      (mem-ref cur :int64))))

(export 'gst-element-query-position)

(defcfun ("gst_element_query_duration" %gst-element-query-duration) :boolean
  (element (g-object gst-element))
  (format gst-format)
  (duration (:pointer :int64)))

(defun gst-element-query-duration (element format)
  (with-foreign-object (duration :int64)
    (when (%gst-element-query-duration element format duration)
      (mem-ref duration :int64))))

(export 'gst-element-query-duration)
