package ui
{
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol87")]
   public class Debug extends Sprite
   {
      
      public var logTxt:TextField;
      
      public var closeBtn:SimpleButton;
      
      public function Debug()
      {
         super();
         this.x = 30;
         this.y = 330;
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.onClose,false,0,true);
      }
      
      private function onClose(e:MouseEvent) : void
      {
         if(Boolean(this.parent) && this.parent.contains(this))
         {
            this.parent.removeChild(this);
         }
      }
      
      public function log(msg:String) : void
      {
         var timestamp:String = null;
         var lines:Array = null;
         var match:Array = null;
         var callerName:String = null;
         var stack:String = new Error().getStackTrace();
         if(stack)
         {
            lines = stack.split("\n");
            if(lines.length > 2)
            {
               match = lines[2].match(/at\s+([\w.:$\/]+)/);
               callerName = match ? match[1] : "unknown";
               if(callerName.indexOf("::") != -1)
               {
                  callerName = callerName.split("::")[1];
               }
               if(callerName.indexOf("/") != -1)
               {
                  callerName = callerName.split("/")[0];
               }
            }
         }
         timestamp = new Date().toTimeString().substr(0,8);
         var entry:String = "[" + timestamp + "] [" + callerName + "] " + msg;
         trace(entry);
         this.logTxt.appendText(entry + "\n");
         this.logTxt.scrollV = this.logTxt.maxScrollV;
      }
      
      public function logError(msg:String) : void
      {
         if(!parent)
         {
            Pocket.SINGLETON.overlay.addChild(this);
         }
         this.log("ERROR: " + msg);
      }
   }
}

