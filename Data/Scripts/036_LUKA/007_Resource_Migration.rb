class MigrationScene

def pbStartScene
 @sprites={}
 @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
 @viewport.z=99999
 @views=Viewport.new(0,75,512,(384-75))
  @views.z=@viewport.z
  @views2=Viewport.new(0,0,512,384)
  @views2.z=@viewport.z
 @frame=0
 pbFadeInAndShow(@sprites)
end

def pbEndScene
  @viewport.dispose
end        

def pbUpdate
  $mouse.update
  Graphics.update
  Input.update
  @count+=1
  @frame+=1 if @count>7
  @count=0 if @count>7
  @frame=0 if @frame>3
  for j in 0...6
    if @sprites["pokemon#{j}"]
      @sprites["pokemon#{j}"].src_rect.set(@width[j]*@frame,0,@width[j],@height[j])
    end
  end
end

def wait(value)
  (value).times do
  pbUpdate
  pbWait(1)
  end
end


def pbPlacePokemon
  @sprites["pokemon#{@index}"]=Sprite.new(@viewport)
  @sprites["pokemon#{@index}"].z=99999
  @sprites["pokemon#{@index}"].bitmap=BitmapCache.load_bitmap(sprintf("Graphics/Characters/%03d.png",@temptrainer.party[@index].species))
  @width[@index]=(@sprites["pokemon#{@index}"].bitmap.width/4)
  @height[@index]=(@sprites["pokemon#{@index}"].bitmap.height/4)
  @sprites["pokemon#{@index}"].src_rect.set(0,0,@width[@index],@height[@index])
  @sprites["pokemon#{@index}"].ox=@width[@index]/2
  @sprites["pokemon#{@index}"].oy=@height[@index]
  @sprites["pokemon#{@index}"].x=@x[@index]+2
  @sprites["pokemon#{@index}"].y=@y[@index]+4
  @sprites["pokemon#{@index}"].opacity=0
  
  10.times do
    @sprites["pokemon#{@index}"].opacity+=15.5
    wait(1)
  end
  
end

  
def pbAddImportedPokemon(pokemon)
  if pbBoxesFull?
   Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
   Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
   return false
  end
  Kernel.pbMessage(_INTL("{1} obtained {2}!\1",$Trainer.name,pokemon.name))  
  if pbBoxesFull?
   Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
   Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
   return
  end
  temp=pokemon
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  mean = rand(1..5)   if $Trainer.numbadges == 0
  mean = rand(10..21) if $Trainer.numbadges == 1
  mean = rand(17..24) if $Trainer.numbadges == 2
  mean = rand(20..29) if $Trainer.numbadges == 3
  mean = rand(30..43) if $Trainer.numbadges == 4
  mean = rand(35..43) if $Trainer.numbadges == 5
  mean = rand(40..47) if $Trainer.numbadges == 6
  mean = rand(40..55) if $Trainer.numbadges == 7
  mean = rand(50..75) if $Trainer.numbadges == 8
  pokemon.level = mean
  Kernel.pbMessage(_INTL("{1} will now be level {2}!\1",pokemon.name,pokemon.level))
  pokemon.calcStats
  pokemon.ballused=13
  pbStorePokemon(pokemon)
  return true
end

def pbMigration(temp)
  @sprites={}
  
  @bg=Sprite.new(@viewport)
  @bg.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/Migratebg.png")
  @bg.z=99999
  @bg.ox=300
  @bg.x=300
  @bg.oy=410
  @bg.y=410
  @bg.zoom_x=0
  @bg.zoom_y=0
  @close=Sprite.new(@viewport)
  @close.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/UIClose.png")
  @close.x=23
  @close.y=21
  @close.z=99999
  @close.opacity=80
  @close.visible=false
  @ball=Sprite.new(@viewport)
  @ball.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/ball00.png")
  @ball.ox=46/2
  @ball.oy=66
  @ball.z=99999
  
  10.times do
    @bg.zoom_x+=0.1
    @bg.zoom_y+=0.1
    pbWait(1)
  end
  @close.visible=true
  
  $screensel=1
  
  @youtrainer=$Trainer
  savefile="Migration/Game.rxdata"
  File.open(savefile){|f|
    $Trainer=Marshal.load(f)
    }
  @temptrainer=$Trainer
  $Trainer=@youtrainer
  
  @y=[250,250,250,250,250,250]
  @x=[53,106,159,212,265,318]
  
  @frame=0
  @count=0
  @index=0
  @width=[0,0,0,0,0,0]
  @height=[0,0,0,0,0,0]
  
  (@temptrainer.party.length).times do
    pbPlacePokemon 
    @index+=1
  end
  
  loop do
    pbUpdate
    
     for i in 0...6
       
       if @sprites["pokemon#{i}"] && @sprites["pokemon#{i}"].visible==true && pbMouseInArea?(@sprites["pokemon#{i}"].x-(@width[i]/2),@sprites["pokemon#{i}"].y-(@height[i]/2),@width[i],@height[i])
         @sprites["pokemon#{i}"].opacity+=10 if @sprites["pokemon#{i}"].opacity<255
         
          if Input.pressed(Input::Mouse_Left) 
           @ball.x=@sprites["pokemon#{i}"].x
           20.times do
             @ball.y+=@y[i]/20
             wait(1)
           end
           @ball.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/ball00_open.png")
           wait(4)
           @ball.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/ball00.png")
           c=0
           10.times do
             c+=25.5
             @sprites["pokemon#{i}"].y-=5
             @sprites["pokemon#{i}"].tone=Tone.new(c,c,c)
             @sprites["pokemon#{i}"].zoom_x-=0.1
             @sprites["pokemon#{i}"].zoom_y-=0.1
             wait(1)
           end
           @ball.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/ball00.png")
           wait(12)
           4.times do
             @ball.y+=10
             wait(1)
           end
           5.times do
             @ball.y-=4
             wait(1)
           end
           4.times do
             @ball.y+=5
             wait(1)
           end
           wait(12)
           yvalue=@ball.y-38
           @ball.oy=28
           @ball.y=yvalue
           5.times do
             @ball.angle-=8
             wait(1)
           end
           5.times do
             @ball.angle+=8
             wait(1)
           end
           wait(12)
           5.times do
             @ball.angle+=8
             wait(1)
           end
           5.times do
             @ball.angle-=8
             wait(1)
           end
           wait(12)
           5.times do
             @ball.angle-=8
             wait(1)
           end
           5.times do
             @ball.angle+=8
             wait(1)
           end
           wait(12)
           c=255
           @ball.tone=Tone.new(c,c,c)
           5.times do
             c-=51
             @ball.tone=Tone.new(c,c,c)
             wait(1)
           end
           wait(12)
           pbAddImportedPokemon(@temptrainer.party[i])
           @sprites["pokemon#{i}"].visible=false
           10.times do
             @ball.opacity-=25.5
             wait(1)
           end
             @ball.y=0
             @ball.oy=66
             @ball.opacity=255
           break
          end
         
       else
         @sprites["pokemon#{i}"].opacity-=10 if @sprites["pokemon#{i}"] && @sprites["pokemon#{i}"].opacity>155
       end
       
     end
     
     
     if pbMouseLeftClick?(@close,61,61)
        break
     end
  end
  
  $screensel=0
end


end

class Migration

def initialize(scene)
 @scene=scene
end

def pbStartScreen(temp)
 @scene.pbStartScene
 @scene.pbMigration(temp)
 @scene.pbEndScene
end
end

def pbPokemonMigration
  scene=MigrationScene.new
  screen=Migration.new(scene)
  screen.pbStartScreen(nil)
end