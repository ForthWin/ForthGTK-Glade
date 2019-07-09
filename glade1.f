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


variable etat
5 etat !

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
 

: TEST-GLADE  ( --) 
  { \ s CC BC TC WC LC XML WD  QB EVENT1 GTK }
  SocketsStartup THROW cr  s  .s  
  " localhost" 50000 fsockopen -> s        s to s2
\ ------------------------------------------------------------------
 
                                              \   gtk_init (&argc, &argv);
     " gtk_init NULL NULL"  >gtk      .gtk$                  
     " glade_init  "  >gtk      .gtk$  
\ ------------------------------------------------------------------
 \  --->  Load the Glade  XML  file  < ---------------
 
 " glade_xml_new    hello.glade  $NULL   $NULL  "    >gtk    ->  XML    
 
\ 1 ------------------------------------------------------------------

\ 1  get the   handle of the GTK window   store into  WD  variable   
                                          \   glade_xml_get_widget(xml, "app1");
" glade_xml_signal_autoconnect {$XML} "  >gtk .GTK$ 
\  2 ------------------------------------------------------------------

" glade_xml_get_widget {$XML} window "   >gtk    -> GTK

" gtk_server_connect   {$GTK}  delete-event  window   "   >gtk   .GTK$   

 " glade_xml_get_widget {$XML} button1 "   >gtk    -> GTK 

 " gtk_server_connect {$GTK}  clicked   1 "   >gtk  .GTK$    \ send 1

 " glade_xml_get_widget {$XML} button2 "   >gtk    -> GTK 

 " gtk_server_connect {$GTK}  clicked   2 "   >gtk  .GTK$       

 " glade_xml_get_widget {$XML} button3 "   >gtk    -> GTK 

 " gtk_server_connect {$GTK}  clicked   3 "   >gtk  .GTK$ 

 " glade_xml_get_widget {$XML} button4 "   >gtk    -> GTK 

 " gtk_server_connect {$GTK}  clicked   4 "   >gtk  .GTK$   

 " glade_xml_get_widget {$XML} button5 "   >gtk    -> GTK 

 " gtk_server_connect {$GTK}  clicked   5 "   >gtk  .GTK$  

 " glade_xml_get_widget {$XML} entry " >gtk -> WD
 
 " gtk_entry_set_text {$WD} -- "  >gtk .gtk$ 
 

\   ------------------------------------------------------------------

 
 do
 "  gtk_server_callback  wait "  >gtk
    str@ swap dup @ \ read the value of the button 
   CASE
		49 OF  " gtk_entry_set_text {$WD} Hello! "  >gtk .gtk$ ENDOF \ 49 ascii for 1
		50 OF  " gtk_entry_set_text {$WD} ForthWin " >gtk .gtk$ ENDOF
		51 OF  " gtk_entry_set_text {$WD} Michel " >gtk .gtk$ ENDOF
		52 OF  " gtk_entry_set_text {$WD} 1.0 " >gtk .gtk$ ENDOF
		53 OF  " gtk_server_exit "  >gtk  .gtk$ ENDOF
	ENDCASE
	
 loop
;

TEST-GLADE

\EOF