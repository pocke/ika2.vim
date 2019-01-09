let s:save_cpo = &cpo
set cpo&vim


command! Ika2StagesNow  call ika2#print_now()
command! Ika2StagesNext call ika2#print_next()

command! Ika2NextZoneG  call ika2#print_next_rule('gachi', 'splat_zones')
command! Ika2NextRainG  call ika2#print_next_rule('gachi', 'rainmaker')
command! Ika2NextClamG  call ika2#print_next_rule('gachi', 'clam_blitz')
command! Ika2NextTowerG call ika2#print_next_rule('gachi', 'tower_control')

command! Ika2NextZoneL  call ika2#print_next_rule('league', 'splat_zones')
command! Ika2NextRainL  call ika2#print_next_rule('league', 'rainmaker')
command! Ika2NextClamL  call ika2#print_next_rule('league', 'clam_blitz')
command! Ika2NextTowerL call ika2#print_next_rule('league', 'tower_control')


let &cpo = s:save_cpo
unlet s:save_cpo
