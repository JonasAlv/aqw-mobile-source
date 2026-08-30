package ui.shortcut
{
   import data.Action;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol95")]
   public class ShortcutButton extends Sprite
   {
      
      public var shortcutBtn:SimpleButton;
      
      public var shortcutTxt:TextField;
      
      private var pocket:Pocket;
      
      private var actionName:String;
      
      public function ShortcutButton(pocket:Pocket, actionName:String)
      {
         super();
         this.pocket = pocket;
         this.actionName = actionName;
         this.shortcutTxt.text = actionName;
         this.shortcutTxt.wordWrap = true;
         this.shortcutTxt.selectable = false;
         this.shortcutTxt.mouseEnabled = false;
         this.shortcutTxt.tabEnabled = false;
         this.mouseChildren = true;
         this.mouseEnabled = false;
         this.shortcutBtn.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
      }
      
      private function onClick(e:MouseEvent) : void
      {
         var action:Action = null;
         if(!this.pocket.game)
         {
            return;
         }
         for each(action in ShortcutPicker.ACTIONS)
         {
            if(action.name == this.actionName && action.onClick != null)
            {
               action.onClick(this.pocket);
               return;
            }
         }
         if(!this.pocket.game.litePreference)
         {
            return;
         }
         var keys:Object = this.pocket.game.litePreference.data.keys;
         if(!keys || !(this.actionName in keys))
         {
            return;
         }
         var keyCodeValue:Object = keys[this.actionName];
         var keyCodeValueTemporary:Number = 999;
         keys[this.actionName] = keyCodeValueTemporary;
         var prevFocus:* = this.pocket.game.stage.focus;
         this.pocket.game.stage.focus = null;
         this.pocket.game.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,keyCodeValueTemporary,keyCodeValueTemporary));
         this.pocket.game.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP,true,false,keyCodeValueTemporary,keyCodeValueTemporary));
         this.pocket.game.stage.focus = prevFocus;
         keys[this.actionName] = keyCodeValue;
      }
   }
}

