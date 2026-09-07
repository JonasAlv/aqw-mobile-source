package game {
	
	import flash.display.Sprite;

	import util.HelperSetting;

	public class Network {
		public static var PENDING_DROPS:Array = [];

		public function Network(pocket:Pocket) {
			this.pocket = pocket;
			this.pocket.game.sfc.addEventListener("onExtensionResponse", onExtensionResponseHandler, false, 0, true);
		}

		private var pocket:Pocket;

		private function onExtensionResponseHandler(event:*):void {
			switch (event.params.type) {
				/*case "str":
					switch (event.params.dataObj[0]) {
						case "whisper":
							break;
					}
					break;*/
				case "json":
					switch (event.params.dataObj.cmd) {
																																										case "dropItem":
							try {
								for (var k:String in event.params.dataObj) {
									if (k == "cmd") continue;
									var val:* = event.params.dataObj[k];
									if (val != null && typeof(val) == "object") {
										for (var subK:String in val) {
											var item:* = val[subK];
											if (HelperSetting.getBool("botAutoAcceptAllDrops", false) && pocket.game.world != null) {
												var roomId:* = pocket.game.world.curRoom;
												pocket.game.sfc.sendString("%xt%zm%getDrop%" + roomId + "%" + item.ItemID + "%");
												pocket.game.chatF.pushMsg("server", "AUTO ACCEPT: " + item.sName, "SERVER", "", 0);
											} else {
												Network.PENDING_DROPS.push({
													sName: item.sName,
													ItemID: item.ItemID
												});
												if (Network.PENDING_DROPS.length > 50) {
													Network.PENDING_DROPS.shift();
												}
											}
										}
									}
								}
							} catch (e:Error) {
								pocket.game.chatF.pushMsg("server", "DROP ERROR: " + e.message, "SERVER", "", 0);
							}
							break;
						case "sAct":
							sAct();
							break;
					}
					break;
			}
		}

		private function sAct():void {
			const actBar:Sprite = this.pocket.game.ui.mcInterface.actBar;

			var icon:Sprite;

			for (var i:int = 0; i < 6; i++) {
				icon = Sprite(actBar.getChildByName("i" + (i + 1)));

				if (icon == null) {
					continue;
				}

				this.pocket.gameUI.layoutController.register(HelperSetting.LAYOUT_SKILL_BAR + "_i" + (i + 1), icon, icon.x, icon.y, icon.scaleX, icon.scaleY);
			}

			this.pocket.gameUI.layoutController.load();
		}

	}

}