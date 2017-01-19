Hymn
====

.. note:: hymn is not installed by default

hymn_ is a monad libary. While it's perfectly possible to test code that uses
monads without Archimedes, there is some patterns that keep repeating. Those
patterns (or rather one of them) has been collected in Archimedes.

In cases where code being tested produces ``Either`` there are generally
several different considerations to be made: is it ``left`` or ``right``? Does
it have correct value inside of it. ``assert-right`` captures pattern of the
first case. It first checks that code being executed produced ``right`` and
then proceeds to perform additional checks. If any of these fail, the assert
fails too.

.. code-block:: hy

   (assert-right (do-monad [status (advance-time-m society)]
                            status)
                 (assert-that society
                              (has-less-resources-than? old-resources)))

_hymn: http://hymn.readthedocs.io/en/latest/
