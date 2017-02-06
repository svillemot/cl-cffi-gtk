;;;; debugger
;;;;
;;;; The standard debugger can be hooked into to provide a nicer experience
;;;; when not having a separate listener open.
;;;;
;;;; So far only restarts not requiring additional values are supported by
;;;; selecting one of the options in the opened dialog.

(in-package #:gtk-demo)

(defun demo-debugger ()
  (within-main-loop
    (setf *debugger-hook* (lambda (condition hook)
                            (declare (ignore hook))
                            (let ((restarts (compute-restarts condition)))
                              (let ((dialog (gtk-dialog-new-with-buttons
                                             "Invoke Restart"
                                             NIL ;; TODO: either reimplement this thing to not use a dialog or track the "current" window to be transient for
                                             '(:modal)
                                             "gtk-ok"
                                             :none)))
                                (let ((restart (car restarts))
                                      (content (gtk-dialog-get-content-area dialog)))
                                  (cond
                                    (restarts
                                     (let* ((model (make-instance 'gtk-list-store :column-types '("gchararray")))
                                            (view (make-instance 'gtk-tree-view))
                                            (scrolled (make-instance 'gtk-scrolled-window))
                                            (renderer (make-instance 'gtk-cell-renderer-text))
                                            (column (gtk-tree-view-column-new-with-attributes "Restart" renderer "text" 0)))
                                       (g-signal-connect
                                        view
                                        "row-activated"
                                        (lambda (view path column)
                                          (declare (ignore view column))
                                          (setf restart (nth (car (gtk-tree-path-get-indices path)) restarts))
                                          (gtk-dialog-response dialog :none)))
                                       (loop
                                         for i from 0
                                         for restart in restarts
                                         do (gtk-list-store-set model (gtk-list-store-append model) (format NIL "~D: ~A" i restart)))
                                       (gtk-tree-view-set-model view model)
                                       (gtk-tree-view-append-column view column)
                                       (gtk-container-add scrolled view)
                                       (gtk-box-pack-start content scrolled)))
                                    (T
                                     (gtk-box-pack-start content (make-instance 'gtk-label :label "No restarts available!"))))
                                  (gtk-widget-show-all dialog)
                                  (unwind-protect (gtk-dialog-run dialog)
                                    (gtk-widget-destroy dialog))
                                  (unless restart
                                    (error "No restarts available?"))
                                  (invoke-restart restart))))))
    (let ((dialog (gtk-dialog-new-with-buttons "Demo Debugger"
                                               *demo-window*
                                               '(:modal)
                                               "gtk-ok"
                                               :none)))
      (g-signal-connect dialog "destroy"
                        (lambda (widget)
                          (declare (ignore widget))
                          (leave-gtk-main)))
      (g-signal-connect dialog "response"
                        (lambda (dialog response-id)
                          (declare (ignore dialog))
                          (format T "Before error was signaled.~%")
                          (when (eql response-id (foreign-enum-value 'gtk-response-type :none))
                            (cerror "Continue." "This should invoke the debugger."))
                          (format T "After error was signaled.~%")))
      (gtk-widget-show-all dialog))))
