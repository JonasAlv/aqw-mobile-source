package ui
{
   import controller.*;
   import controller.walk.*;
   import flash.display.*;
   import flash.events.MouseEvent;
   import ui.input.*;
   import ui.shortcut.*;
   import util.*;
   
   public class GameUI extends Sprite
   {
      
      private var pocket:Pocket;
      
      public var joystickMouseSimulator:Joystick = null;
      
      public var joystickKeyboardSimulator:Joystick = null;
      
      public var layoutController:LayoutController = new LayoutController();
      
      public var shortcutButtons:Object = {};
      
      public function GameUI(pocket:Pocket)
      {
         super();
         this.pocket = pocket;
         this.pocket.addChild(this);
         this.mouseChildren = true;
         this.mouseEnabled = false;
      }
      
      private function showJoystick(layout:String, joystickName:String, walkControllerClass:Class, xPosition:int, yPosition:int) : void
      {
         var joystick:Joystick = Joystick(this.getChildByName(joystickName));
         if(joystick != null)
         {
            return;
         }
         joystick = new Joystick(new walkControllerClass(this.pocket));
         joystick.name = joystickName;
         var joystick_default_x:Number = xPosition;
         var joystick_default_y:Number = yPosition;
         joystick.x = joystick_default_x;
         joystick.y = joystick_default_y;
         this.layoutController.register(layout,joystick,joystick_default_x,joystick_default_y,joystick.scaleX,joystick.scaleY);
         this.layoutController.load();
         this[joystickName] = Joystick(addChild(joystick));
      }
      
      private function hideJoystick(layout:String, joystickName:String) : void
      {
         var joystick:Joystick = Joystick(this.getChildByName(joystickName));
         if(joystick == null)
         {
            this[joystickName] = null;
            return;
         }
         removeChild(joystick);
         this.layoutController.unregister(layout);
         this.layoutController.load();
         joystick = null;
         this[joystickName] = null;
      }
      
      public function showJoystickMouseSimulator() : void
      {
         this.showJoystick(HelperSetting.LAYOUT_JOYSTICK_MOUSE,"joystickMouseSimulator",MouseWalkSimulatorController,73,348);
      }
      
      public function hideJoystickMouseSimulator() : void
      {
         this.hideJoystick(HelperSetting.LAYOUT_JOYSTICK_MOUSE,"joystickMouseSimulator");
      }
      
      public function showJoystickKeyboardSimulator() : void
      {
         this.showJoystick(HelperSetting.LAYOUT_JOYSTICK_KEYBOARD,"joystickKeyboardSimulator",KeyboardWalkSimulatorController,73 + 100,348);
      }
      
      public function hideJoystickKeyboardSimulator() : void
      {
         this.hideJoystick(HelperSetting.LAYOUT_JOYSTICK_KEYBOARD,"joystickKeyboardSimulator");
      }
      
      public function showSkillBar() : void
      {
         if(!this.pocket.game)
         {
            return;
         }
         if(this.pocket.gameCore.currentFrame != "Game")
         {
            return;
         }
         this.pocket.game.ui.mcInterface.actBar.visible = true;
      }
      
      public function hideSkillBar() : void
      {
         if(!this.pocket.game)
         {
            return;
         }
         if(this.pocket.gameCore.currentFrame != "Game")
         {
            return;
         }
         this.pocket.game.ui.mcInterface.actBar.visible = false;
      }
      
      public function addShortcutButton(actionName:String) : void
      {
         var index:int = 0;
         var COLS:int = 0;
         var CELL:int = 0;
         var ORIGIN_X:Number = NaN;
         var ORIGIN_Y:Number = NaN;
         var col:int = 0;
         var row:int = 0;
         if(this.shortcutButtons[actionName] != null)
         {
            return;
         }
         var layoutKey:String = "shortcut_" + Helper.sanitize(actionName);
         index = int(this.countShortcuts());
         COLS = 4;
         CELL = 66;
         ORIGIN_X = 480;
         ORIGIN_Y = 245;
         col = index % COLS;
         row = Math.floor(index / COLS);
         var defaultX:Number = ORIGIN_X + col * CELL;
         var defaultY:Number = ORIGIN_Y + row * CELL;
         var btn:ShortcutButton = new ShortcutButton(this.pocket,actionName);
         btn.name = layoutKey;
         btn.x = defaultX;
         btn.y = defaultY;
         this.layoutController.register(layoutKey,btn,defaultX,defaultY,btn.scaleX,btn.scaleY);
         this.layoutController.load();
         this.shortcutButtons[actionName] = ShortcutButton(addChild(btn));
         this.persistShortcuts();
      }
      
      public function removeShortcutButton(actionName:String) : void
      {
         var btn:ShortcutButton = ShortcutButton(this.shortcutButtons[actionName]);
         if(btn == null)
         {
            return;
         }
         var layoutKey:String = "shortcut_" + Helper.sanitize(actionName);
         if(btn.parent)
         {
            removeChild(btn);
         }
         this.layoutController.unregister(layoutKey);
         this.layoutController.load();
         delete this.shortcutButtons[actionName];
         this.persistShortcuts();
      }
      
      public function loadPersistedShortcuts() : void
      {
         var action:String = null;
         var saved:String = HelperSetting.getString(HelperSetting.OPTION_SHORTCUTS);
         if(!saved || saved.length == 0)
         {
            return;
         }
         for each(action in saved.split(","))
         {
            if(action.length > 0)
            {
               this.addShortcutButton(action);
            }
         }
      }
      
      private function persistShortcuts() : void
      {
         var k:String = null;
         var keys:Array = [];
         for(k in this.shortcutButtons)
         {
            keys.push(k);
         }
         HelperSetting.setString(HelperSetting.OPTION_SHORTCUTS,keys.join(","));
      }
      
      private function countShortcuts() : int
      {
         var k:String = null;
         var n:int = 0;
         for(k in this.shortcutButtons)
         {
            n++;
         }
         return n;
      }
      
      public function showEditLayout() : void
      {
         this.layoutController.toggleEdit(true);
      }
      
      public function hideEditLayout(event:MouseEvent = null) : void
      {
         this.layoutController.toggleEdit(false);
      }
      
      public function resetLayout() : void
      {
         this.layoutController.resetToDefaults();
      }
      
      public function resetShortcuts() : void
      {
         var btn:ShortcutButton = null;
         var actionName:String = null;
         for(actionName in this.shortcutButtons)
         {
            btn = ShortcutButton(this.shortcutButtons[actionName]);
            if(Boolean(btn) && Boolean(btn.parent))
            {
               removeChild(btn);
            }
            this.layoutController.unregister("shortcut_" + Helper.sanitize(actionName));
         }
         this.layoutController.load();
         this.shortcutButtons = {};
         this.persistShortcuts();
      }
   }
}

