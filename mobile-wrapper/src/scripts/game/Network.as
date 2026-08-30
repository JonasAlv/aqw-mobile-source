package game
{
   import flash.display.*;
   import util.*;
   
   public class Network
   {
      
      private var pocket:Pocket;
      
      public function Network(pocket:Pocket)
      {
         super();
         this.pocket = pocket;
         this.pocket.game.sfc.addEventListener("onExtensionResponse",this.onExtensionResponseHandler,false,0,true);
      }
      
      private function onExtensionResponseHandler(event:*) : void
      {
         switch(event.params.type)
         {
            case "str":
               switch(event.params.dataObj[0])
               {
                  case "whisper":
               }
               break;
            case "json":
               switch(event.params.dataObj.cmd)
               {
                  case "sAct":
                     this.sAct();
               }
         }
      }
      
      private function sAct() : void
      {
         var icon:Sprite = null;
         var actBar:Sprite = this.pocket.game.ui.mcInterface.actBar;
         for(var i:int = 0; i < 6; i++)
         {
            icon = Sprite(actBar.getChildByName("i" + (i + 1)));
            if(icon != null)
            {
               this.pocket.gameUI.layoutController.register(HelperSetting.LAYOUT_SKILL_BAR + "_i" + (i + 1),icon,icon.x,icon.y,icon.scaleX,icon.scaleY);
            }
         }
         this.pocket.gameUI.layoutController.load();
      }
   }
}

