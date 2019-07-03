\ *  PETER  PSOCKET  FOR  GTK SERVER JUNE-10- 2019  *

\ simply copy this file  to  C:\Forthw 

\ and upload it with Included  from the menu.

\ ForthW  shall be installed  from  https://github.com/PeterForth/ForthWin-Download
\ the drive can be   C:\  D:\  E:\    no problem
\  before  making ForthWin  included,  the  GTK server must be open 
\ and ready to receive commands on port 50000
\ for that purpose  I created a GTK-socket.bat  you have to call before anything
\ and everytime you get out of ForthW-W.exe  or  close the file, etc.
\ I am using NOTEPAD++ , so I have a macro on CTRL-F5 that automatically
\ calls  ForthW-W.exe with the file I am editing. This is very fast and easy.


\  this demo  will run a GLADE file  , of a CALCULATOR
\  you need to place  calculator.glade   inside your  GTK-server folder
\  in   my case  I copyed into   c:\gtk-server\ 


\  REQUIRE StartApp    

REQUIRE CreateSocket ~ac/lib/win/winsock/ws2/sockets.f
REQUIRE SocketLine   ~ac/lib/win/winsock/ws2/socketline2.f
REQUIRE STR@         ~ac/lib/str5.f

\  REQUIRE drop$       c:\forthw2\stringstack.f
\ socketline -  

: fsock ( socketline -- socket )
  sl_socket @
;

 
: fsockopen ( server port -- socketline )
  { server port \ sock ip }
  server STR@ GetHostIP THROW -> ip
  CreateSocket THROW -> sock
  60000 sock SetSocketTimeout THROW                \ was 60000  !!! 
  ip port sock ConnectSocket 
  ?DUP IF sock CloseSocket DROP THROW THEN
  sock SocketLine
;
\ : fclose ( socketline -- )
\   fsock CloseSocket THROW
\ ;
: fclose ( socketline -- )
   DUP fsock CloseSocket THROW  \ лучше DROP
  FREE THROW
;
: fputs ( str socketline -- )
  { str sock }
  str STR@
  sock fsock WriteSocket THROW
; 

: fgets ( socketline -- str )    
  { sock \ str }
  sock SocketReadLine
  "" -> str  str STR!
  str
;


create winpad 40 allot
create win2  20 allot

0 value win 
0 value s1   

0 value s2

: >gtk   ( -- addr )                                \ send command to gtk server
           s2 fputs               \ 100 PAUSE
           s2 fgets     
;
       
: .gtk$   ( addr --)  cr  ." answer..   "   STYPE  ;   \ print the status string

\ --------------------------TEST GTK -------------------------------
\ -----------------------------------------------------------------
 

\ ' Event Handler
\ REPEAT
\ event = GUI("gtk_server_callback", "WAIT")
\ UNTIL event = "exit" OR event = "quit"


: TEST-CALCULATOR  ( --) 
  { \ s CC BC TC WC LC XML WD  QB EVENT1 GTK }
  SocketsStartup THROW cr  s  .s  
  " localhost" 50000 fsockopen -> s        s to s2
\ ------------------------------------------------------------------
 
                                              \   gtk_init (&argc, &argv);
     " gtk_init NULL NULL"  >gtk      .gtk$                  
     " glade_init  "  >gtk      .gtk$  
\ ------------------------------------------------------------------
    cr  ." ==========reading file =====================  "  cr  
 \  --->  Load the Glade  XML  file  < ---------------
                                               \  xml = glade_xml_new ("hello.glade", NULL, NULL);
 " glade_xml_new    calculator.glade  $NULL   $NULL  "    >gtk    ->  XML    
  pause 100
cr  ."  passed  P0  --file read : " cr  
\ 1 ------------------------------------------------------------------

\ 1  get the   handle of the GTK window   store into  WD  variable   
                                          \   glade_xml_get_widget(xml, "app1");
" glade_xml_signal_autoconnect {$XML} "  >gtk    .GTK$ 
\  2 ------------------------------------------------------------------

" glade_xml_get_widget {$XML} window "   >gtk    -> GTK

"  gtk_server_connect   {$GTK}  delete-event  window   "    >gtk   .GTK$   

 
\  3 GTK = glade_xml_get_widget(XML, "button0")

  " glade_xml_get_widget {$XML} button0 "   >gtk    -> GTK 

\  4  gtk_server_connect GTK, "clicked", "button0"

 " gtk_server_connect {$GTK}  clicked   button0 "   >gtk    .GTK$  
       
\   ------------------------------------------------------------------
 
 
   cr  ."  passed  5 --- entering the loop .."  cr 

 
  "  gtk_server_callback  wait"   >gtk    .gtk$  
 
 
 1000 0 DO 
\ "  gtk_server_callback  WAIT "   >gtk    .gtk$   \ -> EVENT1     \ wait for a button to be pressed
100 pause              \ small pause

\ -------------------------------------------------- 
\ here will be the code to process 
\ the buttons and text entry of the calculator
\  --------------------------------------------------
LOOP

   cr  ." ** end of demo ! ** "

  " gtk_server_exit "  >gtk  .gtk$ 
  
 

;



TEST-CALCULATOR 



\EOF