#lang racket/base

(require racket/dict syntax/id-table racket/match
         mzlib/pconvert racket/syntax
         "../utils/utils.rkt"
         (rep type-rep filter-rep object-rep)
         (utils tc-utils)
         (env init-envs)
         (for-template 
          racket/base          
          (rep type-rep object-rep)
          (types utils union)
          (env init-envs)
          (utils tc-utils)))

(define struct-fn-table (make-free-id-table))
(define struct-constructor-table (make-free-id-table))

(define (add-struct-constructor! id) (dict-set! struct-constructor-table id #t))
(define (struct-constructor? id) (dict-ref struct-constructor-table id #f))

(define (add-struct-fn! id pe mut?) (dict-set! struct-fn-table id (list pe mut?)))

(define-values (struct-accessor? struct-mutator?)
  (let ()
    (define ((mk mut?) id)
      (cond [(dict-ref struct-fn-table id #f)
             => (match-lambda [(list pe m) (and (eq? m mut?) pe)] [_ #f])]
            [else #f]))
    (values (mk #f) (mk #t))))

(define (struct-fn-idx id)
  (match (dict-ref struct-fn-table id #f)
    [(list (StructPE: _ idx) _) idx]
    [_ (int-err (format "no struct fn table entry for ~a" (syntax->datum id)))]))

(define (make-struct-table-code)
  (parameterize ([current-print-convert-hook converter]
                 [show-sharing #f])
    (define/with-syntax (adds ...)      
      (for/list ([(k v) (in-dict struct-fn-table)]
                 #:when (bound-in-this-module k))
        (match v
          [(list pe mut?)
           #`(add-struct-fn! (quote-syntax #,k) #,(print-convert pe) #,mut?)])))
    #'(begin adds ...)))

(provide/cond-contract
 [add-struct-fn! (identifier? StructPE? boolean? . -> . any/c)]
 [add-struct-constructor! (identifier? . -> . any)]
 [struct-constructor? (identifier? . -> . boolean?)]
 [struct-accessor? (identifier? . -> . (or/c #f StructPE?))]
 [struct-mutator? (identifier? . -> . (or/c #f StructPE?))]
 [struct-fn-idx (identifier? . -> . exact-integer?)]
 [make-struct-table-code (-> syntax?)])