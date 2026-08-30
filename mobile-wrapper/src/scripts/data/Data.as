package data
{
   public class Data
   {
      
      public function Data(obj:Object = null)
      {
         super();
         if(obj != null)
         {
            this.fromObject(obj);
         }
      }
      
      public function fromObject(obj:Object) : void
      {
         var p:String = null;
         for(p in obj)
         {
            if(this.hasOwnProperty(p) && !(this[p] is Vector.<*>))
            {
               if(typeof this[p] === "boolean")
               {
                  this[p] = !(obj[p] == "false" || obj[p] == "0" || !obj[p]);
               }
               else
               {
                  this[p] = obj[p];
               }
            }
         }
      }
   }
}

