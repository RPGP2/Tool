# coding: sjis

#dxruby,dxrubyws,standardguiを読み込む事が前提
#フィールド、町、その他のあらゆるマップのクラスを定義

require "dxlibrary"

class Map
  #生成方法1:大きさとデフォルトの色を指定
  def initialize
    sizeSet = WS::WSBuildWindow.new("Mapサイズ指定",
      "1チップの大きさ:",[:one,:textbox,"1000"],"px",WSCr,
      "縦",[:tate,:textbox,"1000"],"マス×横",[:yoko,:textbox,"1000"],"マス",WSCr,
      [:submit,:button,"決定",Proc.new{|ctl|
        ctl.add_handler(:click) do
          if ctl.parent.one.text.number? && ctl.parent.tate.text.number? && ctl.parent.yoko.text.number? &&
              ctl.parent.one.text.to_i > 0 && ctl.parent.tate.text.to_i > 0 && ctl.parent.yoko.text.to_i > 0
            ctl.parent.parent.close
            throw :complete
          else
            WS.desktop.add_control(WS::WSMessageBox.new("Mapサイズ指定", "全てのTextBoxに、0以上の整数を入力してください"))
          end
        end
      }])
    
    old_cap = Window.caption
    catch(:complete) do
      Window.caption = "Mapサイズ指定"
      Window.gameloop do
        WS.update
      end
    end
    Window.caption = old_cap
    
    #ここで必要なデータは揃う
    @one, @tate, @yoko = sizeSet.text(:one).to_i, sizeSet.text(:tate).to_i, sizeSet.text(:yoko).to_i
    @m_gnd = Image.new(@one * @yoko, @one * @tate)
    @m_fnt = Image.new(@one * @yoko, @one * @tate)
    @walkable = Array.new(@yoko)
    @tip = Array.new(@yoko)
    @tile = Array.new(@yoko)
    @yoko.times do |i|
      @walkable[i] = Array.new(@tate)
      @tip[i] = Array.new(@tate)
      @tile[i] = Array.new(@tate)
      @tate.times do |j|
        @walkable[i][j] = false
        @tip[i][j] = 0
        @tile[i][j] = 0
      end
    end
  end
  
  #生成方法2:*.mapを開く
  def self.load
    
  end
end

Window.gameloop do
  Window.drawFont(0,0,"ニートなう!!",Font.new(20))
  a = Map.new if Input.x == 1
end
