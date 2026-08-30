package engine
{
   import flash.display.*;
   import flash.events.*;
   
   public class AvatarRasterizer extends Rasterizer
   {
      
      public function AvatarRasterizer(avatar:*)
      {
         super();
         var source:MovieClip = avatar.mcChar;
         if(Pocket.IS_ANIMATION_OFF)
         {
            source.stopAllMovieClips();
         }
         if(!Pocket.IS_RASTERIZER_ON)
         {
            return;
         }
         _partsToMonitor = new <DisplayObject>[source.idlefoot,source.chest,source.weaponOff,source.frontthigh,source.cape,source.frontshoulder,source.weaponFistOff,source.head,source.backshoulder,source.hip,source.backthigh,source.backhair,source.weaponFist,source.backshin,source.weaponTemp,source.robe,source.weapon,source.frontshin,source.backfoot,source.backrobe,source.arrow,source.shield,source.frontfoot,source.backhand,source.fronthand,avatar.cShadow];
         avatar.addChild(this);
         this.addEventListener(Event.ENTER_FRAME,onTick,false,0,true);
      }
   }
}

