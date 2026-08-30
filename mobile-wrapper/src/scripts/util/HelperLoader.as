package util
{
   import flash.display.Loader;
   import flash.events.*;
   import flash.net.*;
   import flash.system.LoaderContext;
   import flash.utils.*;
   
   public class HelperLoader
   {
      
      public static var COUNT:uint = 0;
      
      public function HelperLoader()
      {
         super();
      }
      
      public static function load(ldr:Loader, url:String, context:LoaderContext, onComplete:Function = null, onProgress:Function = null, onError:Function = null, onHTTPError:Function = null) : void
      {
         prepareContext(context);
         url = Helper.trimUrl(url);
         loadBinary(url,function(bytes:ByteArray):void
         {
            if(onComplete != null)
            {
               ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
            }
            if(onHTTPError != null)
            {
               ldr.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,onHTTPError);
            }
            ldr.loadBytes(bytes,context);
         },onProgress,function(e:IOErrorEvent):void
         {
            if(onError != null)
            {
               onError(e);
               return;
            }
            ldr.dispatchEvent(e);
         });
      }
      
      private static function loadBinary(url:String, onBytes:Function, onProgress:Function = null, onError:Function = null) : void
      {
         var urlLoader:URLLoader = new URLLoader();
         urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
         urlLoader.addEventListener(Event.COMPLETE,function(e:Event):void
         {
            onBytes(URLLoader(e.target).data as ByteArray);
         });
         if(onProgress != null)
         {
            urlLoader.addEventListener(ProgressEvent.PROGRESS,onProgress);
         }
         if(onError != null)
         {
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onError);
         }
         urlLoader.load(new URLRequest(url));
      }
      
      private static function prepareContext(ctx:LoaderContext) : void
      {
         ctx.checkPolicyFile = false;
         ctx.allowCodeImport = true;
      }
      
      public static function progressPercent(e:ProgressEvent) : int
      {
         return int(e.currentTarget.bytesLoaded / e.currentTarget.bytesTotal * 100);
      }
   }
}

