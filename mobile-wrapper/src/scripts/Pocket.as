package
{
   import data.Release;
   import data.Version;
   import engine.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.text.TextField;
   import game.*;
   import load.handlers.*;
   import ui.*;
   import util.*;
   
   public class Pocket extends Sprite
   {
      
      private static var _SINGLETON:Pocket;
      
      public static var IS_RASTERIZER_ON:Boolean = true;
      
      public static var RASTERIZER_QUALITY_LEVEL:Number = 1;
      
      public static var IS_ANIMATION_OFF:Boolean = false;
      
      Sprite.prototype.removeAllChildren = function():void
      {
         var i:* = int(this.numChildren - 1);
         while(i >= 0)
         {
            this.removeChildAt(i);
            i--;
         }
      };
      
      public var loadingTxt:TextField;
      
      public var versionTxt:TextField;
      
      public var loadingErrorTxt:TextField;
      
      public var background:MovieClip;
      
      public var overlay:Overlay = new Overlay(this);
      
      public var gameUI:GameUI = new GameUI(this);
      
      public var game:MovieClip;
      
      public const gameCore:Game = new Game(this);
      
      public const worldCore:World = new World(this);
      
      public const lpfFrameListViewTabbedCore:LPFFrameListViewTabbed = new LPFFrameListViewTabbed(this);
      
      public var networkCore:Network;
      
      private const backgroundLoad:BackgroundLoad = new BackgroundLoad(this);
      
      private const gameLoader:GameLoad = new GameLoad(this);
      
      private const updateLoad:UpdateLoad = new UpdateLoad(this);
      
      private const versionLoad:VersionLoad = new VersionLoad(this);
      
      public var version:Version;
      
      public var release:Release;
      
      public const load:Function = HelperLoader.load;
      
      public const avatarRasterizer:Class = AvatarRasterizer;
      
      public const entityRasterizer:Class = EntityRasterizer;
      
      public function Pocket()
      {
         super();
         NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
         stage.color = 0;
         this.versionTxt.text = "Version " + Config.APP_VERSION;
         this.overlay.debug.log("Init");
         this.check();
         _SINGLETON = this;
      }
      
      public static function get SINGLETON() : Pocket
      {
         return _SINGLETON;
      }
      
      public function check() : void
      {
         switch(HelperLoader.COUNT)
         {
            case 0:
               this.versionLoad.start();
               break;
            case 1:
               this.backgroundLoad.start();
               break;
            case 2:
               this.updateLoad.start();
               break;
            case 3:
               this.gameLoader.start();
               break;
            case 4:
         }
      }
      
      public function advance() : void
      {
         ++HelperLoader.COUNT;
         this.check();
      }
   }
}

