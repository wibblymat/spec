;; Test `set_local` operator

(module
  ;; Typing

  (func "type-local-i32" (local i32) (result i32) (set_local 0 (i32.const 0)))
  (func "type-local-i64" (local i64) (result i64) (set_local 0 (i64.const 0)))
  (func "type-local-f32" (local f32) (result f32) (set_local 0 (f32.const 0)))
  (func "type-local-f64" (local f64) (result f64) (set_local 0 (f64.const 0)))

  (func "type-param-i32" (param i32) (result i32) (set_local 0 (i32.const 10)))
  (func "type-param-i64" (param i64) (result i64) (set_local 0 (i64.const 11)))
  (func "type-param-f32" (param f32) (result f32) (set_local 0 (f32.const 11.1)))
  (func "type-param-f64" (param f64) (result f64) (set_local 0 (f64.const 12.2)))

  (func "type-mixed" (param i64 f32 f64 i32 i32) (local f32 i64 i64 f64)
    (i64.eqz (set_local 0 (i64.const 0)))
    (f32.neg (set_local 1 (f32.const 0)))
    (f64.neg (set_local 2 (f64.const 0)))
    (i32.eqz (set_local 3 (i32.const 0)))
    (i32.eqz (set_local 4 (i32.const 0)))
    (f32.neg (set_local 5 (f32.const 0)))
    (i64.eqz (set_local 6 (i64.const 0)))
    (i64.eqz (set_local 7 (i64.const 0)))
    (f64.neg (set_local 8 (f64.const 0)))
  )

  ;; Writing

  (func "write" (param i64 f32 f64 i32 i32) (local f32 i64 i64 f64) (result i64)
    (set_local 1 (f32.const -0.3))
    (set_local 3 (i32.const 40))
    (set_local 4 (i32.const -7))
    (set_local 5 (f32.const 5.5))
    (set_local 6 (i64.const 6))
    (set_local 8 (f64.const 8))
    (i64.trunc_s/f64
      (f64.add
        (f64.convert_u/i64 (get_local 0))
        (f64.add
          (f64.promote/f32 (get_local 1))
          (f64.add
            (get_local 2)
            (f64.add
              (f64.convert_u/i32 (get_local 3))
              (f64.add
                (f64.convert_s/i32 (get_local 4))
                (f64.add
                  (f64.promote/f32 (get_local 5))
                  (f64.add
                    (f64.convert_u/i64 (get_local 6))
                    (f64.add
                      (f64.convert_u/i64 (get_local 7))
                      (get_local 8)
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )

  ;; Result

  (func "result" (param i64 f32 f64 i32 i32) (local f32 i64 i64 f64) (result f64)
    (f64.add
      (f64.convert_u/i64 (set_local 0 (i64.const 1)))
      (f64.add
        (f64.promote/f32 (set_local 1 (f32.const 2)))
        (f64.add
          (set_local 2 (f64.const 3.3))
          (f64.add
            (f64.convert_u/i32 (set_local 3 (i32.const 4)))
            (f64.add
              (f64.convert_s/i32 (set_local 4 (i32.const 5)))
              (f64.add
                (f64.promote/f32 (set_local 5 (f32.const 5.5)))
                (f64.add
                  (f64.convert_u/i64 (set_local 6 (i64.const 6)))
                  (f64.add
                    (f64.convert_u/i64 (set_local 7 (i64.const 0)))
                    (set_local 8 (f64.const 8))
                  )
                )
              )
            )
          )
        )
      )
    )
  )
)

(assert_return (invoke "type-local-i32") (i32.const 0))
(assert_return (invoke "type-local-i64") (i64.const 0))
(assert_return (invoke "type-local-f32") (f32.const 0))
(assert_return (invoke "type-local-f64") (f64.const 0))

(assert_return (invoke "type-param-i32" (i32.const 2)) (i32.const 10))
(assert_return (invoke "type-param-i64" (i64.const 3)) (i64.const 11))
(assert_return (invoke "type-param-f32" (f32.const 4.4)) (f32.const 11.1))
(assert_return (invoke "type-param-f64" (f64.const 5.5)) (f64.const 12.2))

(assert_return
  (invoke "type-mixed"
    (i64.const 1) (f32.const 2.2) (f64.const 3.3) (i32.const 4) (i32.const 5)
  )
)

(assert_return
  (invoke "write"
    (i64.const 1) (f32.const 2) (f64.const 3.3) (i32.const 4) (i32.const 5)
  )
  (i64.const 56)
)

(assert_return
  (invoke "result"
    (i64.const -1) (f32.const -2) (f64.const -3.3) (i32.const -4) (i32.const -5)
  )
  (f64.const 34.8)
)


;; Invalid typing of access to locals

(assert_invalid
  (module (func $type-local-num-vs-num (local i32) (result i64) (set_local 0 (i32.const 0))))
  "type mismatch"
)
(assert_invalid
  (module (func $type-local-num-vs-num (local f32) (i32.eqz (set_local 0 (f32.const 0)))))
  "type mismatch"
)
(assert_invalid
  (module (func $type-local-num-vs-num (local f64 i64) (f64.neg (set_local 1 (i64.const 0)))))
  "type mismatch"
)

(assert_invalid
  (module (func $type-local-arg-num-vs-num (local i32) (set_local 0 (f32.const 0))))
  "type mismatch"
)
(assert_invalid
  (module (func $type-local-arg-num-vs-num (local f32) (set_local 0 (f64.const 0))))
  "type mismatch"
)
(assert_invalid
  (module (func $type-local-arg-num-vs-num (local f64 i64) (set_local 1 (f64.const 0))))
  "type mismatch"
)


;; Invalid typing of access to parameters

(assert_invalid
  (module (func $type-param-num-vs-num (param i32) (result i64) (get_local 0)))
  "type mismatch"
)
(assert_invalid
  (module (func $type-param-num-vs-num (param f32) (i32.eqz (get_local 0))))
  "type mismatch"
)
(assert_invalid
  (module (func $type-param-num-vs-num (param f64 i64) (f64.neg (get_local 1))))
  "type mismatch"
)

(assert_invalid
  (module (func $type-param-arg-num-vs-num (param i32) (set_local 0 (f32.const 0))))
  "type mismatch"
)
(assert_invalid
  (module (func $type-param-arg-num-vs-num (param f32) (set_local 0 (f64.const 0))))
  "type mismatch"
)
(assert_invalid
  (module (func $type-param-arg-num-vs-num (param f64 i64) (set_local 1 (f64.const 0))))
  "type mismatch"
)


;; Invalid local index

(assert_invalid
  (module (func $unbound-local (local i32 i64) (get_local 3)))
  "unknown local"
)
(assert_invalid
  (module (func $negative-local (local i32 i64) (get_local -1)))
  "unknown local"
)
(assert_invalid
  (module (func $large-local (local i32 i64) (get_local 14324343)))
  "unknown local"
)

(assert_invalid
  (module (func $unbound-param (param i32 i64) (get_local 2)))
  "unknown local"
)
(assert_invalid
  (module (func $negative-param (param i32 i64) (get_local -2)))
  "unknown local"
)
(assert_invalid
  (module (func $large-param (local i32 i64) (get_local 714324343)))
  "unknown local"
)

(assert_invalid
  (module (func $unbound-mixed (param i32) (local i32 i64) (get_local 3)))
  "unknown local"
)
(assert_invalid
  (module (func $negative-mixed (param f32 f64) (local i32 i64) (get_local -1)))
  "unknown local"
)
(assert_invalid
  (module (func $large-mixed (param i64) (local i32 i64) (get_local 214324343)))
  "unknown local"
)

(assert_invalid
  (module (func $type-mixed-arg-num-vs-num (param f32) (local i32) (set_local 1 (f32.const 0))))
  "type mismatch"
)
(assert_invalid
  (module (func $type-mixed-arg-num-vs-num (param i64 i32) (local f32) (set_local 1 (f32.const 0))))
  "type mismatch"
)
(assert_invalid
  (module (func $type-mixed-arg-num-vs-num (param i64) (local f64 i64) (set_local 1 (i64.const 0))))
  "type mismatch"
)
