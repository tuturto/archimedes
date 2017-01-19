Hamcrest
========

.. note:: Hamcrest is't installed by default

hamcrest_ is a framework for matcher objects. It's very useful for writing
expressive tests that are easy to read and report failures in user friendly
way. While hamcrest comes with pleothra of predefined matchers, part of the
power is extensibility of the framework. Developer can write custom matchers
for their specific problem domain.

There are two macros for defining matchers: ``defmatcher`` and 
``attribute-matcher``.

``defmatcher`` is used to define a generic matcher. Simple example below
shows how this is done:

.. code-block:: hy

   (defmatcher is-zero? []
               :match? (= item 0)
               :match! "a zero"
               :no-match! (.format "was a value of {0}" item))

   (assert-that 0 (is-zero?))

Parameters are: name of the matcher, input parameters, rule for matching, how
to report match and how to report mismatch. There is special variable ``item``
that corresponds to the item that the matcher is being run against.

In case where more general matcher is wanted, an input parameters can be used.
These will be available as properties of ``self`` in methods:

.. code-block:: hy

   (defmatcher in-between? [a b]
               :match? (< a item b)
               :match! (.format "value between {0} and {1}" self.a self.b)
               :no-match! (.format "was a value of {0}" item))

   (assert-that 5 (in-between? 2 7))

While ``defmatcher`` is powerful and can be used to define all kinds of
matchers, sometimes a simple one is needed. For these times 
``attribute-matcher`` is sufficient:

.. code-block:: hy

   (attribute-matcher item-with-length?
                      len =
                      "an item with length {0}"
                      "was an item with length {0}")

   (assert-that "foo" (is- (item-with-length? 3)))

Second parameter defines a function that is run for item being matched and
third parameter defines what kind of comparison should be performed. This
macro will always result to a matcher that takes a single parameter defining
some sort of value, which is then compared to result of the function. Handy
trick is to use dot notation to access object method:

.. code-block:: hy

   (attribute-matcher object-with-name?
                      .name =
                      "an object with name {0}"
                      "was an object with name {0}")

   (assert-that obj (is- (object-with-name? "foo")))

.. _hamcrest: https://pypi.python.org/pypi/PyHamcrest
