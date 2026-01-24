echo COMPILED CX16 STREE
del stree.prg
del ..\stree.prg
rem java.exe -jar C:\8bitProgramming\prog8\prog8c-12.1-SNAPSHOT-all.jar -target cx16 stree.p8
java.exe -jar C:\dev\CmdrX16\dos_tools\XFMGR\prog8c-12.1-SNAPSHOT-all.jar -target cx16 stree.p8
rem pause
copy stree.prg ..\stree.prg
del *.asm
del stree.vice*.*
rem x16noCard1x.bat

