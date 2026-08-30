package ui.util
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol53")]
   public class Pagination extends MovieClip
   {
      
      public var fData:Object = {};
      
      public function Pagination()
      {
         super();
      }
      
      public function fClose() : void
      {
         this.fData = null;
         parent.removeChild(this);
      }
   }
}

