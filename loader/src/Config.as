package {
	import flash.desktop.NativeApplication;

	public class Config {

		public static const GAME_BASE_URL:String = "https://game.aq.com/game/";

		public static const API_VERSION_URL:String = GAME_BASE_URL + "api/data/gameversion";
		public static const API_LOGIN_URL:String = GAME_BASE_URL + "api/login/now";

		public static const APP_VERSION:String = getVersion();

		private static function getVersion():String {
			const appDesc:XML = NativeApplication.nativeApplication.applicationDescriptor;
			const ns:Namespace = appDesc.namespace();
			
			return "v" + appDesc.ns::versionNumber;
		}

		public static const GITHUB_RELEASES_URL:String = "https://api.github.com/repos/anthony-hyo/aqw-mobile/releases/latest";

		public static var IS_GRAPHIC_ANIMATION_MONSTER_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_HELM_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_ARMOR_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_CAPE_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_HAIR_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_MISC_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_PET_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_WEAPON_OFF:Boolean = false;

		public static var IS_GRAPHIC_FILTER_OFF:Boolean = false;

		public var option_language:String = "en";
		public var option_skill_tooltips:Boolean = true;
		public var option_disable_cutscenes:Boolean = false;

	}

}