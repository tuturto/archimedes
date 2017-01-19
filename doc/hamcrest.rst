Hamcrest
========

.. code-block:: hy

   (defmatcher is-zero? []
               :match? (= item 0)
               :match! "a zero"
               :no-match! (.format "was a value of {0}" item))

   (assert-that 0 (is-zero?))

   (attribute-matcher item-with-length?
                      len =
                      "an item with length {0}"
                      "was an item with length {0}")

   (assert-that "foo" (is- (item-with-length? 3)))

