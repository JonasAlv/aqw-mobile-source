package ui
{
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol29")]
   public class Notification extends Sprite
   {
      
      public var messageTxt:TextField;
      
      public var closeBtn:SimpleButton;
      
      public function Notification(message:String)
      {
         super();
         this.messageTxt.htmlText = message;
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.onClose,false,0,true);
      }
      
      private function onClose(e:MouseEvent) : void
      {
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
      }
   }
}

