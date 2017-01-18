Hypothesis
==========
Hypothesis_ is a Python library for property based testing, similar to what
QuickCheck_ in Haskell_. Archimedes provides few parameters for ``fact`` and
``check`` macros that are used to instruct Hypothesis to generate test data.

.. note:: Some knowledge of Hypothesis is assumed for this section.

Three macros are provided for controlling Hypothesis: ``variants``, ``sample``
and ``profile``.

``variants`` macro controls test data generation. It maps into ``given``
decorator in Hypothesis. Body of ``variants`` consists of two or more items.
Every odd specifies variable name and element after that is strategy
specifying what kind of data to generate.

``sample`` maps to ``example`` decorator. It specifies concrete examples
for variables to check. Other than that, it works just like ``variants``
macro (variable, value).

``profile`` maps into ``settings`` decorator in Hypothesis. It is used to
tweak behaviour of Hypothesis for a specific test case.

Below is an example test case that showcases usage of all these elements.

.. code-block:: hy

   (require archimedes)
   (import [hypothesis.strategies [integers]])

   (fact "sum of two positive numbers is larger than either one of them"
      (variants :a (integers :min-size 1)
                :b (integers :min-size 1))
      (sample :a 0 :b 0)
      (profile :max-examples 500)
      (assert (> (+ a b) a))
      (assert (> (+ a b) b)))

This causes test case to be run at maximum of 500 times. There are two
parameters ``a`` and ``b``, which both are integers and have value of 1
or greater. There is also a specific test case for them being zero.

.. _Haskell: https://www.haskell.org/
.. _Hypothesis: https://hypothesis.readthedocs.io/en/latest/
.. _QuickCheck: https://hackage.haskell.org/package/QuickCheck
