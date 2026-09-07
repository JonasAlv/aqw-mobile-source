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

	import Pocket;

	public class AutoCombat {

		private static var _pocket:Pocket;
		private static var _timer:Timer;
		private static var _isSmart:Boolean = false;
		private static var _customRotation:Array = [5, 4, 3, 2];
		private static var _rotationIndex:int = 0;
		private static var _lockedMMID:String = null;
		
		private static var _promptContainer:Sprite;
		private static var _promptInput:TextField;

		public static function toggleSmart(pocket:Pocket):void {
			_pocket = pocket;
			if (_timer != null && _isSmart) {
				stop();
			} else {
				start(true);
			}
		}

		public static function toggleCustom(pocket:Pocket):void {
			_pocket = pocket;
			if (_timer != null && !_isSmart) {
				stop();
			} else {
				showPrompt();
			}
		}
		
		public static function showPrompt(pocket:Pocket = null):void {
			if (pocket != null) _pocket = pocket;
			if (_promptContainer != null) {
				hidePrompt();
			}
			
			if (_pocket && _pocket.game && _pocket.game.MsgBox) {
				_pocket.overlay.notification("Opening Custom Auto-Combat Settings...");
			}
			
			try {
				_promptContainer = new Sprite();
				_promptContainer.graphics.beginFill(0x222222, 0.95);
				_promptContainer.graphics.lineStyle(4, 0xFF0000);
				_promptContainer.graphics.drawRoundRect(0, 0, 400, 200, 20, 20);
				_promptContainer.graphics.endFill();
				
				_promptContainer.x = (960 - 400) / 2;
				_promptContainer.y = (550 - 200) / 2;
				
				var title:TextField = new TextField();
				var tfTitle:TextFormat = new TextFormat("_sans", 24, 0xFFFFFF, true);
				tfTitle.align = TextFormatAlign.CENTER;
				title.defaultTextFormat = tfTitle;
				title.text = "Enter Skill Rotation (e.g. 54321)";
				title.width = 400;
				title.y = 30;
				title.selectable = false;
				
				_promptInput = new TextField();
				_promptInput.type = TextFieldType.INPUT;
				
				var tfInput:TextFormat = new TextFormat("_sans", 32, 0x000000, true);
				tfInput.align = TextFormatAlign.CENTER;
				_promptInput.defaultTextFormat = tfInput;
				_promptInput.background = true;
				_promptInput.backgroundColor = 0xFFFFFF;
				_promptInput.border = true;
				_promptInput.borderColor = 0x000000;
				_promptInput.width = 250;
				_promptInput.height = 50;
				_promptInput.x = 75;
				_promptInput.y = 80;
				_promptInput.maxChars = 10;
				_promptInput.restrict = "1-6";
				_promptInput.text = _customRotation.join("");
				
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
					_pocket.overlay.notification("Error: " + err.message);
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
				_customRotation = [];
				for (var i:int = 0; i < _promptInput.text.length; i++) {
					var num:int = parseInt(_promptInput.text.charAt(i));
					if (!isNaN(num) && num >= 1 && num <= 6) {
						_customRotation.push(num);
					}
				}
			}
			hidePrompt();
			
			if (_customRotation.length == 0) {
				_customRotation = [5, 4, 3, 2];
			}
			
			start(false);
		}

		private static function stop():void {
			if (_timer != null) {
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTick);
				_timer = null;
				if (_pocket && _pocket.game && _pocket.game.MsgBox) {
					_pocket.overlay.notification("Auto-Combat Disabled");
				}
			}
		}

		private static function start(smart:Boolean):void {
			stop();
			_isSmart = smart;
			_lockedMMID = null;
			_rotationIndex = 0;

			if (_pocket && _pocket.game && _pocket.game.world && _pocket.game.world.myAvatar) {
				var avatar:* = _pocket.game.world.myAvatar;
				if (avatar.target != null) {
					if (avatar.target.dataLeaf != null && avatar.target.dataLeaf.MonMapID != null) {
						_lockedMMID = String(avatar.target.dataLeaf.MonMapID);
					} else if (avatar.target.objData != null && avatar.target.objData.MonMapID != null) {
						_lockedMMID = String(avatar.target.objData.MonMapID);
					}
				}
			}
			
			_timer = new Timer(300);
			_timer.addEventListener(TimerEvent.TIMER, onTick, false, 0, true);
			_timer.start();

			if (_pocket && _pocket.game && _pocket.game.MsgBox) {
				var msg:String = _isSmart ? "Smart Auto-Combat Enabled" : "Custom Auto-Combat Enabled: " + _customRotation.join("-");
				if (_lockedMMID != null) {
					msg += "\nLocked to MMID: " + _lockedMMID;
				}
				_pocket.overlay.notification(msg);
			}
		}

		private static function onTick(e:TimerEvent):void {
			if (!_pocket || !_pocket.game || !_pocket.game.world || !_pocket.game.world.myAvatar) {
				return;
			}

			var world:* = _pocket.game.world;
			var avatar:* = world.myAvatar;
			var target:* = avatar.target;

			// If current target is dead, clear it
			if (target != null && target.dataLeaf != null && target.dataLeaf.intHP <= 0) {
				if (world.cancelTarget != null) {
					world.cancelTarget();
				}
				target = null;
			}

			// Auto-Targeting Logic
			if (target == null) {
				var cellMonsters:Array = null;
				try {
					cellMonsters = world.getMonstersByCell(world.strFrame);
				} catch (err:Error) { }
				
				if (cellMonsters != null) {
					for each (var m:* in cellMonsters) {
						if (m != null && m.dataLeaf != null && m.dataLeaf.intState > 0 && m.dataLeaf.intHP > 0) {
							if (_lockedMMID != null) {
								var mmid:String = null;
								if (m.dataLeaf.MonMapID != null) mmid = String(m.dataLeaf.MonMapID);
								else if (m.objData != null && m.objData.MonMapID != null) mmid = String(m.objData.MonMapID);
								
								if (mmid != _lockedMMID) continue;
							}

							if (world.setTarget != null) {
								world.setTarget(m);
								target = m;
								break;
							}
						}
					}
				}
			}

			// Still no target? Wait for next tick.
			if (target == null) {
				return;
			}

			var rotation:Array = _customRotation;

			if (_isSmart) {
				var className:String = "";
				if (avatar.objData && avatar.objData.strClassName) {
					className = avatar.objData.strClassName.toLowerCase();
				}

				if (className.indexOf("legion revenant") != -1) {
					rotation = [5, 2, 3, 4, 1];
				} else if (className.indexOf("void highlord") != -1) {
					rotation = [4, 5, 3, 2, 1];
				} else if (className.indexOf("archmage") != -1) {
					rotation = [3, 2, 5, 4, 1];
				} else if (className.indexOf("lightcaster") != -1 || className.indexOf("stonecrusher") != -1) {
					rotation = [3, 4, 2, 5, 1];
				} else if (className.indexOf("lord of order") != -1 || className.indexOf("archpaladin") != -1) {
					rotation = [2, 3, 4, 5, 1];
				} else if (className.indexOf("yami no ronin") != -1) {
					rotation = [2, 5, 4, 3, 1];
				} else if (className.indexOf("chaos avenger") != -1) {
					rotation = [5, 4, 3, 2, 1];
				} else {
					rotation = [5, 4, 3, 2, 1]; // Default smart fallback
				}
				
				// SMART MODE: Priority-based execution
				for each (var idx:int in rotation) {
					if (tryFireSkill(world, avatar, idx)) {
						break;
					}
				}
			} else {
				// CUSTOM MODE: Strict sequential execution
				if (_rotationIndex >= rotation.length) {
					_rotationIndex = 0;
				}
				
				var currentIdx:int = rotation[_rotationIndex];
				if (tryFireSkill(world, avatar, currentIdx)) {
					_rotationIndex++;
					if (_rotationIndex >= rotation.length) {
						_rotationIndex = 0;
					}
				}
			}
		}

		private static function tryFireSkill(world:*, avatar:*, idx:int):Boolean {
			if (!_pocket.game.ui || !_pocket.game.ui.mcInterface || !_pocket.game.ui.mcInterface.actBar) return false;

			var icon:* = _pocket.game.ui.mcInterface.actBar.getChildByName("i" + idx);
			if (icon != null && icon.actObj != null) {
				
				if (icon.actObj.isOK === false) {
					return false; // Skill is not unlocked yet
				}

				// We MUST use uoTreeLeaf for live player stats (MP/HP)
				// avatar.dataLeaf only updates for monsters, not the local player
				var pStats:* = null;
				if (world.uoTreeLeaf != null && avatar.pnm != null) {
					pStats = world.uoTreeLeaf(avatar.pnm);
				}

				// Mana check
				var cost:int = 0;
				if (icon.actObj.mp != null) {
					cost = parseInt(icon.actObj.mp);
				}
				var currentMp:int = 0;
				if (pStats != null && pStats.intMP != null) {
					currentMp = pStats.intMP;
				} else if (avatar.dataLeaf && avatar.dataLeaf.intMP != null) { // Fallback just in case
					currentMp = avatar.dataLeaf.intMP;
				}
				if (currentMp < cost) {
					return false; // Not enough mana
				}
				
				// HP check
				var hpCost:int = 0;
				if (icon.actObj.hp != null) {
					hpCost = parseInt(icon.actObj.hp);
				}
				var currentHp:int = 0;
				if (pStats != null && pStats.intHP != null) {
					currentHp = pStats.intHP;
				} else if (avatar.dataLeaf && avatar.dataLeaf.intHP != null) { // Fallback
					currentHp = avatar.dataLeaf.intHP;
				}
				// If a skill costs health, make sure we have more than the cost to avoid suicide/failure
				if (hpCost > 0 && currentHp <= hpCost) {
					return false;
				}

				var isReady:Boolean = false;
				
				if (world.actionTimeCheck != null) {
					isReady = world.actionTimeCheck(icon.actObj);
				} else {
					// Fallback if actionTimeCheck is missing
					isReady = true;
					var now:Number = new Date().getTime();
					if (world.ActionResults && world.ActionResults[icon.actObj.ref] != null) {
						var ts:Number = world.ActionResults[icon.actObj.ref].ts;
						var cd:Number = icon.actObj.cd;
						if ((now - ts) < cd) {
							isReady = false;
						}
					}
				}

				if (isReady) {
					if (icon.actObj.auto) {
						world.approachTarget();
					} else {
						world.testAction(icon.actObj);
					}
					return true; // Successfully fired
				}
			}
			return false; // Skill not fired
		}
	}
}
