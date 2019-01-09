let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#ika2#new()
let s:HTTP = s:V.import('Web.HTTP')
let s:DateTime = s:V.import('DateTime')

let s:API_URL = 'https://spla2.yuu26.com/schedule'
let s:USER_AGENT = 'Ika2.vim (https://github.com/pocke/ika2.vim)'

let s:CACHE_DIR = $HOME . "/.cache/ika2-vim"
call mkdir(s:CACHE_DIR, 'p')
let s:CACHE_FILE = s:CACHE_DIR . "/schedule.json"

let s:ERR_SCHEDULE_NOT_FOUND = "Schedule not found"

function! s:fetch_schedule_from_api() abort
  let result = s:HTTP.request(s:API_URL, {'headers': {'User-Agent': s:USER_AGENT}})
  if result.status / 100 != 2
    throw printf("Unexpected status: %d", result.status)
  endif

  let content = result.content
  call writefile(split(content, "\n"), s:CACHE_FILE, 'b')
endfunction

function! s:load_schedule() abort
  let schedule = json_decode(join(readfile(s:CACHE_FILE, 'b'), "\n"))
  return schedule
endfunction

function! s:fetch_schedule_for_rule(unixtime, rule, schedule) abort
  for v in a:schedule.result[a:rule]
    if v.start_t <= a:unixtime && a:unixtime <= v.end_t
      return v
    end
  endfor
  throw s:ERR_SCHEDULE_NOT_FOUND
endfunction

function! s:_fetfch_schedule_for(unixtime) abort
  let res = {}
  let schedule = s:load_schedule()

  let res.regular = s:fetch_schedule_for_rule(a:unixtime, 'regular', schedule)
  let res.gachi = s:fetch_schedule_for_rule(a:unixtime, 'gachi', schedule)
  let res.league = s:fetch_schedule_for_rule(a:unixtime, 'league', schedule)

  return res
endfunction

function! ika2#stage_for(unixtime) abort
  if filereadable(s:CACHE_FILE)
    try
      return s:_fetfch_schedule_for(a:unixtime)
    catch /Schedule not found/
      " do nothing
    endtry
  endif

  call s:fetch_schedule_from_api()
  return s:_fetfch_schedule_for(a:unixtime)
endfunction

function! ika2#stage_for_now() abort
  let t = s:DateTime.now().unix_time()
  return ika2#stage_for(t)
endfunction

function! ika2#print_for(unixtime) abort
  let stages = ika2#stage_for(a:unixtime)
  echo "レギュラーマッチ: ナワバリバトル"
  for s in stages.regular.maps_ex
    echo "  " . s.name
  endfor

  echo "ガチマッチ: " . stages.gachi.rule_ex.name
  for s in stages.gachi.maps_ex
    echo "  " . s.name
  endfor

  echo "リーグマッチ: " . stages.league.rule_ex.name
  for s in stages.league.maps_ex
    echo "  " . s.name
  endfor
endfunction

function! ika2#print_now() abort
  call ika2#print_for(s:DateTime.now().unix_time())
endfunction

function! ika2#print_next() abort
  call ika2#print_for(s:DateTime.now().unix_time() + 2 * 60 * 60)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
