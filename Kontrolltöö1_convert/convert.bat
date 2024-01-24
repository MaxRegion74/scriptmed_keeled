@echo off
setlocal ENABLEDELAYEDEXPANSION

set "str=%~1"
set "strCopy=!str!"

set "str=!str:ö=^&ouml;!"
set "str=!str:Ö=^&Ouml;!"
set "str=!str:ä=^&auml;!"
set "str=!str:Ä=^&Auml;!"
set "str=!str:ü=^&uuml;!"
set "str=!str:Ü=^&Uuml;!"
set "str=!str:õ=^&otilde;!"
set "str=!str:Õ=^&Otilde;!"
set "str=!str:š=^&scaron;!"
set "str=!str:Š=^&Scaron;!"
set "str=!str:ž=^&zcaron;!"
set "str=!str:Ž=^&Zcaron;!"

echo.
echo !str!
echo.

set "position=0"
set "tally=0"

:count
set "char=!strCopy:~%position%,1!"
if defined char (
    set /a tally+=1
    set /a charAmount[!char!]+=1
    set /a position+=1
    goto count
)

if %tally% GTR 0 (
    echo Vahetatud:
    echo.

    for /l %%i in (0, 1, 11) do (
        set "char=!charAmount[%%i]!"
        if !char! GTR 0 (
            echo !char! is !charAmount[%%i]!
        )
    )

    echo Kokku: %tally%
) else (
    echo Ei leidnud ühtegi täpitähte.
)

endlocal
