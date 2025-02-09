if has('win32')
	let s:dirsep = '\'
el
	let s:dirsep = '/'
en

if has('plan9')
	let s:rfc_cache_dir = '/lib/rfc'
elsei has('win32')
	let s:rfc_cache_dir = (exists('$LOCALAPPDATA') ?
		$LOCALAPPDATA :
		((exists('$USERPROFILE') ?
			$USERPROFILE :
			((exists('$SystemDrive') ?  $SystemDrive : 'C:') .
			'\Users\' .
			(exists('$USERNAME') ? $USERNAME : $USER))) .
			'\AppData\Local')) . '\rfc'
elsei has('macos')
	let s:rfc_cache_dir = expand('~/Library/Caches/rfc')
else
	let s:rfc_cache_dir = (exists('$XDG_CACHE_HOME') ? $XDG_CACHE_HOME : expand('~/.cache')) . '/rfc'
en

if has('plan9')
	let s:rfc_index = s:rfc_cache_dir . s:dirsep . 'vim-INDEX'
el
	let s:rfc_index = s:rfc_cache_dir . s:dirsep . 'INDEX'
en

fu s:rfc_file(no)
	retu s:rfc_cache_dir . s:dirsep . 'rfc' . a:no
endf

fu s:std_file(no)
	retu s:rfc_cache_dir . s:dirsep . 'std' . a:no
endf

if !has('plan9')
	fu s:rfc_url(no)
		retu 'https://www.rfc-editor.org/rfc/rfc' . a:no . '.txt'
	endf

	fu s:std_url(no)
		retu 'https://www.rfc-editor.org/std/std' . a:no . '.txt'
	endf
en

if has('plan9')
	fu s:download_rfc(no)
		let l:script = 'rfork en'."\n"
					\ .'need='.a:no."\n"
					\ .'path=(/bin)'."\n"
					\ .'fn cd'."\n"
					\ ."\n"
					\ .'dom=`{ndb/query sys $sysname dom}'."\n"
					\ .'if(~ $dom '''') dom=$sysname'."\n"
					\ ."\n"
					\ .'ftpfs -q/ -a $user@$dom ftp.rfc-editor.org'."\n"
					\ ."\n"
					\ .'LIB=/lib/rfc'."\n"
					\ .'cd /n/ftp/in-notes'."\n"
					\ ."\n"
					\ .'if(test -f rfc$need.txt){'."\n"
					\ .'	cp rfc$need.txt $LIB/rfc$need'."\n"
					\ .'	chmod 664 $LIB/rfc$need'."\n"
					\ .'}'."\n"
					\ ."\n"
					\ .'if not for(i in rfc*$need.txt){'."\n"
					\ .'	target=`{'."\n"
					\ .'		echo $i | sed '''."\n"
					\ .'			s/.txt$//'."\n"
					\ .'			s/rfc0*//'''."\n"
					\ .'	}'."\n"
					\ .'	if(~ $target $need){'."\n"
					\ .'		cp $i $LIB/rfc$need'."\n"
					\ .'		chmod 664 $LIB/rfc$need'."\n"
					\ .'	}'."\n"
					\ .'}'."\n"
		cal system('/bin/rc -b >/dev/null >[2]/dev/null', l:script)
		if v:shell_error != 0
			sil cal delete(s:rfc_file(a:no))
		en
	endf

	fu s:download_std(no)
		let l:script = 'rfork en'."\n"
					\ .'need='.a:no."\n"
					\ .'path=(/bin)'."\n"
					\ .'fn cd'."\n"
					\ ."\n"
					\ .'dom=`{ndb/query sys $sysname dom}'."\n"
					\ .'if(~ $dom '''') dom=$sysname'."\n"
					\ ."\n"
					\ .'ftpfs -q/ -a $user@$dom ftp.rfc-editor.org'."\n"
					\ ."\n"
					\ .'LIB=/lib/rfc'."\n"
					\ .'cd /n/ftp/in-notes/std'."\n"
					\ ."\n"
					\ .'if(test -f std$need.txt){'."\n"
					\ .'	cp std$need.txt $LIB/std$need'."\n"
					\ .'	chmod 664 $LIB/std$need'."\n"
					\ .'}'."\n"
					\ ."\n"
					\ .'if not for(i in std*$need.txt){'."\n"
					\ .'	target=`{'."\n"
					\ .'		echo $i | sed '''."\n"
					\ .'			s/.txt$//'."\n"
					\ .'			s/std*//'''."\n"
					\ .'	}'."\n"
					\ .'	if(~ $target $need){'."\n"
					\ .'		cp $i $LIB/std$need'."\n"
					\ .'		chmod 664 $LIB/std$need'."\n"
					\ .'	}'."\n"
					\ .'}'."\n"
		cal system('/bin/rc -b >/dev/null >[2]/dev/null', l:script)
		if v:shell_error != 0
			sil cal delete(s:std_file(a:no))
		en
	endf

	fu s:read_rfc_index()
		let l:script = 'rfork en'."\n"
					\ .'path=(/bin)'."\n"
					\ .'fn cd'."\n"
					\ ."\n"
					\ .'dom=`{ndb/query sys $sysname dom}'."\n"
					\ .'if(~ $dom '''') dom=$sysname'."\n"
					\ ."\n"
					\ .'ftpfs -q/ -a $user@$dom ftp.rfc-editor.org || exit $status'."\n"
					\ ."\n"
					\ .'cat /n/ftp/in-notes/rfc-index.txt || exit $status'."\n"
		let l:txt = systemlist('/bin/rc -b >[2]/dev/null', l:script)
		if v:shell_error == 0
			sil cal append(line('$'), l:txt)
			retu v:true
		el
			retu v:false
		en
	endf

	fu s:read_std_index()
		let l:script = 'rfork en'."\n"
					\ .'path=(/bin)'."\n"
					\ .'fn cd'."\n"
					\ ."\n"
					\ .'dom=`{ndb/query sys $sysname dom}'."\n"
					\ .'if(~ $dom '''') dom=$sysname'."\n"
					\ ."\n"
					\ .'ftpfs -q/ -a $user@$dom ftp.rfc-editor.org || exit $status'."\n"
					\ ."\n"
					\ .'cat /n/ftp/in-notes/std/std-index.txt || exit $status'."\n"
		let l:txt = systemlist('/bin/rc -b >[2]/dev/null', l:script)
		if v:shell_error == 0
			sil cal append(line('$'), l:txt)
			retu v:true
		el
			retu v:false
		en
	endf
elsei executable('curl')
	fu s:download(url, to)
		sil exe '!curl -qfSsLo ' . shellescape(a:to) . ' ' . shellescape(a:url)
		if v:shell_error != 0
			sil cal delete(a:to)
		en
	endf

	fu s:read_url(url)
		sil exe 'r!curl -qfSsL ' . shellescape(a:url)
		if v:shell_error == 0
			retu v:true
		el
			retu v:false
		en
	endf
elsei executable('wget')
	fu s:download(url, to)
		sil exe '!wget -qO ' . shellescape(a:to) . ' ' . shellescape(a:to)
		if v:shell_error != 0
			sil cal delete(a:to)
		en
	endf

	fu s:read_url(url)
		sil exe 'r!wget -qO- ' . shellescape(a:url)
		if v:shell_error == 0
			retu v:true
		el
			retu v:false
		en
	endf
el
	fu s:download(url, to)
		th 'no downloader found'
	endf

	fu s:read_url(url)
		th 'no downloader found'
	endf
en

if !has('plan9')
	fu s:download_rfc(no)
		cal s:download(s:rfc_url(a:no), s:rfc_file(a:no))
	endf

	fu s:download_std(no)
		cal s:download(s:std_url(a:no), s:std_file(a:no))
	endf

	fu s:read_rfc_index()
		retu s:read_url('https://www.rfc-editor.org/rfc-index.txt')
	endf

	fu s:read_std_index()
		retu s:read_url('https://www.ietf.org/rfc/std-index.txt')
	endf
en

fu s:open_doc(typ, no)
	if !isdirectory(s:rfc_cache_dir)
		cal mkdir(s:rfc_cache_dir, 'p', 0700)
	en

	let l:no = str2nr(a:no)
	let l:ltyp = tolower(a:typ)
	let l:file = funcref('<SID>' . l:ltyp . '_file')(l:no)
	if !filereadable(l:file)
		echo 'Downloading ' . a:typ . l:no . '...'
		cal funcref('<SID>download_' . l:ltyp)(l:no)
	en
	if !filereadable(l:file)
		echoe a:typ.' '.l:no.' not found'
		retu
	en

	enew
	setl bt=nofile
	nos
	setl ma nonu nornu nofen
	if bufexists(a:typ.l:no)
		sil exe 'bw' a:typ.l:no
	en
	sil exe 'read' fnameescape(l:file)
	sil 1d _
	setl ft=rfc
	set nomod noma
	sil exe 'file' a:typ.l:no
	redr!
endf

fu s:open_rfc(no)
	cal s:open_doc('RFC', a:no)
endf

fu s:open_std(no)
	cal s:open_doc('STD', a:no)
endf

fu s:download_index()
	if !isdirectory(s:rfc_cache_dir)
		cal mkdir(s:rfc_cache_dir, 'p', 0700)
	en

	bel 12new ++ff=unix ++enc=utf-8 ++nobin ++edit +setl\ ma +redr!
	echo 'Downloading INDEX...'
	if !s:read_rfc_index()
		sil clo!
		retu
	en

	0
	sil %s/\V\m\n\([^\n]\)/\1/g
	0
	sil v/\V\m^\d\{4\} /d
	0
	sil g/\V\m^\d\{4\} Not issued\.$/d
	0
	sil %s/\V\m^\(\d\{4\}\) /RFC\1: /g
	$
	let l:line = line('.') + 1

	if !s:read_std_index()
		sil clo!
		retu
	en

	sil exe l:line
	sil .,$s/\V\m\n\([^\n]\)/\1/g
	sil exe l:line
	sil .,$s/\V\m^\(\d\{4\}\) /STD\1: /g
	0
	sil v/\V\m\C^\(RFC\|STD\)\d\{4\}: /d
	0
	sil %s/\V\m\C *(Format:[^)]\+) */ /g
	0
	try
		sil %s/\V\m\s\+$//g
	cat /.*/
	endt

	sil exe 'w!' s:rfc_index
	sil bw!
endf

fu s:open_entry_by_cr()
	let [l:typ, l:id] = matchlist(getline('.'), '^\v(RFC|STD)(\d+): ')[1:2]
	sil clo
	cal funcref('<SID>open_' .  tolower(l:typ))(str2nr(l:id))
endf

fu rfc#query(query)
	if type(a:query) == v:t_number
		cal s:open_rfc(a:query)
		retu
	en

	if type(a:query) != v:t_string
		echoe 'Invalid query'
		retu
	en

	let l:query = s:trim(a:query)
	if l:query =~ '\V\m\c^rfc \?\d\+$'
		cal s:open_rfc(s:trim(l:query[3:]))
		retu
	elsei l:query =~ '\V\m\c^std \?\d\+$'
		cal s:open_std(s:trim(l:query[3:]))
		retu
	en
	if l:query =~ '\V\m^\d\+$'
		cal s:open_rfc(l:query)
		retu
	en

	if !filereadable(s:rfc_index)
		cal s:download_index()
	en
	if !filereadable(s:rfc_index)
		echoe 'Cannot download INDEX'
		retu
	en

	bel 12new ++ff=unix ++enc=utf-8 ++nobin ++edit +setl\ ma
	sil exe 'read' fnameescape(s:rfc_index)
	sil 1d _
	if bufexists('vim-rfc')
		sil bw vim-rfc
	en
	sil f vim-rfc
	setl nomod wfh bt=nofile bh=wipe nowrap nonu nornu fdc=0 scl=no cc= nospell
	if !empty(a:query)
		0
		sil exe 'v/'.a:query.'/d'
	en
	setl noma nomod
	sil nn <silent><buffer> <CR> :cal <SID>open_entry_by_cr()<CR>
	sil nn <silent><buffer> q :close<cr>
	sil sy match  RFCTitle /.*/                 contains=RFCStart
	sil sy match  RFCStart /\v^\u{3}\d+:/       contains=RFCType,RFCID,RFCDelim contained
	sil sy region RFCType  start=/^/ end=/^.../ contained
	sil sy match  RFCID    /\d\+/               contained
	sil sy match  RFCDelim /:/                  contained
	sil hi def link RFCTitle Normal
	sil hi def link RFCType  Identifier
	sil hi def link RFCID    Number
	sil hi def link RFCDelim Delimiter
	0
endf

fu rfc#cache()
	retu s:rfc_cache_dir
endf
