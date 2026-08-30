package ui
{
   import controller.walk.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.utils.*;
   import ui.option.*;
   import ui.shortcut.*;
   import ui.util.Scroll;
   import util.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol50")]
   public class Overlay extends MovieClip
   {
      
      public var __setAccDict:Dictionary = new Dictionary(true);
      
      public var showPanelBtn:SimpleButton;
      
      public var hidePanelBtn:SimpleButton;
      
      public var reportBugBtn:SimpleButton;
      
      public var updateBtn:SimpleButton;
      
      public var discordBtn:SimpleButton;
      
      public var contentMenu:Sprite;
      
      public var contentOptions:Sprite;
      
      public var contentMask:DisplayObject;
      
      public var contentScroll:Scroll;
      
      public var debug:Debug = new Debug();
      
      public var notifications:Sprite;
      
      private var pocket:Pocket;
      
      public var menus:Vector.<Menu> = new <Menu>[new Menu("General",new <Option>[new Toggle(HelperSetting.OPTION_LOCK_ORIENTATION,0,"Screen Orientation","Choose how the screen rotates",true,["Landscape","Portrait","Landscape Left","Landscape Right","Portrait Flipped"],function(option:Toggle):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(option.getIndex() == 0)
         {
            stage.autoOrients = true;
            stage.setAspectRatio(StageAspectRatio.LANDSCAPE);
            return;
         }
         stage.autoOrients = false;
         stage.setAspectRatio(StageAspectRatio.ANY);
         stage.setOrientation(Helper.ORIENTATIONS[option.getIndex()]);
      },null,function(frame:String):void
      {
         var pocket:* = Pocket.SINGLETON;
         var savedIndex:* = HelperSetting.getInt(HelperSetting.OPTION_LOCK_ORIENTATION);
         if(savedIndex == 0)
         {
            stage.autoOrients = true;
            stage.setAspectRatio(StageAspectRatio.LANDSCAPE);
         }
         else
         {
            stage.autoOrients = false;
            stage.setAspectRatio(StageAspectRatio.ANY);
            stage.setOrientation(Helper.ORIENTATIONS[savedIndex]);
         }
      }),new Check(HelperSetting.OPTION_DISCORD_RPC,true,"Discord RPC","Enable Discord Rich Presence",false,function(option:Check):void
      {
      }),new Check(null,false,"Show Debug","Display debug on screen",true,function(option:Check):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(option.state)
         {
            if(pocket.overlay.debug.parent == null)
            {
               pocket.overlay.addChild(pocket.overlay.debug);
            }
            return;
         }
         if(Boolean(pocket.overlay.debug.parent) && contains(pocket.overlay.debug))
         {
            pocket.overlay.removeChild(pocket.overlay.debug);
         }
      })]),new Menu("Controls",new <Option>[new Check(HelperSetting.OPTION_SHOW_JOYSTICK_MOUSE,true,"Show Joystick","Display joystick on screen",true,function(option:Check):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(!pocket.game || pocket.gameCore.currentFrame != "Game")
         {
            return;
         }
         if(option.state)
         {
            pocket.gameUI.showJoystickMouseSimulator();
            return;
         }
         pocket.gameUI.hideJoystickMouseSimulator();
      },function(frame:String):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(!HelperSetting.getBool(HelperSetting.OPTION_SHOW_JOYSTICK_MOUSE))
         {
            return;
         }
         if(frame != "Game")
         {
            pocket.gameUI.hideJoystickMouseSimulator();
            return;
         }
         pocket.gameUI.showJoystickMouseSimulator();
      }),new Check(HelperSetting.OPTION_SHOW_JOYSTICK_KEYBOARD,false,"Show Arrow keys","Keyboard arrow key simulator",true,function(option:Check):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(!pocket.game || pocket.gameCore.currentFrame != "Game")
         {
            return;
         }
         if(option.state)
         {
            pocket.gameUI.showJoystickKeyboardSimulator();
            return;
         }
         pocket.gameUI.hideJoystickKeyboardSimulator();
      },function(frame:String):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(!HelperSetting.getBool(HelperSetting.OPTION_SHOW_JOYSTICK_KEYBOARD))
         {
            return;
         }
         if(frame != "Game")
         {
            pocket.gameUI.hideJoystickKeyboardSimulator();
            return;
         }
         pocket.gameUI.showJoystickKeyboardSimulator();
      }),new Check(HelperSetting.OPTION_SHOW_SKILL_BAR,true,"Show Skill Bar","Display skill bar on screen",true,function(option:Check):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(!pocket.game || pocket.gameCore.currentFrame != "Game")
         {
            return;
         }
         if(option.state)
         {
            pocket.gameUI.showSkillBar();
            return;
         }
         pocket.gameUI.hideSkillBar();
      },function(frame:String):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(!HelperSetting.getBool(HelperSetting.OPTION_SHOW_SKILL_BAR))
         {
            return;
         }
         if(frame != "Game")
         {
            pocket.gameUI.hideSkillBar();
            return;
         }
         pocket.gameUI.showSkillBar();
      }),new Check(HelperSetting.OPTION_JOYSTICK_DASH,false,"Joystick Dash","Enable dashing using joystick",true,function(option:Check):void
      {
         MouseWalkSimulatorController.IS_DASHING_ON = option.state;
      },function(frame:String):void
      {
         MouseWalkSimulatorController.IS_DASHING_ON = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION);
      })]),new Menu("Shortcuts",new <Option>[new Button(null,"Add Shortcut","Place an action button on screen","Add",function(option:Button):void
      {
         var shortcutPicker:*;
         var pocket:* = undefined;
         pocket = Pocket.SINGLETON;
         if(!pocket.game || pocket.gameCore.currentFrame != "Game")
         {
            if(pocket.game)
            {
               pocket.game.MsgBox.notify("Only available in-game.");
            }
            return;
         }
         pocket.overlay.onHidePanel(null);
         shortcutPicker = pocket.game.stage.getChildByName("ShortcutPicker");
         if(shortcutPicker)
         {
            pocket.game.stage.removeChild(shortcutPicker);
         }
         pocket.game.stage.addChild(new ShortcutPicker(pocket,function(actionName:String):void
         {
            pocket.gameUI.addShortcutButton(actionName);
         }));
      }),new Button(null,"Remove Shortcut","Remove a shortcut button from screen","Remove",function(option:Button):void
      {
         var shortcutPicker:*;
         var pocket:* = undefined;
         pocket = Pocket.SINGLETON;
         if(!pocket.game || pocket.gameCore.currentFrame != "Game")
         {
            return;
         }
         pocket.overlay.onHidePanel(null);
         shortcutPicker = pocket.game.stage.getChildByName("ShortcutPicker");
         if(shortcutPicker)
         {
            pocket.game.stage.removeChild(shortcutPicker);
         }
         pocket.game.stage.addChild(new ShortcutPicker(pocket,function(actionName:String):void
         {
            pocket.gameUI.removeShortcutButton(actionName);
         }));
      }),new Button(null,"Reset Shortcuts","Remove all shortcut buttons from screen","Reset",function(option:Button):void
      {
         var pocket:* = Pocket.SINGLETON;
         pocket.gameUI.resetShortcuts();
         if(pocket.game)
         {
            pocket.game.MsgBox.notify("Shortcuts cleared.");
         }
      })]),new Menu("Layout",new <Option>[new Check(HelperSetting.OPTION_SNAP_TO_GRID,true,"Snap To Grid","Show an alignment grid while editing layout",true),new Button(null,"Edit Layout","Drag to reposition UI elements","Edit",function(option:Button):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(!pocket.game || pocket.gameCore.currentFrame != "Game")
         {
            if(pocket.game)
            {
               pocket.game.MsgBox.notify("Cannot edit outside the game screen.");
            }
            return;
         }
         pocket.worldCore.setWorldFilters([Helper.GRAYSCALE]);
         pocket.overlay.onHidePanel(null);
         pocket.gameUI.showEditLayout();
      },function(frame:String):void
      {
         var pocket:* = Pocket.SINGLETON;
         pocket.gameUI.hideEditLayout();
      }),new Button(null,"Reset Layout","Restore default positions","Reset",function(option:Button):void
      {
         var pocket:* = Pocket.SINGLETON;
         if(pocket.game)
         {
            pocket.game.MsgBox.notify("Layout successfully restored.");
         }
         pocket.gameUI.resetLayout();
      })])];
      
      public function Overlay(pocket:Pocket)
      {
         super();
         addFrameScript(1,this.frame2);
         this.pocket = pocket;
         addFrameScript(0,this.initFrame,1,this.panelFrame);
         this.pocket.addChild(this);
         this.notifications = Sprite(addChild(new Sprite()));
      }
      
      private function initFrame() : void
      {
         var menu:Menu = null;
         var option:Option = null;
         this.showPanelBtn.addEventListener(MouseEvent.CLICK,this.onShowPanel);
         for each(menu in this.menus)
         {
            for each(option in menu.options)
            {
               if(option.onOverlayStateChange != null)
               {
                  option.onOverlayStateChange("Init");
               }
            }
         }
         this.pocket.overlay.setOverlayButtonTransform();
         this.pocket.gameUI.loadPersistedShortcuts();
         stop();
      }
      
      private function panelFrame() : void
      {
         var menu:Menu = null;
         var option:Option = null;
         this.visible = false;
         this.contentMenu.removeAllChildren();
         this.hidePanelBtn.addEventListener(MouseEvent.CLICK,this.onHidePanel);
         var heightTotal:uint = 0;
         for each(menu in this.menus)
         {
            this.contentMenu.addChild(menu);
            menu.y = heightTotal;
            heightTotal += menu.height + 10;
            for each(option in menu.options)
            {
               if(option.onOverlayStateChange != null)
               {
                  option.onOverlayStateChange("Panel");
               }
            }
         }
         Pocket.SINGLETON.overlay.selectMenu(this.menus[0]);
         this.reportBugBtn.addEventListener(MouseEvent.CLICK,this.onReportBug);
         this.updateBtn.addEventListener(MouseEvent.CLICK,this.onUpdate);
         this.discordBtn.addEventListener(MouseEvent.CLICK,this.onDiscord);
         this.visible = true;
         stop();
      }
      
      public function selectMenu(menu:Menu) : void
      {
         var option:Option = null;
         this.contentOptions.removeAllChildren();
         var heightTotal:uint = 0;
         for each(option in menu.options)
         {
            if(option.visible)
            {
               this.contentOptions.addChild(option);
               option.x = 17;
               option.y = heightTotal + 17;
               heightTotal += option.height + 5;
            }
         }
      }
      
      private function onShowPanel(mouseEvent:MouseEvent) : void
      {
         gotoAndStop("Panel");
      }
      
      private function onHidePanel(mouseEvent:MouseEvent) : void
      {
         gotoAndStop("Init");
      }
      
      private function onReportBug(e:MouseEvent) : void
      {
         navigateToURL(new URLRequest("https://github.com/anthony-hyo/aqw-mobile/issues"),"_blank");
      }
      
      private function onUpdate(e:MouseEvent) : void
      {
         navigateToURL(new URLRequest("https://github.com/anthony-hyo/aqw-mobile/releases/latest"),"_blank");
      }
      
      private function onDiscord(e:MouseEvent) : void
      {
         navigateToURL(new URLRequest("https://discord.gg/EXS5qM35ff"),"_blank");
      }
      
      public function notification(message:String) : void
      {
         var index:uint = uint(this.notifications.numChildren);
         var notification:Notification = Notification(this.notifications.addChild(new Notification(message)));
         if(index == 0)
         {
            this.notifications.x = stage.stageWidth - notification.width - 10;
            this.notifications.y = 10;
         }
         notification.y = index * (notification.height + 10);
      }
      
      public function setOverlayButtonTransform() : void
      {
         if(!this.pocket.game)
         {
            return;
         }
         switch(this.pocket.gameCore.currentFrame)
         {
            case "Game":
               if(this.pocket.overlay.showPanelBtn)
               {
                  this.pocket.overlay.showPanelBtn.width = this.pocket.overlay.showPanelBtn.height = 24;
                  this.pocket.overlay.showPanelBtn.x = this.pocket.overlay.showPanelBtn.y = 2;
               }
               break;
            default:
               if(this.pocket.overlay.showPanelBtn)
               {
                  this.pocket.overlay.showPanelBtn.width = this.pocket.overlay.showPanelBtn.height = 37.3;
                  this.pocket.overlay.showPanelBtn.x = 7.1;
                  this.pocket.overlay.showPanelBtn.y = 264.9;
               }
         }
      }
      
      internal function __setAcc_reportBugBtn_Symbol4_contentScroll_1() : *
      {
         if(this.__setAccDict[this.reportBugBtn] == undefined || int(this.__setAccDict[this.reportBugBtn]) != 2)
         {
            this.__setAccDict[this.reportBugBtn] = 2;
            this.reportBugBtn.accessibilityProperties = new AccessibilityProperties();
            this.reportBugBtn.accessibilityProperties.silent = true;
         }
      }
      
      internal function __setAcc_updateBtn_Symbol4_contentScroll_1() : *
      {
         if(this.__setAccDict[this.updateBtn] == undefined || int(this.__setAccDict[this.updateBtn]) != 2)
         {
            this.__setAccDict[this.updateBtn] = 2;
            this.updateBtn.accessibilityProperties = new AccessibilityProperties();
            this.updateBtn.accessibilityProperties.silent = true;
         }
      }
      
      internal function __setAcc_discordBtn_Symbol4_contentScroll_1() : *
      {
         if(this.__setAccDict[this.discordBtn] == undefined || int(this.__setAccDict[this.discordBtn]) != 2)
         {
            this.__setAccDict[this.discordBtn] = 2;
            this.discordBtn.accessibilityProperties = new AccessibilityProperties();
            this.discordBtn.accessibilityProperties.silent = true;
         }
      }
      
      internal function frame2() : *
      {
         this.__setAcc_discordBtn_Symbol4_contentScroll_1();
         this.__setAcc_updateBtn_Symbol4_contentScroll_1();
         this.__setAcc_reportBugBtn_Symbol4_contentScroll_1();
      }
   }
}

