@echo off
setlocal enabledelayedexpansion

:: Define the path to LM Studio's internal model index cache
set "cacheFile=%USERPROFILE%\.lmstudio\.internal\model-index-cache.json"
set count=1

echo Local models in LM Studio
echo ------------------------

:: Check if the cache file exists before proceeding
if not exist "%cacheFile%" (
    echo [!] Error: model-index-cache.json not found.
    goto :end
)

:: Parse the JSON cache file to find model identifiers and directory paths
:: We use findstr to isolate keys and then clean the strings of quotes and commas
for /f "tokens=1,* delims=:" %%a in ('findstr /i "originalIndexedModelIdentifier containingDirAbsolutePath" "%cacheFile%"') do (
    set "key=%%~a"
    set "val=%%~b"
    set "key=!key: =!"
    set "key=!key:"=!"
    set "val=!val: =!"
    set "val=!val:"=!"
    set "val=!val:,=!"

    :: Store the absolute path when found
    if "!key!"=="containingDirAbsolutePath" (
        set "nextPath=!val!"
    )

    :: Store the model ID and filter out internal/hub models to show only local ones
    if "!key!"=="originalIndexedModelIdentifier" (
        if not "!nextPath!"=="" (
            echo !nextPath! | findstr /i /c:"/hub/" >nul
            if !errorlevel! neq 0 (
                echo !nextPath! | findstr /i /c:".internal" >nul
                if !errorlevel! neq 0 (
                    if not defined seen["!nextPath!"] (
                        call :GetFileName "!val!" fileName
                        set "model[!count!].id=!fileName!"
                        set "model[!count!].path=!nextPath!"
                        echo !count!. !fileName!
                        set "seen["!nextPath!"]=1"
                        set /a count+=1
                    )
                )
            )
            set "nextPath="
        )
    )
)

:: Handle cases where no valid local models were parsed
set /a maxCount=count-1
if !maxCount! equ 0 (
    echo [!] No models found.
    goto :end
)

echo.
set /p choice="Enter model number to select: "

:: Validate user selection against the list count
if "!choice!"=="" goto :end
if !choice! geq 1 if !choice! leq !maxCount! (
    echo -----------------------------------
    echo Model ID:    !model[%choice%].id!
    echo Model Path:  !model[%choice%].path!
    echo -----------------------------------
) else (
    echo Invalid selection.
    goto :end
)

echo.
set /p userVirtName="Enter virtual model name: "

:: Convert forward slashes to backslashes and extract the base key for the YAML configuration
set "basePath=!model[%choice%].path!"
for %%A in ("!basePath:/=\!") do (
    for %%B in ("%%~dpA.") do (
        set "baseKey=%%~nxB/%%~nxA"
    )
)

:: Define and create the directory for the custom YAML configuration
set "yamlDir=%USERPROFILE%\.lmstudio\hub\models\custYAML\!userVirtName!"
if not exist "!yamlDir!" (
    mkdir "!yamlDir!"
)

:: Generate the model.yaml file with reasoning and history truncation toggles
(
echo model: custYAML/!userVirtName!
echo base: !baseKey!
echo metadataOverrides:
echo   domain: llm
echo   reasoning: true
echo customFields:
echo   - key: enableThinking
echo     displayName: Enable Thinking
echo     description: Toggle the reasoning block
echo     type: boolean
echo     defaultValue: true
echo     effects:
echo       - type: setJinjaVariable
echo         variable: enable_thinking
echo   - key: truncateHistoryThinking
echo     displayName: Truncate History Thinking
echo     description: Collapses think blocks in past messages to save context tokens.
echo     type: boolean
echo     defaultValue: true
echo     effects:
echo       - type: setJinjaVariable
echo         variable: truncate_history_thinking
) > "!yamlDir!\model.yaml"

echo.
echo -----------------------------------
echo Virtual model created successfully.
echo Location: !yamlDir!\model.yaml
echo -----------------------------------

echo Make sure to modify the Jinja template to utilize "enable_thinking" and "truncate_history_thinking"

goto :end

:: Subroutine to extract the file/folder name from a full path
:GetFileName
set "str=%~1"
:loop
if "!str:/=!" neq "!str!" (
    set "str=!str:*/=!"
    goto :loop
)
set "%~2=!str!"
exit /b

:end
pause



REM echo.
REM echo [ VIRTUAL MODELS ]
REM :: Reset 'seen' for the second pass so we don't skip models just because they were in the first pass
REM for /f "tokens=1,* delims==" %%v in ('set seen[ 2^>nul') do set "%%v="

REM for /f "tokens=1,* delims=:" %%a in ('findstr /i "originalIndexedModelIdentifier containingDirAbsolutePath" "%cacheFile%"') do (
    REM set "key=%%~a"
    REM set "val=%%~b"
    REM set "key=!key: =!"
    REM set "key=!key:"=!"
    REM set "val=!val: =!"
    REM set "val=!val:"=!"
    REM set "val=!val:,=!"

    REM if "!key!"=="containingDirAbsolutePath" (set "nextPath=!val!")
    REM if "!key!"=="originalIndexedModelIdentifier" (
        REM if not "!nextPath!"=="" (
            REM echo !nextPath! | findstr /i /c:"/hub/" >nul
            REM if !errorlevel! equ 0 (
                REM echo !nextPath! | findstr /i /c:".internal" >nul
                REM if !errorlevel! neq 0 (
                    REM if not defined seen["!nextPath!"] (
                        REM call :GetFileName "!val!" fileName
                        REM set "model[!count!].id=!fileName!"
                        REM set "model[!count!].path=!nextPath!"
                        REM echo !count!. !fileName!
                        REM echo     DIR: !nextPath!
                        REM set "seen["!nextPath!"]=1"
                        REM set /a count+=1
                    REM )
                REM )
            REM )
            REM set "nextPath="
        REM )
    REM )
REM )
