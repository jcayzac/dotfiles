" Vim syntax file
" Language:	Old-Style ASCII Property Lists
" Maintainer:	Matthew Jimenez <mjimenez@ersnet.net>
" Last Change:	2005 Feb 28

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match PlistComma		+,+ contained
syn match PlistSemicolon	+;+ contained

syn match PlistParen		+(+ contained
syn match PlistParenEnd		+)+ contained
syn match PlistBrace		+{+ contained
syn match PlistBraceEnd		+}+ contained

syn match PlistParenErr		+(+ contained
syn match PlistParenEndErr	+)+ contained
syn match PlistBraceErr		+{+ contained
syn match PlistBraceEndErr	+}+ contained
syn match PlistDataErr		+<+ contained
syn match PlistDataEndErr	+>+ contained
syn match PlistCommentErr	+\*/+

" Comments can technically go anywhere in between other items, but I'm trying to keep this logical
syn region PlistComment	start=+/\*+ end=+\*/+
syn cluster PlistCommentGroup	contains=PlistComment,PlistCommentErr

" Basic values - unquoted, quoted, double-quoted, data
syn match PlistValue	+[a-zA-Z0-9][a-zA-Z0-9.-:_]*+ contained nextgroup=PlistComma,PlistSemicolon skipwhite skipempty

syn region PlistCharacter	start=+'+ skip=+\\'+ end=+'+ contained nextgroup=PlistComma,PlistSemiColon skipwhite skipempty

syn region PlistString	start=+"+ skip=+\\"+ end=+"+ contained nextgroup=PlistComma,PlistSemicolon skipwhite skipempty

syn region PlistData	start=+<+ skip=+\\"+ end=+>+ contained nextgroup=PlistComma,PlistSemicolon skipwhite skipempty

" Dictionary - {key=value; key='value'; key="value"}
syn cluster PlistValueGroup	contains=PlistArray,PlistString,PlistCharacter,PlistValue,PlistData,PlistDictionary

syn match PlistEqual	+=+ contained nextgroup=@PlistValueGroup skipwhite skipempty

syn match PlistKey	+[a-zA-Z][a-zA-Z0-9.-:_]*\([ \t]*=\)\@=+ contained nextgroup=PlistEqual skipwhite skipempty

syn cluster PlistDictionaryGroup contains=PlistKey,PlistBraceErr,PlistParenErr,PlistParenEndErr,PlistDataErr,PlistDataEndErr

syn region PlistDictionary	matchgroup=PlistBrace start=+{+ matchgroup=PlistBraceEnd end=+}+ contains=@PlistDictionaryGroup,@PlistCommentGroup nextgroup=PlistComma,PlistSemicolon skipwhite skipempty

" Array Entries - (entry,'entry',"entry")
syn cluster PlistArrayGroup	contains=PlistString,PlistArray,PlistDictionary,PlistCharacter,PlistData,PlistBraceEndErr,PlistDataEndErr

syn region PlistArray	matchgroup=PlistParen start=+(+ matchgroup=PlistParenEnd end=+)+ contains=@PlistArrayGroup,@PlistCommentGroup nextgroup=PlistComma,PlistSemicolon skipwhite skipempty


if version>= 508 || !exists("did_c_syn_inits")
  if version < 508
    let did_c_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink PlistString		String
  HiLink PlistCharacter		Character
  HiLink PlistComment		Comment
  HiLink PlistKey		Type
  HiLink PlistParen		Function
  HiLink PlistParenEnd		Function
  HiLink PlistParenErr		Error
  HiLink PlistParenEndErr	Error
  HiLink PlistBrace		Function
  HiLink PlistBraceEnd		Function
  HiLink PlistBraceErr		Error
  HiLink PlistBraceEndErr	Error
  HiLink PlistEqual		Operator
  HiLink PlistComma		Special
  HiLink PlistSemicolon		Special
  HiLink PlistData		Statement
  HiLink PlistDataErr		Error
  HiLink PlistDataEndErr	Error
  HiLink PlistCommentErr	Error

  delcommand HiLink

endif

