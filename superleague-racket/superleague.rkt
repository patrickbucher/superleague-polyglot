#lang racket

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
        (next (op init (first remainder)) (rest remainder))))
  (next init seq))

(define (add-to team-rows row)
  (let ((team (row-team row)))
    (define (combine-rows a b)
      (row team
           0
           (+ (row-wins a) (row-wins b))
           (+ (row-defeats a) (row-defeats b))
           (+ (row-ties a) (row-ties b))
           (+ (row-goals+ a) (row-goals+ b))
           (+ (row-goals- a) (row-goals- b))
           (+ (row-goals= a) (row-goals= b))
           (+ (row-points a) (row-points b))))
    (if (hash-has-key? team-rows team)
        (let ((existing (hash-ref team-rows team)))
          (hash-set team-rows team (combine-rows existing row)))
        (hash-set team-rows team row))))

(module* main #f
  (let ((result-file (vector-ref (current-command-line-arguments) 0)))
    (reduce add-to (hash) (flatten (map result-to-rows (parse-json-file result-file))))))
