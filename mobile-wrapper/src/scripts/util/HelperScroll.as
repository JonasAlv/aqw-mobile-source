package util
{
   import flash.display.DisplayObject;
   import flash.events.*;
   import ui.util.Scroll;
   
   public class HelperScroll
   {
      
      private static const WHEEL_SPEED:int = 20;
      
      private static const FRICTION:Number = 0.92;
      
      private static const MIN_VELOCITY:Number = 0.5;
      
      private var scroll:Scroll;
      
      private var list:DisplayObject;
      
      private var listMask:DisplayObject;
      
      private var hRun:int = 0;
      
      private var dRun:int = 0;
      
      private var oy:int = 0;
      
      private var mhY:int = 0;
      
      private var mbY:int = 0;
      
      private var scrollBarDragging:Boolean = false;
      
      private var listDragging:Boolean = false;
      
      private var dragStartY:Number = 0;
      
      private var dragLastY:Number = 0;
      
      private var dragPrevY:Number = 0;
      
      private var velocity:Number = 0;
      
      public function HelperScroll(scroll:Scroll, list:DisplayObject, mask:DisplayObject, isResize:Boolean = true)
      {
         super();
         this.scroll = scroll;
         this.list = list;
         this.listMask = mask;
         this.scroll.hit.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownScrollHit);
         this.scroll.visible = false;
         this.scroll.hit.alpha = 0;
         this.scroll.h.y = 0;
         var maskHeight:Number = Number(this.listMask.height);
         if(this.list.height > maskHeight)
         {
            if(isResize)
            {
               this.scroll.h.height = int(maskHeight / this.list.height * this.scroll.b.height);
            }
            this.hRun = this.scroll.b.height - this.scroll.h.height;
            this.dRun = this.list.height - maskHeight + 10;
            this.oy = this.list.y = this.listMask.y;
            this.scroll.visible = true;
            this.scroll.hit.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownScrollHit);
            this.list.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownList);
            this.list.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         }
      }
      
      private function clampScrollHandle() : void
      {
         if(this.scroll.h.y + this.scroll.h.height > this.scroll.b.height)
         {
            this.scroll.h.y = int(this.scroll.b.height - this.scroll.h.height);
         }
         if(this.scroll.h.y < 0)
         {
            this.scroll.h.y = 0;
         }
      }
      
      private function clampListPosition() : void
      {
         var minY:Number = this.oy - this.dRun;
         if(this.list.y > this.oy)
         {
            this.list.y = this.oy;
         }
         if(this.list.y < minY)
         {
            this.list.y = minY;
         }
      }
      
      private function syncListFromScrollHandle() : void
      {
         var hP:Number = this.scroll.h.y / this.hRun;
         this.list.y = this.oy - int(hP * this.dRun);
      }
      
      private function syncScrollHandleFromList() : void
      {
         var listP:Number = (this.oy - this.list.y) / this.dRun;
         this.scroll.h.y = int(listP * this.hRun);
         this.clampScrollHandle();
      }
      
      private function onMouseDownList(e:MouseEvent) : void
      {
         if(this.scrollBarDragging)
         {
            return;
         }
         this.listDragging = true;
         this.dragStartY = e.stageY;
         this.dragLastY = e.stageY;
         this.dragPrevY = e.stageY;
         this.velocity = 0;
         this.list.removeEventListener(Event.ENTER_FRAME,this.onMomentum);
         this.list.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveList);
         this.list.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpList);
      }
      
      private function onMouseMoveList(e:MouseEvent) : void
      {
         if(!this.listDragging)
         {
            return;
         }
         var delta:Number = e.stageY - this.dragLastY;
         this.velocity = e.stageY - this.dragPrevY;
         this.dragPrevY = this.dragLastY;
         this.dragLastY = e.stageY;
         this.list.y += delta;
         this.clampListPosition();
         this.syncScrollHandleFromList();
      }
      
      private function onMouseUpList(e:MouseEvent) : void
      {
         this.listDragging = false;
         this.list.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveList);
         this.list.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpList);
         if(Math.abs(this.velocity) > MIN_VELOCITY)
         {
            this.list.addEventListener(Event.ENTER_FRAME,this.onMomentum);
         }
      }
      
      private function onMomentum(e:Event) : void
      {
         this.velocity *= FRICTION;
         this.list.y += this.velocity;
         this.clampListPosition();
         this.syncScrollHandleFromList();
         if(Math.abs(this.velocity) < MIN_VELOCITY)
         {
            this.list.removeEventListener(Event.ENTER_FRAME,this.onMomentum);
         }
      }
      
      private function onMouseDownScrollHit(e:MouseEvent) : void
      {
         this.scrollBarDragging = true;
         this.mbY = int(this.list.stage.mouseY);
         this.mhY = this.scroll.h.y;
         this.list.removeEventListener(Event.ENTER_FRAME,this.onMomentum);
         this.list.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpScrollBar);
         this.list.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveScrollBar);
      }
      
      private function onMouseUpScrollBar(e:MouseEvent) : void
      {
         this.scrollBarDragging = false;
         this.list.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpScrollBar);
         this.list.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveScrollBar);
      }
      
      private function onMouseMoveScrollBar(e:MouseEvent) : void
      {
         this.scroll.h.y = this.mhY + (int(this.list.stage.mouseY) - this.mbY);
         this.clampScrollHandle();
         this.syncListFromScrollHandle();
      }
      
      private function onMouseWheel(e:MouseEvent) : void
      {
         this.list.removeEventListener(Event.ENTER_FRAME,this.onMomentum);
         this.scroll.h.y -= int(e.delta * WHEEL_SPEED * this.hRun / this.dRun);
         this.clampScrollHandle();
         this.syncListFromScrollHandle();
      }
   }
}

