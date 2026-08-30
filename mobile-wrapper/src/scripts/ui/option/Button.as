package ui.option
{
   import flash.display.SimpleButton;
   import flash.events.*;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol57")]
   public class Button extends Option
   {
      
      public var button:SimpleButton;
      
      public var buttonTxt:TextField;
      
      public function Button(key:String, name:String, info:String, buttonLabel:String, onChange:Function = null, onFrameChange:Function = null, onOverlayStateChange:Function = null)
      {
         super(key,name,info,true,onChange,onFrameChange,onOverlayStateChange);
         this.buttonTxt.text = buttonLabel;
         this.buttonTxt.mouseEnabled = false;
         this.button.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
      }
      
      private function onClick(e:MouseEvent) : void
      {
         if(onChange != null)
         {
            onChange(this);
         }
      }
   }
}

