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

(require hy.contrib.anaphoric)

(defmacro background [context-name &rest code]
  (let [[symbols (ap-map (first it) code)]
        [fn-name (HySymbol (.join "" ["setup_" context-name]))]]
    `(defn ~fn-name []
       ~(.join "" ["setup context " context-name])
       (let [~@code]
         ~(dict-comp (keyword x) x [x symbols])))))

(defmacro fact [desc &rest code]
  (defn group [seq &optional [n 2]]
    "group list to lists of size n"
    (setv val [])
    (for [x seq]
      (.append val x)
      (when (>= (len val) n)
        (yield val)
        (setv val [])))
    (when val (yield val)))

  (defn variants []
    "get variants forms"
    (list-comp (rest branch) [branch code] (= 'variants (first branch))))

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
    (let [[fn-name (HySymbol (.join "" ["test_" (.replace (str desc) " " "_")]))]
          [param-list (if (variants)                        
                        (list (ap-map (HySymbol (name (first it))) (group (first (variants)))))
                        `[])]]
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
      `(with-decorator (settings ~@(first (profiles)))))
    res)

  (defn create-given-decorator [res]
    "create decorator for test data generators and splice in res"
    (if (variants)      
      `(with-decorator (given ~@(first (variants)))
         ~res)      
      res))

  (when (> (len (variants)) 1) (macro-error nil "too many variants forms"))
  (when (> (len (samples)) 1) (macro-error nil "too many samples forms"))
  (when (> (len (profiles)) 1) (macro-error nil "too many profile forms"))

  (-> code
      create-code-block
      create-func-definition
      create-sample-decorator
      create-settings-decorator
      create-given-decorator))

(defmacro/g! with-background [context-name symbols &rest code]    
  (let [[fn-name (HySymbol (.join "" ["setup_" context-name]))]]
    `(let [[~g!context (~fn-name)]
           ~@(ap-map `[~it (get ~g!context ~(keyword it))] symbols)]
       ~@code)))
