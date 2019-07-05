 (12/10/1999 Cherezov A.)

(A simple expansion of the SP-Fort operations on dynamic
  lines of arbitrary length. These procedures are made in style.
  Perl or php but the syntax and other details are made more
  corresponding to the Fort style, rather than Perl.

  Creating lines: 

  "string text"

  Or:

  "multiline
    text
    lines "

  You can include calculated expressions in the string, which
  should return the string [two numbers - addr u] or a number. Insofar as
  The fort is abandoned by a typeless language, the only way to
  to which libraries implemented here can find out what
  returned is a measure of the change in stack depth. If a
  Two numbers have been added, we consider this as the address and the length of the string
  if one, then we consider it a number. Returned row inserted
  to the place of the source line where the calculation was called from. If a
  returned the number, then it is converted to a string in the decimal system 
  notation. Example:

  : text S "text";
  "multiline
    {text}
    lines "

  Will create the same string as the previous example.

  The word "[quotation mark] returns a string not in the form of addr u, but in the form
  one number s, which can be converted to addr u with
  the words

  STR@ [s - addr u]

  If the word "is used inside the compiled definition, then
  the string is compiled in its original, uncomputed form, and will be computed
  when performing a compiled definition. For example:

  : TEST "multiline
    {text}
    strings ";

  When performing TEST, you get the same string as in the previous
  an example.

  The expression in {} always uses decimal
  number system.

  All operations with strings are performed in dynamic memory,
  each s returned by "is necessary after use
  remove from memory with a word

  STRFREE [s -]

  All operations put a zero at the end of the string, so the return
  by STR@ string value can be safely used in the functions of Windows
  requiring ASCIIZ strings.

  Create empty string:

  "" [- s]

  Add the line addr u to the end of the line s:

  STR+ + [addr us -]

  Add the string s1 to the end of the string s2 with the removal of s1:

  S+ [s1 s2 -]

  If within the string created by the quotation mark, you need to insert a quotation mark,
  this can be done with {''}, and the end of the string is {CRLF}. For example:

  "multiline {CRLF} {text}
    lines "

  returns the same string as in the previous example.

  If an error [throw] occurs during the evaluation of an expression in {}, then
  the value of the expression inserted into the string is "Error: error_codes".

  The special variant of the calculation of the expression {} is used if
  inside {} uses local names for the current compile
  variable procedures. These names exist only at the time of compilation,
  and at the time of the procedure when calculating {} it is not. therefore
  an error will occur. To prevent such an outcome and preserve
  the possibility of using local variables inside strings adopted
  The following syntax is to use a local variable inside a string:
  {$ var_name}. For example:

  : TEST || t ||
    "abcd" -> t
    "123 {$ t} 123" STYPE
  ;

  Running the word TEST will type 123abcd123.
  Sequences like {$ name} are processed at the time of compilation.
  and are replaced by the sequence {number RP @ + @ STR @}, where "number" is
  the offset of the local variable in the stack.

  If a local variable needs to be inserted into the string as a numeric 
  value, then {# variable_name} is used.

  To work with string literals inside {} you can use
  the word S', which is an analogue of S", but using a single quote
  when parsing.

  You can use the word to insert the contents of a file into a string 
  FILE [addr u - addr1 u1], here addr u is the file name, and addr1 u1 is
  its contents. For example:

  "text1 {S 'filename.txt' FILE} text2"

  EVAL-FILE does the same thing, but it evaluates the expressions in {} inside the file.
  EVAL-FILE can also be used inside EVAL-FILE included files.
  This is actually an analogue of the word INCLUDED, but interprets only
  expressions inside {}, and returning a string as the result.

  The above words "" "STR+ STR@ STRFREE CRLF '' FILE EVAL-FILE
  enough to use this library. It is recommended not to use
  other words defined in the implementation to not lose 
  compatibility with future versions.

  Potentially bottleneck - if in the process of "growth" the line becomes
  longer than 4Kb, a new buffer is allocated, when it is exhausted -
  next, etc. All old buffers except the very first 4Kb
  automatically released. In the service structures of the first buffer
  necessary "redirects" are made. Source pointer to string - s -
  continues to be valid for all the operations described. But
  storing pointers to addr u in external variables is not recommended,
  as it grows, the addr pointer may change when described
  re-allocating buffer. It is better to work with a pointer of the form s, and when
  it is necessary to get the string as addr u by the STR @ operation.

  The compiled size of the library is about 7Kb.
)
REQUIRE || ~ ac / lib / temps.f
0
4 - sType
4 - sAsize
4 - sSize
4 - sState
4 - sNewBuff
4 - sWriteH
4 - sReadH
CONSTANT / sHeader

USER STR-ID

: sAddr (s - addr)
  DUP sNewBuff @? DUP IF NIP EXIT THEN
  / sHeader +
;
: STR@ (s - addr u)
  DUP sAddr SWAP sSize @
;
: STRHERE (s - addr)
  STR @ +
;
: STRALLOT (ns - addr)
  || ns size au ob || ((ns))
  s STR @ NIP n + DUP
  / sHeader + s sAsize @ <
  0 = IF -> size
        size 2000 + ALLOCATE THROW
        s STR @ -> u -> a
        s sNewBuff @ -> ob
        DUP s sNewBuff!
        au ROT SWAP MOVE
        ob? DUP IF FREE THROW THEN
        size 2000 + s sAsize!
        size
     THEN
  s STRHERE
  SWAP s size!
  0 s STRHERE C!
;
: STR+ (addr us -)
  || aus || ((aus))
  aus STRALLOT u MOVE
;
: STR! (addr us -)
  0 OVER sSize! STR +
;
: STRBUF (- s)
  || s ||
  4000 / sHeader + DUP ALLOCATE THROW -> s
  s OVER ERASE
  s size!
  S "" s STR!
  s
;
: "" (- s)
  STRBUF
;
: STRFREE (s -)
  DUP sNewBuff @? DUP IF FREE THROW THEN
  FREE THROW
;
: STR_EVAL (addr us -)
  || s sp tib> in #tib so si ||
  -> s
  SP @ -> sp
  TIB -> tib> IN @ ->> in #TIB @ -> #tib SOURCE-ID -> so STR-ID -> si
  s STR-ID!
  \ if EVALUATE fails, he himself will not be able to restore our TIB, therefore we save
  ['] EVALUATE CATCH? DUP
  IF NIP NIP S "(Error:" s STR +
     ABS 0 <# [CHAR]) HOLD #S #> s STR +
     tib TO TIB> in> IN! #tib #TIB! so TO SOURCE-ID
  ELSE
     SP @ sp -
     \ difference = 0 if two numbers are returned - the address and the length of the string
     IF 0 <# #S #> THEN
     s STR +
  THEN
  si STR-ID!
  sp sp! 2DROP
;
: (") (addr u - s)
  || tib> in #tib s sp base ||
  Tib -> tib #TIB @ -> #tib> IN @ ->> in BASE @ -> base
  #TIB! TO TIB> IN 0! Decimal
  STRBUF -> s
  BEGIN
    > IN @ #TIB @ <
  WHILE
    [CHAR] {PARSE
    s STR +
    [CHAR]} PARSE? DUP
    IF s STR_EVAL
    ELSE DROP THEN
  REPEAT
  > in> IN! #tib #TIB! tib TO TIB base BASE!
  s
;
: _STRLITERAL (- s)
  R> DUP CELL + SWAP @ 2DUP + CHAR +> R
  (")
;
USER STRBUF_

: STRLITERAL (addr u -)
  \ similar to SLITERAL, but the length of the string is not limited to 255
  \ and the compiled string when executed expands by (")
  STATE @ IF
             ['] _STRLITERAL COMPILE,
             DUP,
             HERE SWAP DUP ALLOT MOVE 0 C,
             STRBUF_ @ STRFREE
          ELSE
             (")
          THEN
; IMMEDIATE

: CRLF
  Lt 2
;
CREATE _S "" "CHAR" C,
: ''
  _S "" "1
;

HEX
98 CONSTANT LOCALS_STACK_OFFSET
\ offset of the first local variable in the stack
\ at the time of the word (") inside the compiled definition
Decimal

: STR@ LOCAL (addr u - addr u)
  || tib> in #tib s sp ||
  Tib -> tib #TIB @ -> #tib> IN @ ->> in
  #TIB! TO TIB> IN 0!
  STRBUF -> s
  BEGIN
    >IN @ #TIB @ <
  WHILE
    [CHAR] {PARSE
    s STR +
    [CHAR]} PARSE? DUP
    IF OVER C @ [CHAR] $ =
       IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
          IF> BODY @ CELLS LOCALS_STACK_OFFSET + 0 <# #S [CHAR] {HOLD #> s STR +
             S "RP @ + @ STR @}" s STR +
          THEN
       ELSE OVER C @ [CHAR] # =
            IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
               IF> BODY @ CELLS LOCALS_STACK_OFFSET + 0 <# #S [CHAR] {HOLD #> s STR +
                 S "RP @ + @}" s STR +
              THEN
            ELSE S "{" s STR + s STR + S "}" s STR + THEN
       THEN
    ELSE DROP THEN
  REPEAT
  TIB / sHeader - STRFREE
  > in> IN! #tib #TIB! tib TO TIB
  s DUP STRBUF_! STR @
;
: PARSE "
  || sau ||
  [CHAR] "PARSE
  2DUP + C @ [CHAR] "= 
  IF "" -> ss STR! s STR @ STR @ LOCAL EXIT THEN \ whole literal on one line
  \ otherwise read line by line and look for quotes
  SOURCE-ID? DUP
  IF FILE-SIZE THROW D> S ELSE 10000 THEN 
  DUP ALLOCATE THROW -> s
  s OVER ERASE
  s size!
  s STR! CRLF s STR +
  BEGIN
    Refill
  WHILE
    SOURCE '' SEARCH
    IF -> u -> a
       SOURCE u - s STR +
       SOURCE NIP u - CHAR +> IN!
       s STR @ STR @ LOCAL EXIT
    ELSE s STR + CRLF s STR + THEN
  REPEAT
  s STR @ STR @ LOCAL
;
: "(" ccc "-)
  PARSE "POSTPONE STRLITERAL
; IMMEDIATE

: STYPE
  DUP STR@ TYPE
  STRFREE
;
: FILE (addr u - addr1 u1)
  || f mem ||
  R / O OPEN-FILE-SHARED IF DROP S "" EXIT THEN
   -> f
  f FILE-SIZE THROW D> S DUP ALLOCATE THROW -> mem
  mem SWAP f READ-FILE THROW
  f CLOSE-FILE THROW
  mem SWAP
;
: S'
  [CHAR] 'PARSE [COMPILE] SLITERAL
; IMMEDIATE

: EVAL-FILE (addr u - addr1 u1)
  FILE (") STR @
;
: S! (addr u var_addr -)
  "" DUP ROT! STR +
;
: S+
  OVER STR@ ROT STR+ STRFREE
;

(
\ Tests:

: TEST S"test";
"abc {TEST} 123 5 + 5 = {5 5 +} Ok" STYPE CR

: TEST2 "abc {TEST} 123 5 + 5 = {5 5 +} Ok {ZZZ} OK!" STYPE CR;
TEST2

" 
  abc
  def
  {TEST}
  123
" 
STYPE

: TEST3 || ntk ||
  9 -> n
  "abcd" -> t
  3 -> k
  "123 {$ t} 123 {#n} 123 {S 'file1.txt' EVAL-FILE} <End of file>" STYPE
;
TEST3
)