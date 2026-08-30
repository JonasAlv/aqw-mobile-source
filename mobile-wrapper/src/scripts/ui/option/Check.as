package ui.option
{
   import flash.display.Sprite;
   import flash.events.*;
   import util.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol64")]
   public class Check extends Option
   {
      
      public var state:Boolean;
      
      public var checkMark:Sprite;
      
      public var checkBackground:Sprite;
      
      public function Check(key:String, defaultValue:Boolean, name:String, info:String, visible:Boolean, onChange:Function = null, onFrameChange:Function = null, onOverlayStateChange:Function = null)
      {
         super(key,name,info,visible,onChange,onFrameChange,onOverlayStateChange);
         this.state = this.key != null ? Boolean(HelperSetting.getBool(this.key,defaultValue)) : defaultValue;
         this.syncState();
         this.checkMark.mouseEnabled = false;
         this.checkBackground.addEventListener(MouseEvent.CLICK,this.onToggle,false,0,true);
      }
      
      public function syncState() : void
      {
         this.checkMark.visible = this.state;
      }
      
      public function onToggle(e:MouseEvent = null) : void
      {
         this.state = !this.state;
         if(this.key != null)
         {
            HelperSetting.setBool(this.key,this.state);
         }
         if(this.onChange != null)
         {
            this.onChange(this);
         }
         this.syncState();
      }
   }
}

