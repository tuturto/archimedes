;; -*- coding: utf-8 -*-
;;
;; Copyright (c) 2016 Tuukka Turto
;; 
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;; 
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;; 
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.

(require archimedes)

(import [hypothesis [given example]]
        [hypothesis.strategies [integers]])

(fact "simple facts can be specified"
      (assert true))

(fact "facts with variants can be specified"
      (variants :a (integers :min-value 1))
      (assert (>= a 1)))

(fact "facts with sample data can be specified"
      (variants :a (integers :min-value 1))
      (sample :a 5)
      (assert (>= a 1)))

(fact "profile controls some of the test settings"
      (variants :a (integers :min-value 10))
      (profile :max-examples 10)
      (assert (>= a 10)))

(fact "facts with multiple variants can be specified"
      (variants :a (integers :min-value 1)
                :b (integers :min-value 1))
      (assert (>= (+ a b) 2)))

(fact "facts with multiple variants and sample can be specified"
      (variants :a (integers :min-value 1)
                :b (integers :min-value 1))
      (sample :a 5 :b 5)
      (assert (>= (+ a b) 2)))

(background some-numbers
            [a 10]
            [b 20])

(fact "background can be defined and used"
      (with-background some-numbers [a b]
        (assert (= (+ a b) 30))))

(fact "background can be used with variants"
      (variants :c (integers :min-value 30))
      (with-background some-numbers [a b]
        (assert (>= (+ a b c) 60))))
