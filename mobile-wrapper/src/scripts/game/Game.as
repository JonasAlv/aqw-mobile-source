package game
{
   import ui.option.Menu;
   import ui.option.Option;
   
   public class Game
   {
      
      public var currentFrame:String = "Game";
      
      private var pocket:Pocket;
      
      public function Game(pocket:Pocket)
      {
         super();
         this.pocket = pocket;
      }
      
      public function onFrameChange(frame:String) : void
      {
         var menu:Menu = null;
         var option:Option = null;
         this.currentFrame = frame;
         for each(menu in this.pocket.overlay.menus)
         {
            for each(option in menu.options)
            {
               if(option.onFrameChange != null)
               {
                  option.onFrameChange(frame);
               }
            }
         }
         this.pocket.overlay.setOverlayButtonTransform();
         this.pocket.game.setChildIndex(this.pocket.overlay,this.pocket.game.numChildren - 1);
         this.pocket.game.setChildIndex(this.pocket.gameUI,this.pocket.game.numChildren - 1);
      }
   }
}

