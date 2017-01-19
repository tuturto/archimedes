Hymn
====

.. code-block:: hy

   (assert-right (do-monad [status (advance-time-m society)]
                            status)
                 (assert-that society
                              (has-less-resources-than? old-resources)))
