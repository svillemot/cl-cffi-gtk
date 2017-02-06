;;;; debugger
;;;;
;;;; The standard debugger can be hooked into to provide a nicer experience
;;;; when not having a separate listener open.
;;;;
;;;; So far only restarts not requiring additional values are supported by
;;;; selecting one of the options in the opened dialog.

(in-package #:gtk-demo)

(defun demo-debugger ()
  (let ((old-hook *debugger-hook*))
    (within-main-loop
      (let ((dialog (gtk-dialog-new-with-buttons "Demo Debugger"
                                                 *demo-window*
                                                 '(:modal)
                                                 "gtk-ok"
                                                 :none)))
        (g-signal-connect dialog "destroy"
                          (lambda (widget)
                            (declare (ignore widget))
                            (setf *debugger-hook* old-hook)
                            (leave-gtk-main)))
        (g-signal-connect dialog "response"
                          (lambda (dialog response-id)
                            (declare (ignore dialog))
                            (format T "Before error was signaled.~%")
                            (when (eql response-id (foreign-enum-value 'gtk-response-type :none))
                              (cerror "Continue." "This should invoke the debugger."))
                            (format T "After error was signaled.~%")))
        (gtk-widget-show-all dialog)
        (setf *debugger-hook* (make-gtk-debugger-hook (constantly dialog)))))))
