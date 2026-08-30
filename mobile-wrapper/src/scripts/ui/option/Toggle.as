package ui.option
{
   import flash.display.SimpleButton;
   import flash.events.*;
   import flash.text.TextField;
   import util.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol76")]
   public class Toggle extends Option
   {
      
      public var stateTxt:TextField;
      
      public var buttonLeft:SimpleButton;
      
      public var buttonRight:SimpleButton;
      
      private var toggleLabels:Array;
      
      private var index:int = 0;
      
      public function Toggle(key:String, defaultValue:int, label:String, info:String, visible:Boolean, toggleLabels:Array = null, onChange:Function = null, onFrameChange:Function = null, onOverlayStateChange:Function = null)
      {
         super(key,label,info,visible,onChange,onFrameChange,onOverlayStateChange);
         this.toggleLabels = toggleLabels;
         this.index = this.key != null ? int(HelperSetting.getInt(this.key,defaultValue)) : defaultValue;
         this.syncState();
         this.buttonLeft.addEventListener(MouseEvent.CLICK,this.onLeft,false,0,true);
         this.buttonRight.addEventListener(MouseEvent.CLICK,this.onRight,false,0,true);
      }
      
      public function getIndex() : int
      {
         return this.index;
      }
      
      public function setIndex(i:int) : void
      {
         this.index = i % this.toggleLabels.length;
         this.syncState();
      }
      
      private function syncState() : void
      {
         this.stateTxt.text = this.toggleLabels[this.index];
      }
      
      private function onLeft(e:MouseEvent) : void
      {
         this.index = (this.index - 1 + this.toggleLabels.length) % this.toggleLabels.length;
         HelperSetting.setInt(this.key,this.index);
         this.syncState();
         if(onChange != null)
         {
            onChange(this);
         }
      }
      
      private function onRight(e:MouseEvent) : void
      {
         this.index = (this.index + 1) % this.toggleLabels.length;
         HelperSetting.setInt(this.key,this.index);
         this.syncState();
         if(onChange != null)
         {
            onChange(this);
         }
      }
   }
}

