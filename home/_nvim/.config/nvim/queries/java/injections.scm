; ~/.config/nvim/queries/java/injections.scm

((string_literal) @injection.content
 (#match? @injection.content "<")
 (#set! injection.language "html")
 (#set! injection.include-children))
