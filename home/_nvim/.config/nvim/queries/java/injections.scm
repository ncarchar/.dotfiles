; ~/.config/nvim/queries/java/injections.scm

((multiline_string_fragment) @injection.content
 (#match? @injection.content "<")
 (#set! injection.language "html"))
