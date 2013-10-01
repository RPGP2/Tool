#!ruby
# -*- coding: windows-31j -*-

=begin
WSBuildWindowは、WSモジュールに含まれる、
一行でGUIウィンドウを作成し、一行でその返り値を取り出せるようにするクラス。
DXRubyWSとStandardGUIをrequireしているファイルからrequireして使用。
WSLabel, WSTextBox, WSButton対応。
使い方は簡単。以下、リファレンス。
--------
WS::WSBuildWindow.new(caption, *args)
  題名と内容をそのまま指定してGUIウィンドウを作成する。
  
  caption (String)
    Windowの題名を指定。何も入れないと「WindowTitle」となる。
  args (String, Array, WSCr)
    GUIウィンドウに加えるコントロールを順に指定する。何個でも可。
    
    WSLabelを加える場合、文字列のみを渡す。
    
    WSTextBoxを加える場合、[①コントロールの名前, ②:textbox(, ③整数か文字列, ④生成したコントロールで実行するProcオブジェクト)]の配列を渡す。
      ①はSymbolオブジェクトで。
      ②は固定。
      ③にIntegerオブジェクトを指定するとWSTextBoxの横幅にそのまま(px単位で)設定する。文字列を指定するとその長さがちょうど入る横幅にする。何も入れないと100(px)となる。
      ④を渡すと、コントロール生成後すぐにそのコントロールを引数として渡して実行される。
    
    WSButtonを加える場合、[①コントロールの名前, ②:button, (③文字列, ④生成したコントロールで実行するコード)]の配列を渡す。
      ①はどんなオブジェクトでも良い。
      ②は固定。
      ③はそのままWSButtonに表示される。何も入れないと何も表示されない。
      ④を渡すと、コントロール生成後すぐにそのコントロールを引数として渡して実行される。
    
    定数WSCrを渡すと改行(それ以降のコントロールが1段下の左から追加)される

WS::WSBuildWindow#text(name)
  インスタンス生成時にWSTextBoxに指定した名前を渡すと、その@textが返される。
--------
「あくまで簡単に」なので少機能。改変自由とする。
サンプルが最後に有る。コメント範囲を解除して実行。
=end

WSCr = K_RETURN

class String
  def number?
    self =~ /^\d+$/
  end
end

module WS
  class WSBuildWindow
    def initialize(caption = "WindowTitle",*args)
      x = 0 #コントロールの配置場所管理
      y = 2 #↑同様
      xMax = 0 #生成したコントロールの端の位置を保持し、WSWindowのサイズに使用
      @controls = {}
      @labels = []
      f12 = Font.new(12) #Font#getWidth用。WSTextboxで必要
      f16 = Font.new(16) #Font#getWidth用。WSLabel,WSButtonで必要
      
      args.each do |obj|
        case obj.class.name
        when "String"
          #文章が送られて来たら、ラベル生成
          @labels.push(WS::WSLabel.new(x,y + 2,f16.getWidth(obj.force_encoding("windows-31j")),16,obj))
          x += f16.getWidth(obj) #次のコントロールの横位置をずらす
        when "Array"
          #配列が送られて来たら、コントロール作成
          case obj[1]
            when :textbox
              #WSTextBoxを指定
              case obj[2].class.name
              when "String"
                w = f12.getWidth(obj[2]) + 8
              when "Integer"
                w = obj[2]
              when "NilClass"
                w = 100
              end
              @controls[obj[0]] = WS::WSTextBox.new(x,y,w,20)
              obj[3].call(@controls[obj[0]]) if obj[3]
              x += w #次のコントロールの横位置をずらす
            when :button
              #WSButtonを指定
              @controls[obj[0]] = WS::WSButton.new(x + 1,y,f16.getWidth((obj[2] ? obj[2].force_encoding("windows-31j") : "")) + 4,20,(obj[2] ? obj[2].force_encoding("windows-31j") : ""))
              obj[3].call(@controls[obj[0]]) if obj[3]
              x += f16.getWidth((obj[2] ? obj[2] : "")) + 6
          end
        when "Fixnum"
          #数字が送られて来たら、WSCrなら改行(次の列に)する
          if obj == WSCr
            x = 0
            y += 21
          end
        end
        xMax = [xMax,x].max #コントロールの端の座標を更新
      end
      
      @window = WS::WSWindow.new(10,10,xMax + 6,y + 43,caption)
      @controls.each_key do |ky|
        if ky.class.name == "Symbol"
          @window.client.add_control(@controls[ky],ky)
        else
          @window.client.add_control(@controls[ky])
        end
      end
      @labels.each do |lb|
          @window.client.add_control(lb)
      end
      WS.desktop.add_control(@window)
    end
    
    def text(name)
      return @controls[name].text.force_encoding("windows-31j") if @controls[name].class.name == "WS::WSTextBox"
      return nil
    end
  end
end

=begin
#サンプルコード
i = ""
test = WS::WSBuildWindow.new("掛け算",
        [:a,:textbox,"1000"],"*",[:b,:textbox,"1000"],"=",[:c,:textbox,"Write Number!"],WSCr,
        [:submit,:button,"更新",Proc.new{|ctl|
  ctl.add_handler(:click) do
    ctl.parent.c.text = (ctl.parent.a.text.number? && ctl.parent.b.text.number? ? (ctl.parent.a.text.to_i * ctl.parent.b.text.to_i).to_s : "Write Number!")
  end
        }],[:end,:button,"終了",Proc.new{|ctl|
  ctl.add_handler(:click) do
    ctl.parent.parent.close
    throw :exit
  end
        }])

catch(:exit) do
  Window.gameloop do
    WS.update
  end
end
=end
