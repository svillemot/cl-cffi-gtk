(in-package #:gtk)

(defun make-gtk-debugger-hook (&optional (parent (constantly NIL)))
  (lambda (condition hook)
    (let ((restarts (compute-restarts condition)))
      (let ((dialog (gtk-dialog-new-with-buttons
                     (format NIL "A ~A was signaled" (type-of condition))
                     (funcall parent condition) ;; TODO: either reimplement this thing to not use a dialog or track the "current" window to be transient for
                     '(:modal)
                     "gtk-ok"
                     :none)))
        (let ((restart (car restarts))
              (content (gtk-dialog-get-content-area dialog)))
          (gtk-box-pack-start content (make-instance 'gtk-label :label (format NIL "~A" condition) :xpad 12 :ypad 12))
          (cond
            (restarts
             (gtk-box-pack-start content (make-instance 'gtk-label :label "Choose a restart to invoke:" :xpad 12 :ypad 12 :xalign 0 :yalign 1))
             (let* ((model (make-instance 'gtk-list-store :column-types '("gchararray")))
                    (view (make-instance 'gtk-tree-view))
                    (scrolled (make-instance 'gtk-scrolled-window))
                    (renderer (make-instance 'gtk-cell-renderer-text))
                    (column (gtk-tree-view-column-new-with-attributes "Restart" renderer "text" 0)))
               (g-signal-connect
                (gtk-tree-view-get-selection view)
                "changed"
                (lambda (selection)
                  (let* ((selected (gtk-tree-selection-get-selected selection))
                         (path (and selected (gtk-tree-model-get-path model selected)))
                         (indices (and path (gtk-tree-path-get-indices path))))
                    (when indices
                      (setf restart (nth (car indices) restarts))))))
               (g-signal-connect
                view
                "row-activated"
                (lambda (view path column)
                  (declare (ignore view path column))
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
            (error "No restarts available!"))
          (let ((*debugger-hook* hook))
            (invoke-restart restart)))))))

(export 'make-gtk-debugger-hook)
