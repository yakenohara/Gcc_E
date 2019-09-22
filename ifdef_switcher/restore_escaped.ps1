$sakuraExeAbusolutePath = "C:\Program Files (x86)\sakura\sakura.exe"
$searchDir = $Args[0]

Write-Host $searchDir

#変換Array
#("変換前正規表現文字列","変換後正規表現文字列")
$substitutions = @(
  ("{% vacant_line %}`"(.*)`"{% vacant_line %}", "\1"),
  ("{% define %}`"(.*)`"{% define %}", "#\1define"),
  ("{% include %}`"(.*)`"{% include %}", "#\1include"),
  ("{% error %}`"(.*)`"{% error %}", "#\1error"),
  ("{% pragma %}`"(.*)`"{% pragma %}", "#\1pragma")
)

#ディレクトリ存在チェック
if (-Not(Test-Path $searchDir)){ #存在しない場合
    echo ("directory not exit `""+ $searchDir +"`"")
    exit #終了
}

#Grep置換
$counter = 1
$substitutions | foreach{
    
    #progress表示
    echo ("processing " + $counter + "/" + $substitutions.Length + ", GKEY=`"" + $_[0] + "`"")

    #Grep置換実行    
    $sakuraObj = Start-Process -FilePath $sakuraExeAbusolutePath `
                               -ArgumentList "-GREPMODE", `
                                             ("-GKEY=`"" + $_[0] + "`""), `
                                             ("-GREPR=`"" + $_[1] + "`""), `
                                             "-GFILE=`"*.c *.h`"", `
                                             ("-GFOLDER=`"" + $searchDir + "`""), `
                                             "-GOPT=SRP1U" `
                               -PassThru
                               
    Wait-Process -ID $sakuraObj.Id
    
    $counter++ #progress表示用counter
} 

echo "Done!"
