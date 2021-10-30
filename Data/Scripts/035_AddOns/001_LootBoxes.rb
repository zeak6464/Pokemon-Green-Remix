#Script de lootboxes creado por Nyaruko
#Si metes micropagos no me hago responsable

COMUNES = [:POTION,:POKEBALL,:ANTIDOTE]
RAROS = [:FIRESTONE,:WATERSTONE,:LEAFSTONE,:THUNDERSTONE,:MOONSTONE,:SUNSTONE,:DUSKSTONE,:DAWNSTONE,:ICESTONE,:SHINYSTONE]
LEGENDARIOS = [:FORCESTONE,:DEFORCESTONE,:RANDOMSTONE]
EPICOS = [:RARECANDY,:DELTASTONE,:TYPESTONE,:ABILITYSTONE,:MOVESTONE]


  def randomItemBall
    viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z=99999
    random1=rand(100)
    random2=rand(100)
    random3=rand(100)
    pbSetViableDexes
    select = 0
    comunes = COMUNES
    raros = RAROS
    legendarios = LEGENDARIOS
    epicos = EPICOS
    sprites={}
    sprites["bg"]=Sprite.new
    sprites["bg"].z=99998
    sprites["bg"].bitmap= BitmapCache.load_bitmap("Graphics/Pictures/Lootboxes/background")
    
    sprites["bolsa"]=IconSprite.new(0,0,viewport)
    sprites["bolsa"].setBitmap("Graphics/Pictures/Lootboxes/bag_closed")
    sprites["bolsa"].x =157
    sprites["bolsa"].y =256
    
    sprites["item1"]=IconSprite.new(0,0,viewport)    
    sprites["item1"].x = 227
    sprites["item1"].y = 135
    
    sprites["item2"]=IconSprite.new(0,0,viewport)    
    sprites["item2"].x = 99
    sprites["item2"].y = 135
    
    sprites["item3"]=IconSprite.new(0,0,viewport)    
    sprites["item3"].x = 355
    sprites["item3"].y = 135
    
    
    sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    
    loop do
      Graphics.update
      Input.update
      #if Input.trigger?(Input::C)
        pbSEPlay("select")
        pbWait(20)
        sprites["bolsa"].setBitmap("Graphics/Pictures/Lootboxes/bag_open")
        #Item 1
        if random1 <= 40
          sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_comun")
          pbWait(20)
          item1=rand(comunes.length)
          Kernel.pbReceiveItem(comunes[item1])
        elsif random1 <= 70 && random1 > 40
          sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_raro")
          pbWait(20)
          item1=rand(raros.length)
          Kernel.pbReceiveItem(raros[item1])
        elsif random1 <= 90 && random1 > 70
          sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_legend")
          pbWait(20)
          item1=rand(legendarios.length)
          Kernel.pbReceiveItem(legendarios[item1])
        else
          sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_epico")
          pbWait(20)
          item1=rand(epicos.length)
          Kernel.pbReceiveItem(epicos[item1])
        end
        #Item 2
        if random2 <= 40
          sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_comun")
          pbWait(20)
          leng = 
          item2=rand(comunes.length)
          Kernel.pbReceiveItem(comunes[item2])
        elsif random2 <= 70 && random2 > 40
          sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_raro")
          pbWait(20)
          item2=rand(raros.length)
          Kernel.pbReceiveItem(raros[item2])
        elsif random2 <= 90 && random2 > 70
          sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_legend")
          pbWait(20)
          item2=rand(legendarios.length)
          Kernel.pbReceiveItem(legendarios[item2])
        else
          sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_epico") 
          pbWait(20)
          item2=rand(epicos.length)
          Kernel.pbReceiveItem(epicos[item2])
        end
        #Item 3
        if random3 <= 40
          sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_comun")
          pbWait(20)
          item3=rand(comunes.length)
          Kernel.pbReceiveItem(comunes[item3])
        elsif random3 <= 70 && random3 > 40
          sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_raro")
          pbWait(20)
          item3=rand(raros.length)
          Kernel.pbReceiveItem(raros[item3])
        elsif random3 <= 90 && random3 > 70
          sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_legend") 
          pbWait(20)
          item3=rand(legendarios.length)
          Kernel.pbReceiveItem(legendarios[item3])
        else
          sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_epico")
          pbWait(20)
          item3=rand(epicos.length)
          Kernel.pbReceiveItem(epicos[item3])
        end
         pbWait(10)
          pbFadeOutAndHide(sprites){pbUpdateSpriteHash(sprites)}
          pbDisposeSpriteHash(sprites)
          viewport.dispose if viewport
          break
    end  
  end