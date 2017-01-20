Facts and checks
================
Basic building block is of course a test case. Archimedes follows nose
convention, where test function name starts with "test_", so they're easy
to collect and execute programmatically. To define a test case, ``fact``
macro is used:

.. code-block:: hy

   (fact "this is a test case"
     (assert (= 1 1)))

This will define a function, which is equivalent to:

.. code-block:: hy

   (defn test_this_is_a_test_case []
     "this is a test case"
     (assert (= 1 1)))

Nose (or any other test framework that follows the convention) can then
programmatically find this and execute it.

Sometimes one might want to execute test case immediately. This can be useful
when working in interactive mode, be it Hy repl or Jupyter_ notebook. For these
situations, there is ``check`` macro. It defines test case just like ``fact``
macro does and then executes it:

.. code-block:: hy

   (check "this is executed immediately"
     (assert (= 1 1)))

Both of these support specifying common setup code that can be shared between
several test cases. ``background`` macro specifies setup code with a unique
name and ``with-background`` takes one or more variables from that
specification in use. Since this probably sounds a bit confusing, an example
is in order:

.. code-block:: hy

   (background some-numbers
     a 3
     b 4
     c 5)

   (fact "sum of two numbers"
     (with-background some-numbers [a b]
       (assert (= (+ a b) 7))))

   (fact "product of three numbers"
     (with-background some-numbers [a b c]
       (assert (= (* a b c) 60))))     

Background can contain arbitrarily many variable definitions and they can be
more complex than simple values (calculations for example).

.. _Jupyter: http://jupyter.org/
