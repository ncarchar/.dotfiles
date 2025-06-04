; ~/.config/nvim/queries/java/injections.scm

((multiline_string_fragment) @injection.content
 (#match? @injection.content "<[^>]*>")
 (#set! injection.language "html"))

; ((string_literal) @injection.content
;  (#match? @injection.content "<[^>]*>")
;  (#set! injection.language "html"))
;
; ; For multiline content, use this pattern instead:
; ((string_literal) @injection.content
;  (#match? @injection.content "<.*>")
;  (#set! injection.language "html"))
