;;;; A demo for GtkFrame
;;;;
;;;; This demo allows to change interactively the appearance of the frame.

(in-package #:gtk-demo)

(defun demo-frame ()
  (within-main-loop
    (let* (;; Create a toplevel window.
           (window (make-instance 'gtk-window
                                  :type :toplevel
                                  :title "Demo GtkFrame"
                                  :border-width 12))
           ;; A horizontal Box for the content of the window.
           (content (make-instance 'gtk-grid
                                   :orientation :horizontal
                                   :column-spacing 24))
           ;; A vertical Grid for the actions.
           (action (make-instance 'gtk-grid
                                  :orientation :vertical
                                  :row-spacing 6))
           ;; A Frame with a label.
           (frame (make-instance 'gtk-frame
                                 :label "Label"
                                 :label-xalign 0.1
                                 :width-request 200
                                 :height-request 200))
           ;; Store the Label Widget of the Frame.
           (label-widget (gtk-frame-get-label-widget frame))
           ;; The entry for input the text for the Frame Label
           (entry (make-instance 'gtk-entry
                                  :secondary-icon-stock "gtk-ok"
                                  :secondary-icon-tooltip-text
                                  "Change the Label of the Frame")))

      ;; Signal handler for the window to handle the signal "destroy".
      (g-signal-connect window "destroy"
                        (lambda (widget)
                          (declare (ignore widget))
                          (leave-gtk-main)))

      ;; Put some text into the Frame.
      (gtk-container-add frame (gtk-label-new "Test Frame"))

      ;; Set the Frame Label.
      (let () ; The entry is already defined
        (g-signal-connect entry "icon-press"
                          (lambda (entry icon-pos event)
                            (declare (ignore icon-pos event))
                            (gtk-frame-set-label frame
                                                 (gtk-entry-text entry))))
        (gtk-container-add action
                           (make-instance 'gtk-label
                                          :use-markup t
                                          :xalign 0.0
                                          :label
                                          "<b>Set Frame Label</b>"))
        ;; Put the actual Label text into the entry.
        (setf (gtk-entry-text entry) (gtk-frame-get-label frame))
        ;; Pack the entry in the action widget.
        (gtk-container-add action entry))

      ;; Set the Label alignment.
      (let ((hbox (make-instance 'gtk-grid
                                  :orientation :horizontal
                                  :column-homogenous t
                                  :column-spacing 6))
            (x-spin (make-instance 'gtk-spin-button
                                   :adjustment
                                   (make-instance 'gtk-adjustment
                                                  :value
                                                  (gtk-frame-label-xalign frame)
                                                  :lower 0.0
                                                  :upper 1.0
                                                  :step-increment 0.1
                                                  :page-increment 0.1
                                                  :page-size 0.0)
                                   :climb-rate 0
                                   :digits 2
                                   :wrap t))
            (y-spin (make-instance 'gtk-spin-button
                                   :adjustment
                                   (make-instance 'gtk-adjustment
                                                  :value
                                                  (gtk-frame-label-yalign frame)
                                                  :lower 0.0
                                                  :upper 1.0
                                                  :step-increment 0.1
                                                  :page-increment 0.1
                                                  :page-size 0.0)
                                   :climb-rate 0
                                   :digits 2
                                   :wrap t)))
        (g-signal-connect x-spin "value-changed"
           (lambda (spin)
             (multiple-value-bind (xalign yalign)
                 (gtk-frame-get-label-align frame)
               (declare (ignore xalign))
               (gtk-frame-set-label-align frame
                                          (gtk-spin-button-value spin)
                                          yalign))))
        (g-signal-connect y-spin "value-changed"
           (lambda (spin)
             (multiple-value-bind (xalign yalign)
                 (gtk-frame-get-label-align frame)
               (declare (ignore yalign))
               (gtk-frame-set-label-align frame
                                          xalign
                                          (gtk-spin-button-value spin)))))
        (gtk-container-add action
                           (make-instance 'gtk-label
                                          :use-markup t
                                          :xalign 0.0
                                          :margin-top 12
                                          :label
                                          "<b>Align Frame Label</b>"))
        (gtk-container-add hbox x-spin)
        (gtk-container-add hbox y-spin)
        (gtk-container-add action hbox))

      ;; Change the Shadow Type
      (let ((combo (make-instance 'gtk-combo-box-text)))
        (gtk-combo-box-text-append-text combo "NONE")
        (gtk-combo-box-text-append-text combo "IN")
        (gtk-combo-box-text-append-text combo "OUT")
        (gtk-combo-box-text-append-text combo "ETCHED-IN")
        (gtk-combo-box-text-append-text combo "ETCHED-OUT")
        (gtk-combo-box-set-active combo 3)
        (g-signal-connect combo "changed"
           (lambda (combobox)
             (let ((text (gtk-combo-box-text-get-active-text combobox)))
               (gtk-frame-set-shadow-type frame (intern text :keyword)))))

        (gtk-container-add action
                           (make-instance 'gtk-label
                                          :use-markup t
                                          :xalign 0.0
                                          :margin-top 12
                                          :label
                                          "<b>Shadow Type</b>"))
        (gtk-container-add action combo))

      ;; Set a Label Widget
      (let ((toggle (gtk-check-button-new-with-label "Show Stock Image")))
        (g-signal-connect toggle "toggled"
           (lambda (widget)
             (if (gtk-toggle-button-active widget)
                 (let ((image (gtk-image-new-from-icon-name
                               "gtk-home" :button)))
                   ;; Store the actual Label Widget.
                   (setf label-widget (gtk-frame-get-label-widget frame))
                   (setf (gtk-widget-sensitive entry) nil)
                   (gtk-frame-set-label-widget frame image)
                   (gtk-widget-show image))
                   ;; Restore the saved Label Widget.
                   (progn
                     (setf (gtk-widget-sensitive entry) t)
                     (gtk-frame-set-label-widget frame label-widget)))))
        (gtk-container-add action
                           (make-instance 'gtk-label
                                          :use-markup t
                                          :xalign 0.0
                                          :margin-top 12
                                          :label
                                          "<b>Change Label Widget</b>"))
        (gtk-container-add action toggle))

      ;; A Quit button
      (let ((button (make-instance 'gtk-button
                                   :label "Quit"
                                   :margin-top 12)))
        (g-signal-connect button "clicked"
           (lambda (widget)
             (declare (ignore widget))
             (gtk-widget-destroy window)))
        (gtk-container-add action button))

      ;; Add frame, content, and action to the window.
      (gtk-container-add content frame)
      (gtk-container-add content action)
      (gtk-container-add window content)
      ;; Show the window.
      (gtk-widget-show-all window))))

