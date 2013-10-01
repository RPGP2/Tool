echo off
ruby -e 'print "クリップボードにある文字列をRubyスクリプトとして実行します。\n\nクリップボードの内容--------------------\n";rcode = Rclip.getData;print rcode.force_encoding("sjis") + "\n----------------------------------------\n\n実行結果--------------------------------\n";eval(rcode);print "\n----------------------------------------\n\n終了です。\n\n"'
pause
