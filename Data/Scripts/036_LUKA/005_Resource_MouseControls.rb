def pbMouseOver?(image,width=-1,height=-1)
    width=image.bitmap.width if width==-1
    height=image.bitmap.height if height==-1
    if $mouse.x >= image.x && $mouse.x <= (image.x + width) and $mouse.y >= image.y && $mouse.y <= (image.y + height)
      return true
    else
      return false
    end
end
  
def pbMouseInArea?(x,y,width,height)
    if $mouse.x >= x && $mouse.x <= (x + width) and $mouse.y >= y && $mouse.y <= (y + height)
      return true
    else
      return false
    end
end
  
def pbMouseInAreaLeft?(x,y,width,height)
    if $mouse.x >= x && $mouse.x <= (x + width) and $mouse.y >= y && $mouse.y <= (y + height) && Input.pressed(Input::Mouse_Left)
      return true
    else
      return false
    end
end
  
def pbMouseInAreaRight?(x,y,width,height)
    if $mouse.x >= x && $mouse.x <= (x + width) and $mouse.y >= y && $mouse.y <= (y + height) && Input.pressed(Input::Mouse_Right)
      return true
    else
      return false
    end
end
  
def pbMouseLeftClick?(image,width=-1,height=-1)
    width=image.bitmap.width if width==-1
    height=image.bitmap.height if height==-1
    if $mouse.x >= image.x && $mouse.x <= (image.x + width) and $mouse.y >= image.y && $mouse.y <= (image.y + height) && Input.pressed(Input::Mouse_Left)
      return true
    else
      return false
    end
end

def pbMouseRightClick?(image,width=-1,height=-1)
    width=image.bitmap.width if width==-1
    height=image.bitmap.height if height==-1
    if $mouse.x >= image.x && $mouse.x <= (image.x + width) and $mouse.y >= image.y && $mouse.y <= (image.y + height) && Input.pressed(Input::Mouse_Right)
      return true
    else
      return false
    end
end
