package controller.walk
{
   import flash.display.*;
   import flash.events.*;
   import flash.ui.*;
   
   public class KeyboardWalkSimulatorController extends WalkController
   {
      
      private var _lastKeyCode:uint = 0;
      
      public function KeyboardWalkSimulatorController(pocket:Pocket)
      {
         super(pocket);
      }
      
      override public function update() : void
      {
         var keyCode:uint = 0;
         var dirX:Number = this.pocket.gameUI.joystickKeyboardSimulator.dirX;
         var dirY:Number = this.pocket.gameUI.joystickKeyboardSimulator.dirY;
         if(dirX == 0 && dirY == 0)
         {
            this._releaseKey();
            return;
         }
         var angle:Number = Math.atan2(dirY,dirX);
         var PI4:Number = Math.PI / 4;
         if(angle >= -PI4 && angle < PI4)
         {
            keyCode = uint(Keyboard.RIGHT);
         }
         else if(angle >= PI4 && angle < PI4 * 3)
         {
            keyCode = uint(Keyboard.DOWN);
         }
         else if(angle >= -PI4 * 3 && angle < -PI4)
         {
            keyCode = uint(Keyboard.UP);
         }
         else
         {
            keyCode = uint(Keyboard.LEFT);
         }
         if(keyCode != this._lastKeyCode)
         {
            this._releaseKey();
            this._pressKey(keyCode);
         }
      }
      
      override public function stop() : void
      {
         this._releaseKey();
      }
      
      private function _pressKey(keyCode:uint) : void
      {
         var target:DisplayObject = this._target;
         if(!target)
         {
            return;
         }
         this._lastKeyCode = keyCode;
         target.dispatchEvent(this._makeEvent(KeyboardEvent.KEY_DOWN,keyCode));
      }
      
      private function _releaseKey() : void
      {
         if(this._lastKeyCode == 0)
         {
            return;
         }
         var target:DisplayObject = this._target;
         if(!target)
         {
            return;
         }
         target.dispatchEvent(this._makeEvent(KeyboardEvent.KEY_UP,this._lastKeyCode));
         this._lastKeyCode = 0;
      }
      
      private function get _target() : DisplayObject
      {
         var ext:MovieClip = MovieClip(this.pocket.game.mcExtSWF);
         if(!ext || ext.numChildren == 0)
         {
            return null;
         }
         try
         {
            return ext.getChildAt(0);
         }
         catch(e:RangeError)
         {
            return null;
         }
         catch(e:SecurityError)
         {
            return null;
         }
      }
      
      private function _makeEvent(ttype:String, keyCode:uint) : KeyboardEvent
      {
         return new KeyboardEvent(ttype,true,false,0,keyCode);
      }
   }
}

