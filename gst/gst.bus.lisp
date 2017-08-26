(in-package :gst)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (register-object-type "GstBus" 'gst-bus))

(define-g-object-class "GstBus" gst-bus
  (:superclass gst-object
   :export t
   :interfaces nil
   :type-initializer "gst_bus_get_type")
  ())

(defcenum gst-bus-sync-reply
  :drop
  :pass
  :async)

(defcallback gst-bus-sync-handler-cb gst-bus-sync-reply
    ((bus (g-object gst-bus))
     ;; (message (g-object gst-message))
     (message :pointer)
     (user-data :pointer))
  (let ((fn (glib:get-stable-pointer-value user-data)))
    (restart-case
        (funcall fn bus message)
      (return-from-gst-bus-sync-handler-cb () :async))))

(defcfun ("gst_bus_set_sync_handler" %gst-bus-set-sync-handler) :void
  (bus (g-object gst-bus))
  (func :pointer)
  (user-data :pointer)
  (notify :pointer))

(defun gst-bus-set-sync-handler (bus func)
  (%gst-bus-set-sync-handler
   bus
   (callback gst-bus-sync-handler-cb)
   (glib:allocate-stable-pointer func)
   (callback glib:stable-pointer-destroy-notify-cb)))

(export 'gst-bus-set-sync-handler)

(defcallback gst-bus-func-cb :boolean
    ((bus (g-object gst-bus))
     ;; (message (g-object gst-message))
     (message :pointer)
     (user-data :pointer))
  (let ((fn (glib:get-stable-pointer-value user-data)))
    (restart-case
        (funcall fn bus message)
      (return-from-gst-bus-func-cb () NIL))))

(defcfun ("gst_bus_add_watch_full" %gst-bus-add-watch-full) :uint
  (bus (g-object gst-bus))
  (priority :int)
  (func :pointer)
  (user-data :pointer)
  (notify :pointer))

(defun gst-bus-add-watch (bus priority func)
  (%gst-bus-add-watch-full
   bus
   priority
   (callback gst-bus-func-cb)
   (glib:allocate-stable-pointer func)
   (callback glib:stable-pointer-destroy-notify-cb)))

(export 'gst-bus-add-watch)
