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

(import [hy [HySymbol]])

(require [hy.extra.anaphoric [*]])

(defmacro background [context-name &rest code]
  (let [symbols (ap-map (first it) (partition code))
        fn-name (HySymbol (.join "" ["setup_" context-name]))]
    `(defn ~fn-name []
       ~(.join "" ["setup context " context-name])
       (let [~@code]
         ~(dict-comp (keyword x) x [x symbols])))))

(defmacro fact [desc &rest code]

  (defn variants []
    "get variants forms"
    (list-comp (list (rest branch)) [branch code] (= 'variants (first branch))))

  (defn samples []
    "get samples forms"
    (list-comp (rest branch) [branch code] (= 'sample (first branch))))

  (defn profiles []
    "get profile forms"
    (list-comp (rest branch) [branch code] (= 'profile (first branch))))

  (defn create-code-block [code]
    "create test function body"
    `(do ~@(list (ap-filter (and (not (= 'variants (first it)))
                                 (not (= 'sample (first it)))
                                 (not (= 'profile (first it))))
                            code))))

  (defn create-func-definition [res]
    "create function header and splice in res"
    (let [fn-name (HySymbol (.join "" ["test_" (.replace (str desc) " " "_")]))
          param-list (if (variants)                        
                       (list (ap-map (HySymbol (name (first it))) 
                                     (list (partition (first (variants))))))
                       `[])]
      `(defn ~fn-name ~param-list
         ~desc         
         ~res)))

  (defn create-sample-decorator [res]
    "create decorator for sample data and splice in res"
    (if (samples)      
      `(with-decorator (example ~@(first (samples)))
         ~res)
      res))

  (defn create-settings-decorator [res]
    (if (profiles)
      `(with-decorator (settings ~@(first (profiles)))
         ~res)
      res))

  (defn create-given-decorator [res]
    "create decorator for test data generators and splice in res"
    (if (variants)      
      `(with-decorator (given ~@(first (variants)))
         ~res)      
      res))

  (defn create-importer [res]
    "create wrapping function to perform some imports"
    (if (variants)
      (let [fn-name (HySymbol (.join "" 
                                     ["test_" (.replace (str desc) " " "_")]))]
      `(defn ~fn-name []
         ~desc
         (import [hypothesis [given example settings]])
         ~res
         (~fn-name)))
      res))

  (when (> (len (variants)) 1) (macro-error None "too many variants forms"))
  (when (> (len (samples)) 1) (macro-error None "too many samples forms"))
  (when (> (len (profiles)) 1) (macro-error None "too many profile forms"))

  (-> code
      create-code-block
      create-func-definition
      create-sample-decorator
      create-settings-decorator
      create-given-decorator
      create-importer))

(defmacro check [fact-name &rest code]
          "define and execute a fact"
          `(try ((fact ~fact-name ~@code))
                (except [e Exception] 
                       (do (setv desc (str e))
                           (if (and (> (len desc) 0)
                                    (!= (first desc) "\n"))
                               (setv desc (+ "\n" desc)))
                           (print (+ "Failure: " ~fact-name desc))))
                (else (print (+ "Ok: " ~fact-name)))))

(defmacro defmatcher [matcher-name params &rest funcs]
  "define matcher class and function"

  (defn helper [match? match! no-match!]
    `(defn ~matcher-name ~params
       (import [hamcrest.core.base-matcher [BaseMatcher]])

       (defclass MatcherClass [BaseMatcher]
         [--init-- (fn [self ~@params]
                     ~@(genexpr `(setv (. self ~x) ~x) [x params]))
          -matches (fn [self item]
                     ~match?)
          describe-to (fn [self description]
                        (.append description ~match!))
          describe-mismatch (fn [self item mismatch-description]
                              (.append mismatch-description ~no-match!))])

       (MatcherClass ~@params)))

  (apply helper [] (dict-comp (if (= (first x) :match?) "is_match"
                                  (= (first x) :match!) "match!"
                                  (= (first x) :no-match!) "no_match!")
                              (second x)
                              [x (partition funcs)])))

(defmacro attribute-matcher [matcher-name func pred match no-match]
  `(defmatcher ~matcher-name [value]
     :match? (~pred (~func item) value)
     :match! (.format ~match (. self value))
     :no-match! (.format ~no-match (~func item))))

(defmacro/g! assert-macro-error [error-str code]
  `(let [~g!result (try
                    (do
                     (import [hy.errors [HyMacroExpansionError]])
                     (macroexpand (quote ~code))
                     "no exception raised")
                    (except [~g!e HyMacroExpansionError]
                      (if (= (. ~g!e message) ~error-str)
                        None
                        (.format "expected: '{0}'\n  got: '{1}'"
                                 ~error-str
                                 (. ~g!e message)))))]
     (when ~g!result
       (assert False ~g!result))))

(defmacro/g! assert-error [error-str code]
  "assert that an error is raised"
  `(let [~g!result (try 
                    (do ~code
                        "no exception raised")
                    (except [~g!e Exception]
                      (if (= (str ~g!e) ~error-str)
                        None
                        (.format "expected: '{0}'\n  got: '{1}'"
                                 ~error-str
                                 (str ~g!e)))))]     
     (when ~g!result
        (assert False ~g!result))))

(defmacro/g! assert-right [monad check]
  "helper macro for asserting Either.Right"
  `(either (fn [~g!fail]
             (assert False (str ~g!fail)))
           (fn [~g!ok]
             ~check)
           ~monad))

(defmacro/g! with-background [context-name symbols &rest code]    
  (let [fn-name (HySymbol (.join "" ["setup_" context-name]))]    
    `(let [~g!context (~fn-name)
           ~@(reduce (fn [acc item]
                       (+ acc [item `(get ~g!context ~(keyword item))]))
                     symbols
                     [])]
       ~@code)))
