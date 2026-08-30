package ui.input
{
   import controller.*;
   import controller.walk.WalkController;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.geom.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol102")]
   public class Joystick extends Sprite
   {
      
      public var knob:Sprite;
      
      public var dirX:Number = 0;
      
      public var dirY:Number = 0;
      
      private var _limit:Number;
      
      private var walkController:WalkController;
      
      public function Joystick(walkController:WalkController)
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAdded,false,0,true);
         this.walkController = walkController;
      }
      
      public function move(stageX:Number, stageY:Number) : void
      {
         var dx:Number = NaN;
         var dy:Number = NaN;
         var local:Point = globalToLocal(new Point(stageX,stageY));
         dx = local.x;
         dy = local.y;
         var dist:Number = Math.sqrt(dx * dx + dy * dy);
         if(dist > this._limit)
         {
            dx = dx / dist * this._limit;
            dy = dy / dist * this._limit;
         }
         this.knob.x = dx;
         this.knob.y = dy;
         this.dirX = dx / this._limit;
         this.dirY = dy / this._limit;
      }
      
      public function snapHome() : void
      {
         this.knob.x = 0;
         this.knob.y = 0;
         this.dirX = 0;
         this.dirY = 0;
      }
      
      private function onAdded(e:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAdded);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onDown,false,0,true);
         this._limit = (this.width >> 1) - (this.knob.width >> 1) * 0.4;
      }
      
      private function onDown(e:MouseEvent) : void
      {
         if(!this.visible || Boolean(LayoutController.editMode))
         {
            return;
         }
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         stage.removeEventListener(Event.ENTER_FRAME,this.onEnterFrameJoystick);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMove,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onUp,false,0,true);
         stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrameJoystick,false,0,true);
         this.move(e.stageX,e.stageY);
      }
      
      private function onMove(e:MouseEvent) : void
      {
         if(this.dirX != 0 || this.dirY != 0)
         {
            this.move(e.stageX,e.stageY);
         }
      }
      
      private function onUp(e:MouseEvent) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         stage.removeEventListener(Event.ENTER_FRAME,this.onEnterFrameJoystick);
         if(this.dirX == 0 && this.dirY == 0)
         {
            return;
         }
         this.snapHome();
         this.walkController.stop();
      }
      
      private function onEnterFrameJoystick(e:Event) : void
      {
         this.walkController.update();
      }
   }
}

