(asdf:load-system '#:logv)
(asdf:load-system '#:osicat)

(osicat-posix:setenv "GST_DEBUG" "3")

(asdf:load-system '#:cl-cffi-gtk-gst)
(asdf:load-system '#:cl-cffi-gtk)

(defun gst-demo (uri)
  (let* (#+(or)(pipeline (gst:gst-parse-launch (format NIL "playbin uri=~A" uri)))
         #-(or)(pipeline (gst:gst-element-factory-make "playbin" (cffi:null-pointer)))
         #+(or)(bus (gst:gst-pipeline-get-bus pipeline))
         (loop (glib:g-main-loop-new (cffi:null-pointer) NIL)))
    (logv:logv (gobject:g-object-get-property pipeline "uri"))
    (progn
      (gobject:g-object-set-property pipeline "uri" (cffi:foreign-string-alloc uri))
      (logv:logv (gobject:g-object-get-property pipeline "uri"))
      #+(or)
      (gst:gst-bus-add-watch
       bus glib:+g-priority-default+
       (lambda (bus message)
         (logv:logv bus message)
         T))
      #+(or)
      (gobject:g-object-unref (gobject:pointer bus)))
    (gst:gst-element-set-state pipeline :playing)
    (unwind-protect
         (glib:g-main-loop-run loop)
      (gst:gst-element-set-state pipeline :null)
      (gobject:g-object-unref (gobject:pointer pipeline)))))

(defun gst-gtk-demo (uri)
  (gtk:within-main-loop
    (let* ((window (gtk:gtk-window-new :toplevel))
           (drawing-area (gtk:gtk-drawing-area-new))
           (pipeline (gst:gst-element-factory-make "playbin" (cffi:null-pointer)))
           (bus (gst:gst-pipeline-get-bus pipeline))
           handle)

      (gst:gst-bus-add-watch
       bus glib:+g-priority-default+
       (lambda (bus message)
         (declare (ignore bus))
         (logv:logv (cffi:foreign-slot-value message '(:struct gst::gst-message-cstruct) 'gst::type))
         T))
      (gobject:g-object-unref (gobject:pointer bus))

      (gobject:g-object-set-property pipeline "uri" (cffi:foreign-string-alloc uri))

      (gobject:g-signal-connect window "destroy"
                                (lambda (widget)
                                  (declare (ignore widget))

                                  (gst:gst-element-set-state pipeline :null)
                                  (gobject:g-object-unref (gobject:pointer pipeline))

                                  (gtk:leave-gtk-main)))
      (gobject:g-signal-connect drawing-area "realize"
                                (lambda (widget)
                                  (declare (ignore widget))
                                  (let ((window (logv:logv (gtk:gtk-widget-window drawing-area))))
                                    (logv:logv (gdk:gdk-window-ensure-native window))
                                    (setf handle (logv:logv (gdk:gdk-x11-window-get-xid window))))))
      (setf (gtk:gtk-widget-double-buffered drawing-area) NIL)
      (gtk:gtk-container-add window drawing-area)
      (gtk:gtk-widget-show-all window)
      (gtk:gtk-widget-realize drawing-area)

      (logv:logv handle)

      (gst:gst-bus-set-sync-handler bus (lambda (bus message)
                                          (declare (ignore bus))
                                          (cond
                                            ((not (gst:gst-is-video-overlay-prepare-window-handle-message message))
                                             :pass)
                                            (T
                                             (when (logv:logv handle)
                                               (let ((overlay (logv:logv (cffi:foreign-slot-value message '(:struct gst::gst-message-cstruct) 'gst::src))))
                                                 (gst:gst-video-overlay-set-window-handle overlay handle)))
                                             (gst:gst-mini-object-unref message)
                                             :drop))))
      (gobject:g-object-unref (gobject:pointer bus))
      (gst:gst-element-set-state pipeline :playing))))
