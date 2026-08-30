package ui.option
{
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol11")]
   public class Menu extends Sprite
   {
      
      public var button:SimpleButton;
      
      public var buttonTxt:TextField;
      
      public var options:Vector.<Option> = null;
      
      public function Menu(buttonLabel:String, options:Vector.<Option>)
      {
         super();
         this.buttonTxt.text = buttonLabel;
         this.options = options;
         this.buttonTxt.mouseEnabled = false;
         this.button.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         this.__setTab_buttonTxt_Símbolo1_Camada1_0();
      }
      
      private function onClick(e:MouseEvent) : void
      {
         Pocket.SINGLETON.overlay.selectMenu(this);
      }
      
      internal function __setTab_buttonTxt_Símbolo1_Camada1_0() : *
      {
         this.buttonTxt.tabIndex = 1;
      }
   }
}

