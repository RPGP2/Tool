# coding: sjis

require "rclip"

print "クリップボードにある文字列をRubyスクリプトとして実行します。\n\n"

eval(Rclip.getData.encode("Shift_JIS"))

print "\n\n終了です。"
