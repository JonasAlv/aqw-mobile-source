package
{
   import flash.desktop.*;
   
   public class Config
   {
      
      public static const GAME_BASE_URL:String = "https://game.aq.com/game/";
      
      public static const API_VERSION_URL:String = GAME_BASE_URL + "api/data/gameversion";
      
      public static const API_LOGIN_URL:String = GAME_BASE_URL + "api/login/now";
      
      public static const APP_VERSION:String = getVersion();
      
      public static const GITHUB_RELEASES_URL:String = "https://api.github.com/repos/anthony-hyo/aqw-mobile/releases/latest";
      
      public function Config()
      {
         super();
      }
      
      private static function getVersion() : String
      {
         var appDesc:XML = null;
         appDesc = NativeApplication.nativeApplication.applicationDescriptor;
         var ns:Namespace = appDesc.namespace();
         return "v" + appDesc.ns::versionNumber;
      }
   }
}

