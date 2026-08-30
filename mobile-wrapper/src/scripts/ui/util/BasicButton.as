package ui.util
{
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol104")]
   public class BasicButton extends Sprite
   {
      
      public var button:SimpleButton;
      
      public var buttonTxt:TextField;
      
      public function BasicButton(buttonLabel:String)
      {
         super();
         this.buttonTxt.text = buttonLabel;
         this.buttonTxt.mouseEnabled = false;
         this.__setTab_buttonTxt_CópiadeSímbolo1_Camada1_0();
      }
      
      internal function __setTab_buttonTxt_CópiadeSímbolo1_Camada1_0() : *
      {
         this.buttonTxt.tabIndex = 1;
      }
   }
}

