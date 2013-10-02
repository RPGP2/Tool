# coding: sjis

#「お待ちください」的なウィンドウを出しとく。

module Window
  def join(content = "処理中です。しばらくお待ちください。", &b)
    jobEnd = false
    
    thread = Thread.new{
      result = b.call
      jobEnd = true
      result
    }
    
    font = Font.new(12)
    old_cap = Window.caption
    Window.caption = "処理中"
    while !jobEnd do
      Window.gameloop do
        Window.drawFont((Window.width - font.getWidth(content)) / 2,(Window.height - 12) / 2, content, font)
        break if jobEnd
      end
    end
    Window.caption = old_cap
    
    thread.value
  end
end
