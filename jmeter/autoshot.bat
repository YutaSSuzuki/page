@echo off
setlocal enabledelayedexpansion

:: 設定
set JMETER_PATH="C:\path\to\jmeter\bin\jmeter.bat"
set TEST_PLAN_DIR="C:\path\to\testplans"
set RESULT_DIR="C:\path\to\results"
set SHELL_SCRIPT="C:\path\to\remove_rampup.sh"  :: ランプアップ削除スクリプト
set ERROR_LOG="C:\path\to\error_summary.txt"

:: エラーログを初期化
echo エラー率1%%超過テスト一覧 > "%ERROR_LOG%"

:: ループでテストファイルを実行
for %%F in (%TEST_PLAN_DIR%\*.jmx) do (
    set TIMESTAMP=%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
    set TIMESTAMP=!TIMESTAMP: =0!

    set CURRENT_RESULT_DIR=%RESULT_DIR%\%%~nF_!TIMESTAMP!
    mkdir "!CURRENT_RESULT_DIR!"

    echo Running JMeter test: %%F
    %JMETER_PATH% -n -t "%%F" -l "!CURRENT_RESULT_DIR!\result.jtl" -j "!CURRENT_RESULT_DIR!\jmeter.log"

    :: ランプアップ削除スクリプトを実行（WSL 経由で Bash 実行）
    echo Running ramp-up cleanup script...
    wsl bash "%SHELL_SCRIPT%" "!CURRENT_RESULT_DIR!\result.jtl"

    :: JMeter可視化レポート作成
    echo Generating JMeter report...
    %JMETER_PATH% -g "!CURRENT_RESULT_DIR!\result.jtl" -o "!CURRENT_RESULT_DIR!\report"

    :: エラー率チェック
    echo Checking error rate...
    findstr /C=" s=" "!CURRENT_RESULT_DIR!\result.jtl" | find /C " s=\"false\"" > "!CURRENT_RESULT_DIR!\error_count.txt"
    findstr /C=" s=" "!CURRENT_RESULT_DIR!\result.jtl" | find /C " s=" > "!CURRENT_RESULT_DIR!\total_count.txt"

    set /p ERROR_COUNT=<"!CURRENT_RESULT_DIR!\error_count.txt"
    set /p TOTAL_COUNT=<"!CURRENT_RESULT_DIR!\total_count.txt"

    if %TOTAL_COUNT% GTR 0 (
        set /a ERROR_RATE=(%ERROR_COUNT%*100)/%TOTAL_COUNT%
        if %ERROR_RATE% GTR 1 (
            echo %%F (Error Rate: %ERROR_RATE%%) >> "%ERROR_LOG%"
        )
    )

    echo Test complete. Results stored in !CURRENT_RESULT_DIR!
    echo Waiting for 10 minutes...
    timeout /t 600 /nobreak >nul
)

echo All tests completed.
