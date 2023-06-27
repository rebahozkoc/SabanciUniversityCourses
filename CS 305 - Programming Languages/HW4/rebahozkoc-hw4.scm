(define n-length-list 
    (lambda (lst count)
        (if (> count 0)
            (cons (car lst) (n-length-list (cdr lst) (- count 1)))
            '()
        )
    )
)

(define sub-list
    (lambda (lst start count)
        (cond 
            ((not (list? lst)) (error "ERROR305: sub-list only operates on lists lst is not a list"))
            ((> start count) (error "ERROR305: Start index cannot be bigger than end index"))
            ;((and (= start 0) (= end (- (length lst) 1)) ))
            ((> start 0) (sub-list (cdr lst) (- start 1) count))
            (else (n-length-list lst count))
        )
    )
)

(define merge
    (lambda (a b comp)
        (cond 
            ((null? a) b)
            ((null? b) a)
            ((comp (car a) (car b)) (cons (car a) (merge (cdr a) b comp)))
            (else (cons (car b) (merge a (cdr b) comp)))
        )
    )
)

(define merge-sort ;comp is a predicate function which takes two parameters
    (lambda (lst comp)
        (if (< (length lst) 2)
            lst
            (merge 
                (merge-sort (sub-list lst 0 (quotient (length lst) 2)) comp)
                (merge-sort (sub-list lst (quotient (length lst) 2) (- (length lst) (quotient (length lst) 2))) comp)
                comp
            )
        )
    )
)

(define my-apply ; returns a list of func(elem1) func(elem2)...
    (lambda (lst func)
        (if (null? lst)
            '()
            (cons (func (car lst)) (my-apply (cdr lst) func))
        )
    )
)

(define my-filter ; returns a list of elements if pred(elem) true
    (lambda (lst pred)
        (cond 
            ((null? lst) '())
            ((pred (car lst)) (cons (car lst) (my-filter (cdr lst) pred)))
            (else (my-filter (cdr lst) pred))
        )
    )
)

(define my-and-list  ; takes a list of boolean variables and returns true if all of them are true
    (lambda (lst)
        (cond 
            ((< (length lst) 1) (< (length lst) 1))
            ((= (length lst) 1) (car lst))
            (else (and (car lst) (my-and-list (cdr lst))))
        )
    )
)

(define check-length?
    (lambda (inTriple count)
        (if (null? inTriple)
            (= count 0)
            (check-length? (cdr inTriple) (- count 1))
        )
    )
)

(define triple?
    (lambda (lst)
        (and (check-length? lst 3) (my-and-list (my-apply lst integer?)))
    )
)

(define check-triple?
    (lambda (tripleList)
        (my-and-list (my-apply tripleList (lambda (x) (triple? x))))
    )
)


(define check-sides?
    (lambda (inTriple)
        (and 
            (my-and-list (my-apply inTriple integer?))
            (my-and-list (my-apply inTriple (lambda (x) (> x 0))))
        )
    )
)

(define sort-triple 
    (lambda (inTriple)
        (merge-sort inTriple (lambda (x y) (< x y)))
    )
)

(define sort-all-triples
    (lambda (tripleList)
        (my-apply tripleList sort-triple)
    )
)

(define triangle?
    (lambda (triple)
        (if (check-sides? triple)
            (and 
                (> (+ (car triple) (cadr triple)) (caddr triple))
                (and 
                    (> (+ (car triple) (caddr triple)) (cadr triple))
                    (> (+ (cadr triple) (caddr triple)) (car triple))
                )
            )
            #f
        )
    )
)

(define filter-triangle
    (lambda (tripleList)
        (my-filter tripleList triangle?)
    )
)

(define pythagorean-triangle?
    (lambda (triple)
        (= 
            (+ (* (car triple) (car triple)) (* (cadr triple) (cadr triple)))  ;a^2 + b^2 
            (* (caddr triple) (caddr triple)) ; c^2
        )
    )
)

(define filter-pythagorean
    (lambda (tripleList)
        (my-filter tripleList pythagorean-triangle?)
    )
)

(define get-area 
    (lambda (triple) 
        ( / ( * (car triple) (cadr triple)) 2 )
    )
)

(define sort-area 
    (lambda (tripleList)
        (merge-sort tripleList (lambda (x y) (< (get-area x) (get-area y))))
    )
)

(define main-procedure
    (lambda (tripleList)
        (if (or (null? tripleList) (not (list? tripleList)))
            (error "ERROR305: the input should be a list full of triples")
            (if (check-triple? tripleList)
                (sort-area (filter-pythagorean (filter-triangle
                (sort-all-triples tripleList))))
                (error "ERROR305: the input should be a list full of triples")
            )
        )
    )
)