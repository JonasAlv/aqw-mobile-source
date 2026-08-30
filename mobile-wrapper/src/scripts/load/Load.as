package load
{
   import flash.display.*;
   import flash.errors.*;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.system.*;
   import util.*;
   
   public class Load
   {
      
      public var domain:ApplicationDomain = new ApplicationDomain();
      
      public var context:LoaderContext = new LoaderContext(false,this.domain);
      
      protected var pocket:Pocket = null;
      
      protected var url:String = "";
      
      public function Load(pocket:Pocket)
      {
         super();
         this.pocket = pocket;
         this.context.allowCodeImport = true;
      }
      
      public function start() : void
      {
         this.load();
      }
      
      protected function load() : void
      {
         HelperLoader.load(new Loader(),this.url,this.context,this.onCompleted,this.onProgress,this.onError);
      }
      
      protected function onCompleted(event:Event) : void
      {
         throw new IllegalOperationError("Must override onCompleted Function");
      }
      
      protected function onProgress(event:ProgressEvent) : void
      {
         throw new IllegalOperationError("Must override onProgress Function");
      }
      
      protected function onError(error:IOErrorEvent) : void
      {
         throw new IllegalOperationError("Must override onError Function");
      }
   }
}

