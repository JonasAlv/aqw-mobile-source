package util
{
   import flash.display.*;
   
   public class HelperRasterizer
   {
      
      public function HelperRasterizer()
      {
         super();
      }
      
      public static function hasLabel(mc:MovieClip, label:String) : Boolean
      {
         var frameLabel:FrameLabel = null;
         for each(frameLabel in mc.currentLabels)
         {
            if(frameLabel.name == label)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function resetPlayback(container:DisplayObjectContainer) : void
      {
         if(container is MovieClip)
         {
            MovieClip(container).gotoAndPlay(1);
         }
         for(var i:int = 0; i < container.numChildren; i++)
         {
            if(container.getChildAt(i) is DisplayObjectContainer)
            {
               resetPlayback(DisplayObjectContainer(container.getChildAt(i)));
            }
         }
      }
      
      public static function simulateFrameAdvance(container:DisplayObjectContainer) : void
      {
         var mc:MovieClip = null;
         var nextF:int = 0;
         if(container is MovieClip)
         {
            mc = MovieClip(container);
            nextF = mc.currentFrame + 1;
            if(nextF > mc.totalFrames)
            {
               nextF = 1;
            }
            mc.gotoAndPlay(nextF);
         }
         for(var i:int = 0; i < container.numChildren; i++)
         {
            if(container.getChildAt(i) is DisplayObjectContainer)
            {
               simulateFrameAdvance(DisplayObjectContainer(container.getChildAt(i)));
            }
         }
      }
      
      public static function getMasterCycle(container:DisplayObjectContainer) : int
      {
         var counts:Array = [];
         findCounts(container,counts);
         if(counts.length == 0)
         {
            return 1;
         }
         var cycle:int = int(counts[0]);
         for(var i:int = 1; i < counts.length; i++)
         {
            cycle = int(lcm(cycle,counts[i]));
         }
         return cycle;
      }
      
      private static function findCounts(container:DisplayObjectContainer, list:Array) : void
      {
         var mc:MovieClip = null;
         if(container is MovieClip)
         {
            mc = MovieClip(container);
            if(mc.totalFrames > 1 && list.indexOf(mc.totalFrames) == -1)
            {
               list.push(mc.totalFrames);
            }
         }
         for(var i:int = 0; i < container.numChildren; i++)
         {
            if(container.getChildAt(i) is DisplayObjectContainer)
            {
               findCounts(DisplayObjectContainer(container.getChildAt(i)),list);
            }
         }
      }
      
      private static function lcm(a:int, b:int) : int
      {
         return a * b / gcd(a,b);
      }
      
      private static function gcd(a:int, b:int) : int
      {
         var temp:int = 0;
         while(b != 0)
         {
            temp = b;
            b = a % b;
            a = temp;
         }
         return a;
      }
   }
}

