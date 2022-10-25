#lang racket

(require racket/format)
(require json)

(define (parse-json-file path)
  (let ((f (open-input-file path)))
    (read-json f)))

(struct row (team rank wins defeats ties goals+ goals- goals= points))

(define (result-to-rows result)
  (let ((hg (hash-ref result 'homeGoals))
        (ag (hash-ref result 'awayGoals))
        (ht (hash-ref result 'homeTeam))
        (at (hash-ref result 'awayTeam)))
    (cond ((> hg ag)
           (list
            (row ht 0 1 0 0 hg ag (- hg ag) 3)
            (row at 0 0 1 0 ag hg (- ag hg) 0)))
          ((< hg ag)
           (list
            (row ht 0 0 1 0 hg ag (- hg ag) 0)
            (row at 0 1 0 0 ag hg (- ag hg) 3)))
          (else
           (list
            (row ht 0 0 0 1 hg ag (- hg ag) 1)
            (row at 0 0 0 1 ag hg (- ag hg) 1))))))

(define (accumulate op init seq)
  (if (null? seq)
      init
      (op (first seq)
          (accumulate op init (rest seq)))))

(define (flatten seq)
  (accumulate append '() seq))

(define (reduce op init seq)
  (define (next acc remainder)
    (if (null? remainder)
        acc
        (next (op acc (first remainder)) (rest remainder))))
  (next init seq))

(define (combine-rows a b)
  (row (row-team a)
       0
       (+ (row-wins a) (row-wins b))
       (+ (row-defeats a) (row-defeats b))
       (+ (row-ties a) (row-ties b))
       (+ (row-goals+ a) (row-goals+ b))
       (+ (row-goals- a) (row-goals- b))
       (+ (row-goals= a) (row-goals= b))
       (+ (row-points a) (row-points b))))

(define (add-to team-rows row)
  (let ((team (row-team row)))
    (if (hash-has-key? team-rows team)
        (let ((existing (hash-ref team-rows team)))
          (hash-set team-rows team (combine-rows existing row)))
        (hash-set team-rows team row))))

(define (ordered rows)
  (vector-sort
   (vector-sort
    (vector-sort
     (vector-sort
      (list->vector rows)
      string<? #:key row-team)
     > #:key row-goals=)
    > #:key row-wins)
   > #:key row-points))

(define (enumerate rows)
  (define (ranked olds news i)
    (if (null? olds)
        news
        (ranked (rest olds)
                (append news
                        (list (struct-copy row (first olds) [rank i])))
                (+ i 1))))
  (ranked rows '() 1))

(define (print-row r)
  (define (out v w)
    (~a v #:align 'right #:width w))
  (display
   (string-append
    (out (row-team r) 30)
    (out (row-rank r) 3)
    (out (row-wins r) 3)
    (out (row-ties r) 3)
    (out (row-defeats r) 3)
    (out (row-goals+ r) 4)
    (out (row-goals- r) 4)
    (out (row-goals= r) 4)
    (out (row-points r) 4)
    "\n")))

(define (print-rows rs)
  (when (not (null? rs))
    (begin
      (print-row (first rs))
      (print-rows (rest rs)))))

(define (print-table rows)
  (begin
    (display "                          Team  #  W  D  L   +   -   =   P\n")
    (display "----------------------------------------------------------\n")
    (print-rows rows)))

(module* main #f
  (let ((result-file (vector-ref (current-command-line-arguments) 0)))
    (print-table
     (enumerate
      (vector->list
       (ordered
        (hash-values
         (reduce add-to
                 (hash)
                 (flatten (map result-to-rows (parse-json-file result-file)))))))))))
