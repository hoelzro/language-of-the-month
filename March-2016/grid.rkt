#lang racket

(require pict)

; creates an empty grid with a width of
; size and a height of size.
(define (empty-grid size)
  (let [(width size)
        (height size)]
    (make-list height
      (make-list width 'dead))))

; updates a cell in the grid to the given
; value, returning the new grid
(define (grid-update grid row column new-value)
  (list-set grid row
    (list-set (list-ref grid row) column new-value)))

; updates a grid with many values
(define (grid-mass-update grid updates)
  (foldl (match-lambda* [(list (list row column value) g) (grid-update g row column value)]) grid updates))

(define empty-pict (rectangle 0 0))

(define cell-size (make-parameter 10))

; renders the given grid as a pict
(define (grid->pict grid)
  (define (grid-cell->pict cell)
    (if (eq? cell 'alive)
      (filled-rectangle (cell-size) (cell-size))
      (rectangle (cell-size) (cell-size))))

  (define (grid-row->pict row)
    (foldr hc-append empty-pict (map grid-cell->pict row)))

  (foldr vc-append empty-pict
    (map grid-row->pict grid)))

(define (grid-ref grid row column)
  (list-ref (list-ref grid row) column))

(define-syntax-rule (define-pair (name a b) body)
  (define/match (name pair)
    [((list a b)) body]))

; returns a list of 3-element lists that
; indicate the row, column, and state of
; each of the given cell's neighbors
(define (neighbors grid row column)
  (define num-rows (length grid))
  (define num-cols (length (first grid)))

  (define-pair (wrap-coords row column)
    (list (modulo row num-rows)
          (modulo column num-cols)))

  (define-pair (apply-offset delta-r delta-c)
    (list (+ row delta-r) (+ column delta-c)))

  (define non-zero? (compose not zero?))

  (define-pair (not-zero-zero a b)
    (or (non-zero? a) (non-zero? b)))

  (define offsets (filter not-zero-zero (cartesian-product '(-1 0 1) '(-1 0 1))))
  (define neighbor-coords (map apply-offset offsets))

  (map (match-lambda [(list row column) (list row column (grid-ref grid row column))]) (map wrap-coords neighbor-coords)))

; XXX no builtin?
(define (map-indices fn lst)
  (map (λ (index) (fn index (list-ref lst index))) (range 0 (length lst))))

; runs a function fn, which takes a 3-element list
; (row column state) and returns a new state.  A
; new grid is built from the resulting states
(define (map-cell fn grid)
  (map-indices (λ (row-num row) (map-indices (λ (col-num state) (fn (list row-num col-num state))) row)) grid))

(provide
  empty-grid
  grid-ref
  grid-update
  grid-mass-update
  map-cell
  neighbors
  cell-size
  grid->pict)
