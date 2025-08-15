source "$(dirname "$(dirname "$(realpath "$(which blesh-share)")")")/share/blesh/ble.sh"

export COLORTERM=truecolor

bleopt term_index_colors=auto
bleopt term_true_colors=semicolon

ble-face auto_complete='fg=grey'

ble-face region='bg=blue,fg=white'
ble-face region_target='bg=yellow,fg=black'
ble-face region_match='bg=magenta,fg=white'
ble-face region_insert='fg=cyan'
ble-face disabled='fg=gray'
ble-face overwrite_mode='fg=white'

ble-face syntax_default=none
ble-face syntax_command='fg=brown'
ble-face syntax_quoted='fg=green'
ble-face syntax_quotation='fg=green'
ble-face syntax_escape='fg=magenta'
ble-face syntax_expr='fg=blue'
ble-face syntax_error='fg=red'
ble-face syntax_varname='fg=yellow'
ble-face syntax_delimiter=none
ble-face syntax_param_expansion='fg=magenta'
ble-face syntax_history_expansion='bg=yellow,fg=white'
ble-face syntax_function_name='fg=magenta'
ble-face syntax_comment='fg=gray,italic'
ble-face syntax_glob='fg=magenta'
ble-face syntax_brace='fg=cyan'
ble-face syntax_tilde='fg=blue'
ble-face syntax_document='fg=cyan'
ble-face syntax_document_begin='fg=cyan'

ble-face command_builtin_dot='fg=red'
ble-face command_builtin='fg=red'
ble-face command_alias='fg=green'
ble-face command_function='fg=magenta'
ble-face command_file='fg=green'
ble-face command_keyword='fg=blue'
ble-face command_jobs='fg=red'
ble-face command_directory='fg=blue'

ble-face argument_option='fg=cyan'
ble-face argument_error='gf=red,bold'

ble-face filename_directory='underline,fg=250'
ble-face filename_directory_sticky='underline,fg=250'
ble-face filename_link='underline,fg=250'
ble-face filename_orphan='underline,fg=black'
ble-face filename_executable='underline,fg=green'
ble-face filename_setuid='underline,fg=black'
ble-face filename_setgid='underline,fg=black'
ble-face filename_other='underline,fg=250'
ble-face filename_socket='underline,fg=250'
ble-face filename_pipe='underline,fg=green'
ble-face filename_character='underline,fg=white'
ble-face filename_block='underline,fg=yellow'
ble-face filename_warning='underline,fg=red'
ble-face filename_url='underline,fg=250'

ble-face varname_array='fg=orange,bold'
ble-face varname_empty='fg=blue'
ble-face varname_export='fg=red,bold'
ble-face varname_expr='fg=magenta,bold'
ble-face varname_hash='fg=green,bold'
ble-face varname_number='fg=green'
ble-face varname_readonly='fg=red'
ble-face varname_transform='fg=blue,bold'
ble-face varname_unset='fg=gray'
