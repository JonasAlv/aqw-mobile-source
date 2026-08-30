package engine
{
   import data.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import util.*;
   
   public class Rasterizer extends Sprite
   {
      
      protected var _bakedParts:Vector.<BakedPart> = new Vector.<BakedPart>();
      
      protected var _partsToMonitor:Vector.<DisplayObject>;
      
      public function Rasterizer()
      {
         super();
      }
      
      protected function bakePart(targetPart:MovieClip) : void
      {
         var isTimeline:Boolean = false;
         var i:int = 0;
         var bounds:Rectangle = null;
         var bmd:BitmapData = null;
         var matrix:Matrix = null;
         var marker:Sprite = null;
         if(!targetPart || targetPart.numChildren == 0 || targetPart.name == "hitbox" || Boolean(targetPart.getChildByName("bmp_cache")))
         {
            return;
         }
         isTimeline = Boolean(HelperRasterizer.hasLabel(targetPart,"Walk"));
         var totalFrames:int = Math.min(isTimeline ? targetPart.totalFrames : Number(HelperRasterizer.getMasterCycle(targetPart)),60);
         HelperRasterizer.resetPlayback(targetPart);
         var maxBounds:Rectangle = new Rectangle();
         for(i = 1; i <= totalFrames; i++)
         {
            bounds = targetPart.getBounds(targetPart);
            if(bounds.width > 0 && bounds.height > 0)
            {
               if(maxBounds.width == 0)
               {
                  maxBounds = bounds.clone();
               }
               else
               {
                  maxBounds = maxBounds.union(bounds);
               }
            }
            HelperRasterizer.simulateFrameAdvance(targetPart);
         }
         maxBounds.inflate(15 * Pocket.RASTERIZER_QUALITY_LEVEL,15 * Pocket.RASTERIZER_QUALITY_LEVEL);
         if(maxBounds.width <= 0 || maxBounds.width > 2000)
         {
            marker = new Sprite();
            marker.name = "bmp_cache";
            marker.visible = false;
            targetPart.addChild(marker);
            return;
         }
         var frames:Vector.<BitmapData> = new Vector.<BitmapData>();
         HelperRasterizer.resetPlayback(targetPart);
         for(i = 1; i <= totalFrames; i++)
         {
            bmd = new BitmapData(Math.ceil(maxBounds.width * Pocket.RASTERIZER_QUALITY_LEVEL),Math.ceil(maxBounds.height * Pocket.RASTERIZER_QUALITY_LEVEL),true,0);
            matrix = new Matrix();
            matrix.a = Pocket.RASTERIZER_QUALITY_LEVEL;
            matrix.d = Pocket.RASTERIZER_QUALITY_LEVEL;
            matrix.tx = -maxBounds.left * Pocket.RASTERIZER_QUALITY_LEVEL;
            matrix.ty = -maxBounds.top * Pocket.RASTERIZER_QUALITY_LEVEL;
            bmd.draw(targetPart,matrix,null,null,null,true);
            frames.push(bmd);
            HelperRasterizer.simulateFrameAdvance(targetPart);
         }
         for(var c:int = 0; c < targetPart.numChildren; c++)
         {
            targetPart.removeChildAt(c);
         }
         var bitmap:Bitmap = new Bitmap(frames[0]);
         bitmap.name = "bmp_cache";
         bitmap.smoothing = true;
         bitmap.x = maxBounds.left;
         bitmap.y = maxBounds.top;
         bitmap.scaleX = 1 / Pocket.RASTERIZER_QUALITY_LEVEL;
         bitmap.scaleY = 1 / Pocket.RASTERIZER_QUALITY_LEVEL;
         targetPart.addChild(bitmap);
         if(totalFrames > 1)
         {
            this._bakedParts.push(new BakedPart(targetPart,bitmap,frames,isTimeline));
         }
      }
      
      public function clearCache() : void
      {
         var part:BakedPart = null;
         var bmd:BitmapData = null;
         if(this._bakedParts)
         {
            for each(part in this._bakedParts)
            {
               for each(bmd in part.frames)
               {
                  bmd.dispose();
               }
               if(Boolean(part.bitmap) && Boolean(part.bitmap.parent))
               {
                  part.bitmap.parent.removeChild(part.bitmap);
               }
            }
            this._bakedParts = null;
            this._bakedParts = new Vector.<BakedPart>();
         }
      }
      
      public function dispose() : void
      {
         this.removeEventListener(Event.ENTER_FRAME,this.onTick);
         this.clearCache();
         this._bakedParts = null;
      }
      
      protected function onTick(e:Event) : void
      {
         var bakedPart:BakedPart = null;
         var partsToMonitorElement:DisplayObject = null;
         var skel:MovieClip = null;
         var bmd:BitmapData = null;
         var frameIndex:int = 0;
         var mcPart:MovieClip = null;
         for(var i:* = int(this._bakedParts.length - 1); i >= 0; i--)
         {
            bakedPart = this._bakedParts[i];
            if(!bakedPart.part || !bakedPart.part.stage || bakedPart.part.getChildByName("bmp_cache") == null)
            {
               for each(bmd in bakedPart.frames)
               {
                  bmd.dispose();
               }
               this._bakedParts.splice(i,1);
            }
            else if(bakedPart.isTimeline)
            {
               frameIndex = bakedPart.part.currentFrame - 1;
               if(frameIndex >= 0 && frameIndex < bakedPart.frames.length)
               {
                  bakedPart.bitmap.bitmapData = bakedPart.frames[frameIndex];
                  bakedPart.bitmap.smoothing = true;
               }
            }
            else
            {
               skel = MovieClip(bakedPart.part.parent);
               if(Boolean(skel) && skel.currentLabel == "Idle")
               {
                  bakedPart.currentFrame = 0;
               }
               else
               {
                  ++bakedPart.currentFrame;
                  if(bakedPart.currentFrame >= bakedPart.frames.length)
                  {
                     bakedPart.currentFrame = 0;
                  }
               }
               bakedPart.bitmap.bitmapData = bakedPart.frames[bakedPart.currentFrame];
               bakedPart.bitmap.smoothing = true;
            }
         }
         for each(partsToMonitorElement in this._partsToMonitor)
         {
            if(partsToMonitorElement is MovieClip)
            {
               mcPart = MovieClip(partsToMonitorElement);
               if(mcPart.numChildren > 0 && mcPart.getChildByName("bmp_cache") == null && mcPart.name != "hitbox")
               {
                  this.bakePart(mcPart);
               }
            }
         }
      }
   }
}

