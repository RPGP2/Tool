# coding: sjis

#dxruby,dxrubyws,standardguiを読み込む事が前提
#フィールド、町、その他のあらゆるマップのクラスを定義

require "dxlibrary"

class Array
  def quarry(xRange, yRange)
    return self[xRange].map{|item| item.to_a[yRange]}
  end
  
  def quarry!(xRange, yRange)
    self.replace(self[xRange].map{|item| item.to_a[yRange]})
    return self
  end
  
  def join2D(divX, divY, &b)
    str = []
    self.each do |ary|
      str.push(ary.clone)
      str[-1].collect!{|obj| b.call(obj)} if b
      str[-1] = str[-1].join(divX)
    end
    str = str.join(divY)
    return str
  end
  
  def join2D!(divX, divY)
    self.replace(self.join2D(divX, divY))
    return self
  end
  
  def self.createFromImage(image)
    ary = []
    image.width.times do |x|
      image.height.times do |y|
        4.times do |i|
          ary << image[x,y][i]
        end
      end
    end
    return ary
  end
end

class String
  def split2D(divX, divY, &b)
    
  end
end

class Tip
  #チップ情報を集約するクラス
  #@sizeと@imageと@walkableを持つ。
  
  attr_accessor :walkable
  attr_reader :image
  
  def initialize(size, walkable = false)
    @size = size
    @image = Image.new(@size, @size)
    @walkable = walkable
  end
  
  def image=(v)
    w = [@size, v.width].min
    h = [@size, v.height].min
    @image.draw(0,0,v,0,0,w,h)
  end
  
  def to_s(divI = "+", div2 = "/")
    return Array.createFromImage(@image).join(divI) + div2 + (walkable ? "1" : "0")
  end
end

class Map
  #Mapクラスのインスタンスを作成する。が、ユーザの使用は想定していない。
  #ユーザは、Map.makeや.loadを使用する。
  def initialize(one, tate, yoko, m_gnd, m_fnt, walkable, tip)
    @one = one
    @tate = tate
    @yoko = yoko
    @m_gnd = m_gnd
    @m_fnt = m_fnt
    @walkable = walkable
    @tip = tip
  end
  
  #生成方法1:大きさとデフォルトの色を指定
  def self.make
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

    Map.new(sizeSet.text(:one).to_i,
      sizeSet.text(:tate).to_i,
      sizeSet.text(:yoko).to_i,
      Array.new(sizeSet.text(:yoko).to_i){Array.new(sizeSet.text(:tate).to_i){0}},
      Array.new(sizeSet.text(:yoko).to_i){Array.new(sizeSet.text(:tate).to_i){0}},
      Array.new(sizeSet.text(:yoko).to_i){Array.new(sizeSet.text(:tate).to_i){false}},
      Array.new(2500){Tip.new(sizeSet.text(:one).to_i)})
  end
  
  #生成方法2:*.mapを開く
  def self.load(filename)
    str = read(filename).split("\n")
    
    one = str[0].to_i
    tate = str[1].to_i
    yoko = str[2].to_i
    m_gnd = str[3].split("/")
  end
  
  #データのテキスト化
  def to_s
    str = Window.join("Mapファイルを文字列化しています。") do
      str = "#{@one}\n#{@tate}\n#{@yoko}\n" #大きさ
      str += @m_gnd.join2D("+","/") + "\n" #地面の配列
      str += @m_fnt.join2D("+","/") + "\n" #前面の配列
      str += @walkable.join2D("+","/"){|obj| obj ? 1 : 0} + "\n" #歩ける範囲の配列
      @tip.each do |obj|
        str += obj.to_s + "\n"
      end
      str
    end
    
    str
  end
end

Window.gameloop do
  Window.drawFont(0,0,"ニートなう!!",Font.new(20))
  if Input.x == 1
    a = Map.make
    a.to_s
    break
  end
end
