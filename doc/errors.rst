Errors
======
Sometimes it's useful to verify that a certain exception is raised. This is
achieved with ``assert-error`` or ``assert-macro-error`` macro. Both take two
parameters: a string and piece of code. The code is executed and resulting
exception is compared with the provided string. In case of ``assert-error``
this comparison is done by simply calling ``str`` for exception. For
``assert-macro-error`` message attribute is used. If no exception is raised,
or raised exception doesn't match the provided string, assertion fails.

.. code-block:: hy

   (fact "errors can be asserted"
         (assert-error "error"
                       (raise (ValueError "error"))))

.. code-block:: hy

   (fact "macro errors can be asserted"
         (assert-macro-error "cond branches need to be a list"
                             (cond (= 1 1) true)))
