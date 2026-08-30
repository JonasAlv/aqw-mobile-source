package game
{
   import flash.events.Event;
   
   public class World
   {
      
      private static const TICK_DISCORD_RPC:int = 150;
      
      private var pocket:Pocket;
      
      private var _tickDiscordRPC:int = 0;
      
      public function World(pocket:Pocket)
      {
         super();
         this.pocket = pocket;
      }
      
      public function setWorldFilters(filters:Array) : void
      {
         if(Boolean(this.pocket.game) && Boolean(this.pocket.game.world))
         {
            this.pocket.game.world.map.filters = filters;
            this.pocket.game.world.CHARS.filters = filters;
         }
      }
      
      public function onEnterFrame(event:Event) : void
      {
      }
   }
}

