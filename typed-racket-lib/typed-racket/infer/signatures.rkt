#lang racket/base
(require "../utils/utils.rkt"
         racket/unit (contract-req)
         "../utils/unit-utils.rkt"
         "../rep/type-rep.rkt"
         "../rep/values-rep.rkt")

(require-for-cond-contract "constraint-structs.rkt")

(provide (all-defined-out))

(define-signature dmap^
  ([cond-contracted dmap-meet (dmap? dmap? . -> . (or/c #f dmap?))]))

(define-signature constraints^
  ([cond-contracted cset-meet ((cset? cset?) #:rest (listof cset?) . ->* . (or/c #f cset?))]
   [cond-contracted cset-meet* ((listof cset?) . -> . (or/c #f cset?))]
   [cond-contracted no-constraint c?]
   [cond-contracted empty-cset ((listof symbol?) (listof symbol?) . -> . cset?)]
   [cond-contracted insert (cset? symbol? Type? Type? . -> . cset?)]
   [cond-contracted cset-join ((listof cset?) . -> . cset?)]
   [cond-contracted c-meet ((c? c?) (symbol?) . ->* . (or/c #f c?))]))

(define-signature intersect^
  ([cond-contracted intersect ((Type? Type?) (OptObject?) . ->* . Type?)]
   [cond-contracted restrict  ((Type? Type?) (OptObject?) . ->* . Type?)]))

(define-signature infer^
  ([cond-contracted infer ((;; variables from the forall
                            (listof symbol?)
                            ;; indexes from the forall
                            (listof symbol?)
                            ;; actual argument types from call site
                            (listof Type?)
                            ;; domain
                            (listof Type?)
                            ;; range
                            (or/c #f Values/c AnyValues? ValuesDots?))
                           ;; optional expected type
                           ((or/c #f Values/c AnyValues? ValuesDots?)
                            ;; optional multiple substitutions?
                            #:multiple? boolean?
                            #:objs (listof OptObject?))
                           . ->* . any)]
   [cond-contracted infer/vararg ((;; variables from the forall
                                   (listof symbol?)
                                   ;; indexes from the forall
                                   (listof symbol?)
                                   ;; actual argument types from call site
                                   (listof Type?)
                                   ;; domain
                                   (listof Type?)
                                   ;; rest
                                   (or/c #f Type? Rest?)
                                   ;; range
                                   (or/c #f Values/c AnyValues? ValuesDots?))
                                  ;; [optional] expected type
                                  ((or/c #f Values/c AnyValues? ValuesDots?)
                                   #:objs (listof OptObject?))
                                  . ->* . any)]
   [cond-contracted infer/dots (((listof symbol?)
                                 symbol?
                                 (listof Values/c)
                                 (listof Values/c)
                                 Values/c
                                 (or/c Values/c ValuesDots?)
                                 (listof symbol?))
                                (#:expected (or/c #f Values/c AnyValues? ValuesDots?)
                                 #:objs (listof OptObject?))
                                . ->* . any)]))
