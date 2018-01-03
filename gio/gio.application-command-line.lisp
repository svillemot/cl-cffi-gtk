(in-package :gio)

(defcfun ("g_application_command_line_get_arguments" g-application-command-line-get-arguments) (g-strv :free-from-foreign t)
  (cmdline :pointer)
  (argc :pointer))

(export 'g-application-command-line-get-arguments)
