#lang racket

(require "grid.rkt")

; a blinker
(define blinker
  (grid-mass-update (empty-grid 5)
    '[(1 1 alive)
      (2 1 alive)
      (3 1 alive)]))

; a glider
(define glider
  (grid-mass-update (empty-grid 10)
    '[(1 2 alive)
      (2 3 alive)
      (3 1 alive)
      (3 2 alive)
      (3 3 alive)]))

; executes a single step of the Game of Life
(define (step grid)
  (map-cell (match-lambda [(list row column state)
    (let [(alive? (eq? state 'alive))
          (dead? (not (eq? state 'alive)))
          (num-living-neighbors (length (filter (λ (cell) (eq? (third cell) 'alive)) (neighbors grid row column))))]
      (cond
        [(and dead? (= 3 num-living-neighbors)) 'alive]
        [(and alive? (or (= 2 num-living-neighbors) (= 3 num-living-neighbors))) 'alive]
        [else 'dead]))]) grid))

(define current-glider glider)

(define (do-it)
  (set! current-glider (step current-glider))
  (print (grid->pict current-glider)))

(provide
  blinker
  step)
