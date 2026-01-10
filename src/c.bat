echo COMPILED CX16 STREE
rem java.exe -jar C:\8bitProgramming\prog8\prog8c-11.4.1-all.jar -target cx16 stree.p8
del stree.prg
del ..\stree.prg
java.exe -jar C:\8bitProgramming\prog8\prog8c-12.0.1-all.jar -target cx16 stree.p8
rem pause
copy stree.prg ..\stree.prg
del stree.asm
del stree.vice*.*
rem x16noCard1x.bat

