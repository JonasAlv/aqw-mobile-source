package controller.walk
{
   import flash.errors.*;
   
   public class WalkController
   {
      
      protected var pocket:Pocket;
      
      protected var frameTick:int = 0;
      
      public function WalkController(pocket:Pocket)
      {
         super();
         this.pocket = pocket;
      }
      
      public function update() : void
      {
         throw new IllegalOperationError("Must override update Function");
      }
      
      public function stop() : void
      {
         throw new IllegalOperationError("Must override stop Function");
      }
   }
}

