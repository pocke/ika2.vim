let s:save_cpo = &cpo
set cpo&vim


command! Ika2StagesNow call ika2#print_now()
command! Ika2StagesNext call ika2#print_next()

let &cpo = s:save_cpo
unlet s:save_cpo
