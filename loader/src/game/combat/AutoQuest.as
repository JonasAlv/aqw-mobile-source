package game.combat {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.display.Sprite;

	public class AutoQuest {
		private static var _pocket:*;
		private static var _timer:Timer;
		private static var _questIDs:Array = [];
		private static var _lastTurnIns:Object = {};
		private static var _promptContainer:Sprite;
		private static var _promptInput:TextField;

		public static function toggle(pocket:*):void {
			_pocket = pocket;
			if (_timer != null) {
				stop();
			} else {
				showPrompt();
			}
		}

		public static function showPrompt():void {
			if (_promptContainer != null) {
				hidePrompt();
			}
			
			if (_pocket && _pocket.game && _pocket.game.MsgBox) {
				_pocket.game.MsgBox.notify("Opening Auto-Quest Settings...");
			}
			
			try {
				_promptContainer = new Sprite();
				_promptContainer.graphics.beginFill(0x222222, 0.95);
				_promptContainer.graphics.lineStyle(4, 0x00FF00);
				_promptContainer.graphics.drawRoundRect(0, 0, 400, 200, 20, 20);
				_promptContainer.graphics.endFill();
				
				_promptContainer.x = (960 - 400) / 2;
				_promptContainer.y = (550 - 200) / 2;
				
				var title:TextField = new TextField();
				var tfTitle:TextFormat = new TextFormat("_sans", 24, 0xFFFFFF, true);
				tfTitle.align = TextFormatAlign.CENTER;
				title.defaultTextFormat = tfTitle;
				title.text = "Enter Quest IDs (e.g. 123, 456:789)";
				title.width = 400;
				title.y = 30;
				title.selectable = false;
				
				_promptInput = new TextField();
				_promptInput.type = TextFieldType.INPUT;
				_promptInput.needsSoftKeyboard = true;
				var tfInput:TextFormat = new TextFormat("_sans", 32, 0x000000, true);
				tfInput.align = TextFormatAlign.CENTER;
				_promptInput.defaultTextFormat = tfInput;
				_promptInput.background = true;
				_promptInput.backgroundColor = 0xFFFFFF;
				_promptInput.border = true;
				_promptInput.borderColor = 0x000000;
				_promptInput.width = 300;
				_promptInput.height = 50;
				_promptInput.x = 50;
				_promptInput.y = 80;
				_promptInput.maxChars = 30;
				_promptInput.restrict = "0-9, :";
				if (_questIDs.length > 0) {
					var strList:Array = [];
					for (var j:int = 0; j < _questIDs.length; j++) {
						var qObj:Object = _questIDs[j];
						if (qObj.itemId > 0) {
							strList.push(qObj.qid + ":" + qObj.itemId);
						} else {
							strList.push(qObj.qid);
						}
					}
					_promptInput.text = strList.join(",");
				}
				
				var btnOK:Sprite = new Sprite();
				btnOK.graphics.beginFill(0x00CC00, 1);
				btnOK.graphics.lineStyle(2, 0xFFFFFF);
				btnOK.graphics.drawRoundRect(0, 0, 150, 45, 10, 10);
				btnOK.graphics.endFill();
				btnOK.x = 125;
				btnOK.y = 140;
				btnOK.buttonMode = true;
				
				var txtOK:TextField = new TextField();
				var tfOK:TextFormat = new TextFormat("_sans", 20, 0xFFFFFF, true);
				tfOK.align = TextFormatAlign.CENTER;
				txtOK.defaultTextFormat = tfOK;
				txtOK.text = "START";
				txtOK.width = 150;
				txtOK.y = 10;
				txtOK.mouseEnabled = false;
				
				btnOK.addChild(txtOK);
				btnOK.addEventListener(MouseEvent.CLICK, onPromptOK);
				
				_promptContainer.addChild(title);
				_promptContainer.addChild(_promptInput);
				_promptContainer.addChild(btnOK);
				
				if (_pocket && _pocket.game && _pocket.game.ui) {
					_pocket.game.ui.addChild(_promptContainer);
				} else {
					_pocket.addChild(_promptContainer);
				}
			} catch (err:Error) {
				if (_pocket && _pocket.game && _pocket.game.MsgBox) {
					_pocket.game.MsgBox.notify("Error: " + err.message);
				}
			}
		}

		private static function hidePrompt():void {
			if (_promptContainer != null && _promptContainer.parent != null) {
				_promptContainer.parent.removeChild(_promptContainer);
			}
			_promptContainer = null;
			_promptInput = null;
		}
		
		private static function onPromptOK(e:MouseEvent):void {
			if (_promptInput != null && _promptInput.text.length > 0) {
				var parts:Array = _promptInput.text.split(",");
				_questIDs = [];
				for (var i:int = 0; i < parts.length; i++) {
					var raw:String = parts[i];
					var subParts:Array = raw.split(":");
					var val:int = parseInt(subParts[0]);
					if (!isNaN(val) && val > 0) {
						var itemId:int = -1;
						if (subParts.length > 1) {
							itemId = parseInt(subParts[1]);
						}
						_questIDs.push({qid: val, itemId: itemId});
					}
				}
			}
			hidePrompt();
			
			if (_questIDs.length > 0) {
				start();
			}
		}

		private static function stop():void {
			if (_timer != null) {
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTick);
				_timer = null;
				if (_pocket && _pocket.game && _pocket.game.MsgBox) {
					_pocket.game.MsgBox.notify("Auto-Quest Disabled");
				}
			}
		}

		private static function start():void {
			stop();
			_lastTurnIns = {};
			_timer = new Timer(4000); // Check every 4 seconds to prevent lag spam
			_timer.addEventListener(TimerEvent.TIMER, onTick, false, 0, true);
			_timer.start();

			if (_pocket && _pocket.game && _pocket.game.MsgBox) {
				
			var strList:Array = [];
			for (var i:int = 0; i < _questIDs.length; i++) {
				if (_questIDs[i].itemId > 0) strList.push(_questIDs[i].qid + ":" + _questIDs[i].itemId);
				else strList.push(_questIDs[i].qid);
			}
			_pocket.game.MsgBox.notify("Auto-Quest Enabled: " + strList.join(","));

			}
		}

		private static function onTick(e:TimerEvent):void {
			if (!_pocket || !_pocket.game || !_pocket.game.world) return;
			var world:* = _pocket.game.world;

			try {
				if (world.questTree != null) {
					var now:Number = new Date().getTime();
					for (var i:int = 0; i < _questIDs.length; i++) {
						var qObj:Object = _questIDs[i];
						var qid:int = qObj.qid;
						var itemId:int = qObj.itemId;
						
						if (world.questTree[qid] != null) {
							var quest:* = world.questTree[qid];
							
							var lastAttempt:Number = 0;
							if (_lastTurnIns[qid] != null) {
								lastAttempt = _lastTurnIns[qid];
							}
							if (now - lastAttempt < 6000) {
								continue;
							}

							if (quest.status == "c") {
								if (world.tryQuestComplete != null) {
									_lastTurnIns[qid] = now;
									if (itemId > 0) {
										world.tryQuestComplete(qid, itemId);
										trace("AutoQuest: Attempted tryQuestComplete for " + qid + " with item " + itemId);
									} else {
										world.tryQuestComplete(qid);
										trace("AutoQuest: Attempted tryQuestComplete for " + qid);
									}
									// Only turn in one quest per tick to prevent server spam!
									break;
								}
							}
						}
					}
				}
			} catch (err:Error) {
				trace("AutoQuest Error: " + err.message);
			}
		}
	}
}
