package util
{
   import flash.display.*;
   import flash.filters.*;
   
   public class Helper
   {
      
      public static const GRAYSCALE:ColorMatrixFilter = new ColorMatrixFilter([0.3,0.59,0.11,0,0,0.3,0.59,0.11,0,0,0.3,0.59,0.11,0,0,0,0,0,1,0]);
      
      public static const ORIENTATIONS:Array = [StageOrientation.DEFAULT,StageOrientation.DEFAULT,StageOrientation.ROTATED_LEFT,StageOrientation.ROTATED_RIGHT,StageOrientation.UPSIDE_DOWN];
      
      public static const RASTERIZER_LEVELS:Array = [1,1.5,2,3,0.5,0.1];
      
      public function Helper()
      {
         super();
      }
      
      public static function sanitize(s:String) : String
      {
         return s.replace(/[^a-zA-Z0-9]/g,"_");
      }
      
      public static function trimUrl(str:String) : String
      {
         if(str == null || str.length == 0)
         {
            return str;
         }
         var end:* = int(str.length - 1);
         if(str.charCodeAt(end) > 32)
         {
            return str;
         }
         while(end >= 0 && str.charCodeAt(end) <= 32)
         {
            end--;
         }
         return str.substring(0,end + 1);
      }
      
      public static function capitalizeFirstLetter(text:String) : String
      {
         return text == null || text.length == 0 ? text : text.charAt(0).toUpperCase() + text.slice(1);
      }
   }
}

