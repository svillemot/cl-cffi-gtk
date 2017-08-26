(in-package :gst)

(defcfun ("gst_element_factory_make" gst-element-factory-make) (g-object gst-element)
  (factoryname :string)
  (name :string))

(export 'gst-element-factory-make)
