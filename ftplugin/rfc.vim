" Vim script file
" FileType:			RFC
" Author:				lilydjwg <shura1991@gmail.com>
" Version:			1.2
" Contributor:	Marcelo Montú, Chenxiong Qi, shurizzle

let b:backposes = []

if !exists('*<SID>get_pattern_at_cursor')
	fu s:get_pattern_at_cursor(pat)
		" This is a function copied from another script.
		" Sorry that I don't remember which one.
		let col = col('.') - 1
		let line = getline('.')
		let ebeg = -1
		let cont = match(line, a:pat, 0)
		while (ebeg >= 0 || (0 <= cont) && (cont <= col))
			let contn = matchend(line, a:pat, cont)
			if (cont <= col) && (col < contn)
				let ebeg = match(line, a:pat, cont)
				let elen = contn - ebeg
				brea
			el
				let cont = match(line, a:pat, contn)
			en
		endwh
		if ebeg >= 0
			retu strpart(line, ebeg, elen)
		el
			retu ""
		en
	endf
en

if !exists('*<SID>rfcTag')
	fu s:rfcTag()
		" Jump from Contents or [xx] to body or References
		let syn = synIDattr(synID(line("."), col("."), 1), "name")
		if syn == 'rfcContents' || syn == 'rfcDots'
			let l = getline('.')
			let lm = matchstr(l, '\v%(^\s+)@<=%(Appendix\s+)=[A-Z0-9.]+\s')
			if lm == ""
				" Other special contents
				let lm = matchstr(l, '\vFull Copyright Statement')
			en
			let l = '^\c\V' . lm
			cal add(b:backposes, getpos('.'))
			cal search(l, 'Ws')
		elsei syn == 'rfcReference'
			let l = s:get_pattern_at_cursor('\[\w\+\]')
			if l == ''
				" Not found.
				echoh Error
				echom 'Cursor is not on References!'
				echoh None
				retu
			en
			if b:refpos[0] == 0 " Not found.
				echoh Error
				echom 'References not found!'
				echoh None
				retu
			en
			norm m'
			cal add(b:backposes, getpos('.'))
			cal cursor(b:refpos[0], 0)
			try
				exe '/^\s\+\V'. l.'\v\s+[A-Za-z"]+/'
				norm ^
			cat /^Vim\%((\a\+)\)\=:E385/
				" Not found.
				exe "normal \<C-O>"
				echoh WarningMsg
				echom 'The reference not found!'
				echoh None
			endt
		elsei syn == 'rfcRFC'
			if search('\v%(RFC|STD) \d+', 'bc', line('.')) != 0
				call rfc#query(matchstr(getline('.')[col('.')-1:], '\v%(RFC|STD) (\d+)'))
			en
		el
			echoh Error
			echom 'Cursor is not on Contents or References!'
			echoh None
		en
	endf
en

if !exists('*<SID>rfcJumpBack')
	fu s:rfcJumpBack()
		if len(b:backposes) > 0
			let backpos = remove(b:backposes, len(b:backposes) - 1)
			cal setpos('.', backpos)
		el
			echo ErrorMsg
			echo "Can't jump back anymore."
			echo None
		en
	endf
en

" References jump will need it
let b:refpos = searchpos('^\v(\d+\.?\s)?\s*References\s*$', 'wn')

nn <buffer> <silent> <C-]> :call <SID>rfcTag()<CR>
nn <buffer> <silent> <cr>  :call <SID>rfcTag()<CR>
nn <buffer> <silent> <C-t> :call <SID>rfcJumpBack()<CR>
