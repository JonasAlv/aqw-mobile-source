package load.handlers
{
   import data.*;
   import flash.events.*;
   import flash.net.*;
   import load.Load;
   import util.*;
   
   public class VersionLoad extends Load
   {
      
      public function VersionLoad(pocket:Pocket)
      {
         super(pocket);
      }
      
      override public function start() : void
      {
         this.url = Config.API_VERSION_URL;
         super.start();
      }
      
      override protected function load() : void
      {
         var urlLoader:URLLoader = new URLLoader(new URLRequest(this.url));
         urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
         urlLoader.addEventListener(Event.COMPLETE,this.onCompleted,false,0,true);
         urlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onError,false,0,true);
      }
      
      override protected function onCompleted(event:Event) : void
      {
         var backgrounds:Array = null;
         try
         {
            this.pocket.version = new Version(JSON.parse(URLLoader(event.target).data));
            backgrounds = ["DageScorn.swf","Mirror2.swf","ravenloss2.swf","EtherstormPlague.swf","BrightFallCommanderTitle.swf",this.pocket.version.sBG];
            this.pocket.version.sBG = backgrounds[Math.floor(Math.random() * backgrounds.length)];
            this.pocket.overlay.debug.log("Version fetched");
            this.pocket.overlay.debug.log("File: " + this.pocket.version.sFile);
            this.pocket.overlay.debug.log("Title: " + this.pocket.version.sTitle);
            this.pocket.overlay.debug.log("Background: " + this.pocket.version.sBG);
            this.pocket.overlay.debug.log("Version: " + this.pocket.version.sVersion);
            this.pocket.advance();
         }
         catch(error:Error)
         {
            this.pocket.overlay.debug.logError("Failed to parse version response: " + error.message);
         }
      }
      
      override protected function onProgress(progressEvent:ProgressEvent) : void
      {
         this.pocket.loadingTxt.text = "API " + HelperLoader.progressPercent(progressEvent) + "%";
      }
      
      override protected function onError(error:IOErrorEvent) : void
      {
         this.pocket.loadingErrorTxt.htmlText = "Version load failed. Check your internet connection and try again.\n\n" + "1. Open your browser, visit <font color=\'#FFCC00\'><a href=\'https://www.aq.com\'>www.aq.com</a></font> then relaunch the game.\n" + "2. Disable your <font color=\'#FFCC00\'>VPN or proxy</font> if you are using one.\n" + "3. Restart your <font color=\'#FFCC00\'>modem/router</font> to get a fresh IP.\n\n" + "<font color=\'#888888\'>Error: " + error.text + "</font>";
         this.pocket.overlay.debug.logError("Version load failed: " + JSON.stringify(error));
      }
   }
}

