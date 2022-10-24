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

(module* main #f
  (let ((result-file (vector-ref (current-command-line-arguments) 0)))
    (flatten (map result-to-rows (parse-json-file result-file)))))
