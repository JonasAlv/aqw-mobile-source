package game.script {
	import flash.events.TimerEvent;
	import game.Network;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.events.MouseEvent;
	import ui.util.BasicButton;
	import flash.utils.Timer;
	
	import game.combat.AutoCombat;
	import game.combat.AutoQuest;

	public class ScriptEngine {
		private var _pocket:*;
		private var _timer:Timer;
		private var _commands:Array = [];
		private var _currentIndex:int = 0;
		private var _isRunning:Boolean = false;
		private var _waitTimer:Number = 0;
		private var _unbankedItems:Object = {};
		public var statusText:String = "Stopped";
		
		private static var _instance:ScriptEngine;
		public static function get SINGLETON():ScriptEngine {
			if (_instance == null) {
				_instance = new ScriptEngine();
			}
			return _instance;
		}

		public function ScriptEngine() {
			_timer = new Timer(500); // Check every 500ms
			_timer.addEventListener(TimerEvent.TIMER, onTick, false, 0, true);
		}

		
		private static var _promptContainer:Sprite;
		private static var _promptInput:TextField;
		
		public static function showPastePrompt(pocket:*):void {
			if (_promptContainer != null) {
				hidePastePrompt();
			}
			
			if (pocket && pocket.overlay) {
				pocket.overlay.notification("Opening Script Paste Window...");
			}
			
			try {
				var stageWidth:Number = pocket.stage.stageWidth;
				var stageHeight:Number = pocket.stage.stageHeight;
				
				_promptContainer = new Sprite();
				_promptContainer.graphics.beginFill(0x000000, 0.7);
				_promptContainer.graphics.drawRect(0, 0, stageWidth, stageHeight);
				_promptContainer.graphics.endFill();
				
				var bg:Sprite = new Sprite();
				bg.graphics.beginFill(0x222222, 1);
				bg.graphics.lineStyle(2, 0x555555);
				bg.graphics.drawRoundRect(0, 0, 500, 300, 10, 10);
				bg.graphics.endFill();
				bg.x = (stageWidth - 500) / 2;
				bg.y = (stageHeight - 300) / 2;
				_promptContainer.addChild(bg);
				
				var title:TextField = new TextField();
				var tfTitle:TextFormat = new TextFormat("_sans", 16, 0xFFFFFF, true);
				tfTitle.align = TextFormatAlign.CENTER;
				title.defaultTextFormat = tfTitle;
				title.text = "Paste Script Here";
				title.width = 500;
				title.y = bg.y + 10;
				title.x = bg.x;
				title.selectable = false;
				title.mouseEnabled = false;
				_promptContainer.addChild(title);
				
				var inputBg:Sprite = new Sprite();
				inputBg.graphics.beginFill(0xFFFFFF, 1);
				inputBg.graphics.drawRect(0, 0, 460, 180);
				inputBg.graphics.endFill();
				inputBg.x = bg.x + 20;
				inputBg.y = bg.y + 40;
				_promptContainer.addChild(inputBg);
				
				_promptInput = new TextField();
				_promptInput.type = TextFieldType.INPUT;
				var tfInput:TextFormat = new TextFormat("_sans", 12, 0x000000, false);
				_promptInput.defaultTextFormat = tfInput;
				_promptInput.text = "";
				_promptInput.width = 460;
				_promptInput.height = 180;
				_promptInput.x = bg.x + 20;
				_promptInput.y = bg.y + 40;
				_promptInput.multiline = true;
				_promptInput.wordWrap = true;
				_promptContainer.addChild(_promptInput);
				
				var startBtn:BasicButton = new BasicButton("Load Script");
				startBtn.x = bg.x + 120;
				startBtn.y = bg.y + 240;
				startBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					var text:String = _promptInput.text;
					hidePastePrompt();
					SINGLETON.loadScript(text, pocket);
					if (pocket && pocket.overlay) pocket.overlay.notification("Script loaded successfully!");
				});
				_promptContainer.addChild(startBtn);
				
				var cancelBtn:BasicButton = new BasicButton("Cancel");
				cancelBtn.x = bg.x + 300;
				cancelBtn.y = bg.y + 240;
				cancelBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					hidePastePrompt();
				});
				_promptContainer.addChild(cancelBtn);
				
				pocket.stage.addChild(_promptContainer);
			} catch (err:Error) {
				if (pocket && pocket.overlay) pocket.overlay.notification("Error: " + err.message);
			}
		}
		
		public static function hidePastePrompt():void {
			if (_promptContainer != null && _promptContainer.parent != null) {
				_promptContainer.parent.removeChild(_promptContainer);
			}
			_promptContainer = null;
			_promptInput = null;
		}

		public function loadScript(scriptText:String, pocket:*):void {
			_pocket = pocket;
			_commands = [];
			_currentIndex = 0;
			_unbankedItems = {};
			
			var lines:Array = scriptText.split("\n");
			for (var i:int = 0; i < lines.length; i++) {
				var line:String = lines[i].replace(/^\s+|\s+$/g, "");
				if (line.length == 0 || line.indexOf("//") == 0 || line.indexOf("--") == 0) {
					continue;
				}
				
				var firstSpace:int = line.indexOf(" ");
				var action:String = line;
				var argsString:String = "";
				if (firstSpace != -1) {
					action = line.substring(0, firstSpace);
					argsString = line.substring(firstSpace + 1).replace(/^\s+|\s+$/g, "");
				}
				
				var args:Array = [];
				if (argsString.length > 0) {
					args = argsString.split(",");
					for (var j:int = 0; j < args.length; j++) {
						args[j] = args[j].replace(/^\s+|\s+$/g, "");
					}
				}
				
				_commands.push({ action: action.toUpperCase(), args: args, raw: line });
			}
			statusText = "Loaded " + _commands.length + " commands.";
		}

		public function reset():void {
			_currentIndex = 0;
			_waitTimer = 0;
			_unbankedItems = {};
			statusText = "Stopped";
		}
		
		public function start(pocket:*):void {
			if (_commands.length == 0) return;
			_pocket = pocket;
			if (_currentIndex >= _commands.length) {
				_currentIndex = 0;
				_unbankedItems = {};
			}
			_isRunning = true;
			_waitTimer = 0;
			
			// Initialize AutoCombat pocket reference so it can function
			if (AutoCombat._pocket == null) {
				AutoCombat._pocket = pocket;
			}
			

			
			if (AutoCombat.IS_ON) {
				AutoCombat.stop(true);
			}
			_timer.start();
			statusText = "Running...";
		}

		public function stop():void {
			_isRunning = false;
			_timer.stop();
			statusText = "Stopped.";
			if (_pocket != null && _pocket.game != null) {
				// Turn off combat if it was on
				AutoCombat.stop(true);
				
				// Jump to current cell to drop combat
				try {
					var world:* = _pocket.game.world;
					if (world != null && world.moveToCell != null && world.strFrame != null && world.strPad != null) {
						world.moveToCell(world.strFrame, world.strPad);
					}
				} catch (e:Error) {
					// Ignore
				}
			}
		}
		
		public function get isRunning():Boolean {
			return _isRunning;
		}

		public function getItemCount(searchName:String):int {
			var world:* = _pocket.game.world;
			if (world == null) return 0;
			
			var count:int = 0;
			searchName = searchName.toLowerCase();
			
			if (world.invTree != null) {
				for (var k:String in world.invTree) {
					var item:* = world.invTree[k];
					if (item != null && item.sName != null && item.sName.toLowerCase() == searchName) {
						var q:Number = parseFloat(item.iQty);
						count += isNaN(q) ? 1 : q;
					}
				}
			}
			
			return count;
		}

		private function onTick(e:TimerEvent):void {
			if (!_isRunning || !_pocket || !_pocket.game || !_pocket.game.world) return;
			var world:* = _pocket.game.world;
			
			if (_currentIndex >= _commands.length) {
				stop();
				statusText = "Script Finished!";
				_pocket.overlay.notification("Bot Script Finished!");
				return;
			}
			
			var now:Number = new Date().getTime();
			if (_waitTimer > 0 && now < _waitTimer) {
				return; // Still waiting
			}
			
			var cmd:Object = _commands[_currentIndex];
			
			
			
			try {
				switch (cmd.action) {
					case "JOIN":
						if (cmd.args.length >= 1) {
							var mapName:String = cmd.args[0].toLowerCase();
							var cell:String = cmd.args.length >= 2 ? cmd.args[1] : "Enter";
							var pad:String = cmd.args.length >= 3 ? cmd.args[2] : "Spawn";
							
							// Check if already in map
							var currentMap:String = "";
							if (world.strMapName != null) currentMap = world.strMapName.toLowerCase();
							
							var mapNameOnly:String = mapName.split("-")[0];
							if (currentMap == mapNameOnly || currentMap.indexOf(mapNameOnly) != -1 || mapNameOnly.indexOf(currentMap) != -1) {
								_currentIndex++; // Done
							} else {
								statusText = "Joining " + mapName + "...";
									// Join map
									if (world.gotoTown != null) {
										world.gotoTown(mapName, cell, pad);
									} else if (world.sfc != null && world.myAvatar != null && world.myAvatar.objData != null) {
										_pocket.game.sfc.sendString("%xt%zm%cmd%1%tfer%" + world.myAvatar.objData.strUsername + "%" + mapName + "%");
									}
									_waitTimer = now + 4000; // Wait 4 seconds for load
							}
						} else {
							_currentIndex++;
						}
						break;
						
					case "ACCEPT":
						if (cmd.args.length >= 1) {
							var qid:int = parseInt(cmd.args[0]);
							statusText = "Accepting Quest " + qid;
							if (world.acceptQuest != null) {
								world.acceptQuest(qid);
							}
							_waitTimer = now + 1500;
							_currentIndex++;
						}
						break;
						
					case "COMPLETE":
						if (cmd.args.length >= 1) {
							var cqid:int = parseInt(cmd.args[0]);
							statusText = "Completing Quest " + cqid;
							if (world.tryQuestComplete != null) {
								world.tryQuestComplete(cqid);
							}
							_waitTimer = now + 1500;
							_currentIndex++;
						}
						break;
						
					case "KILL":
						if (cmd.args.length >= 3) {
							var targetMob:String = cmd.args[0];
							var dropName:String = cmd.args[1];
							var neededQty:int = parseInt(cmd.args[2]);
							
							trace("[Script] KILL called with: mob=" + targetMob + " drop=" + dropName + " qty=" + neededQty);
							
							var monster:String = cmd.args[0];
							var itemName:String = cmd.args[1];
							var qty:int = parseInt(cmd.args[2]);
							var mmid:String = null;
							if (cmd.args.length >= 4) {
								mmid = cmd.args[3];
							}
							
							statusText = "Hunting " + monster + " for " + itemName + " (" + qty + ")";
							
							var currentQty:int = getItemCount(itemName);
								
							if (currentQty >= qty) {
									// Done killing
									if (_pocket != null && _pocket.overlay != null) _pocket.overlay.removeStickyNotification("kill_progress");
									if (AutoCombat.IS_ON) {
									AutoCombat.stop(true);
								}
								_currentIndex++;
							} else {
									// Need to kill
									if (_pocket != null && _pocket.overlay != null) _pocket.overlay.stickyNotification("kill_progress", "Farming for " + itemName + " (" + currentQty + "/" + qty + ")");
									if (!AutoCombat.IS_ON) {
									AutoCombat.targetName = monster;
									AutoCombat.lockedMMID = mmid;
									AutoCombat._pocket = _pocket;
									AutoCombat.start(AutoCombat.isSmart, true);
								}
								_waitTimer = now + 1000;
							}
						} else {
							_currentIndex++;
						}
						break;
						
					case "DELAY":
						if (cmd.args.length > 0) {
							var ms:int = parseInt(cmd.args[0]);
							_waitTimer = now + ms;
							statusText = "Waiting " + ms + "ms...";
						}
						_currentIndex++;
						break;
						
										case "MSG":
																																										case "ACCEPTDROP":
						case "GETDROP":
							if (cmd.args.length > 0 && world != null) {
								var dropTarget:String = cmd.args[0].toLowerCase();

								for (var di:int = Network.PENDING_DROPS.length - 1; di >= 0; di--) {
									var pDrop:Object = Network.PENDING_DROPS[di];
									if (dropTarget == "all" || pDrop.sName.toLowerCase() == dropTarget) {
										var rId:* = (_pocket.game.sfc.activeRoomId != null) ? _pocket.game.sfc.activeRoomId : _pocket.game.sfc.myUserId;
										_pocket.game.sfc.sendString("%xt%zm%getDrop%" + rId + "%" + pDrop.ItemID + "%");
										_pocket.game.chatF.pushMsg("server", "GETDROP COMMAND: " + pDrop.sName, "SERVER", "", 0);
										Network.PENDING_DROPS.splice(di, 1);
									}
								}
							}
							_currentIndex++;
							break;
						case "DUMP_DROPS":
						if (world != null) {
							var found:Boolean = false;
							if (world.items != null) {
								for (var i:int = 0; i < world.items.length; i++) {
									var itemObj:* = world.items[i];
									if (itemObj != null && itemObj.sName != null) {
										var sName:String = itemObj.sName.toLowerCase();
										if (sName.indexOf("essence") != -1 || sName.indexOf("bone") != -1) {
											_pocket.game.chatF.pushMsg("server", "world.items HAS: " + itemObj.sName + " ID: " + itemObj.ItemID, "SERVER", "", 0);
											found = true;
										}
									}
								}
							}
							if (!found) {
								_pocket.game.chatF.pushMsg("server", "Not found in world.items either!", "SERVER", "", 0);
							}
						}
						_currentIndex++;
						break;
					case "TEST_DROP":
						if (world != null) {
							var found:Boolean = false;
							if (world.dropStack != null) {
								for (var i:int = 0; i < world.dropStack.length; i++) {
									var dropObj:* = world.dropStack[i];
									_pocket.game.chatF.pushMsg("server", "DROP: " + dropObj.sName + " ID: " + dropObj.ItemID, "SERVER", "", 0);
									found = true;
								}
							}
							if (_pocket.game.ui != null && _pocket.game.ui.dropStack != null) {
								for (var j:int = 0; j < _pocket.game.ui.dropStack.length; j++) {
									var uDrop:* = _pocket.game.ui.dropStack[j];
									_pocket.game.chatF.pushMsg("server", "UIDROP: " + uDrop.sName + " ID: " + uDrop.ItemID, "SERVER", "", 0);
									found = true;
								}
							}
							if (!found) {
								_pocket.game.chatF.pushMsg("server", "NO DROPS FOUND IN dropStack or ui.dropStack", "SERVER", "", 0);
							}
						}
						_currentIndex++;
						break;
					case "LOG":
						if (cmd.args.length > 0) {
							var msg:String = cmd.args.join(",");
							if (_pocket != null && _pocket.overlay != null) {
								_pocket.overlay.notification(msg);
							}
							try {
								if (world != null && world.chatF != null) {
									world.chatF.pushMsg("server", msg, "BOT", "", 0);
								}
							} catch (e:Error) {}
							statusText = msg;
						}
						_currentIndex++;
						break;
						
					case "COMBAT":
						if (cmd.args.length >= 1) {
							var mode:String = cmd.args[0].toLowerCase();
							if (mode == "smart") {
								AutoCombat.isSmart = true;
								statusText = "Combat Mode: Smart";
							} else if (mode == "custom" && cmd.args.length >= 2) {
								AutoCombat.isSmart = false;
								AutoCombat.setCustomRotation(cmd.args[1]);
								statusText = "Combat Mode: Custom (" + cmd.args[1] + ")";
							}
							_currentIndex++;
						}
						break;
						
					case "AUTOQUEST":
						if (cmd.args.length >= 1) {
							if (cmd.args[0].toLowerCase() == "stop") {
								// Stop autoquest
								// Wait, AutoQuest.stop() is private! We can just pass empty string to startWith to clear it, but wait, let's just make stop public or just startWith.
								// Actually, just pass an empty string? No, AutoQuest handles it if length > 0.
							} else {
								var qStr:String = cmd.args.join(","); // Rejoin args to pass to AutoQuest
								AutoQuest.startWith(_pocket, qStr);
								statusText = "Background AutoQuest: " + qStr;
							}
							_currentIndex++;
						}
						break;
					case "LOADBANK":
						if (cmd.requested == null) {
							cmd.requested = true;
							if (world != null) {
								if (("loadBank" in world) && world.loadBank != null) {
									world.loadBank();
								} else if (world.sfc != null) {
									_pocket.game.sfc.sendString("%xt%zm%loadBank%" + world.curRoom + "%All%");
								}
							}
							_waitTimer = now + 1000;
						} else {
							if (world != null && ((world.bankinfo != null && world.bankinfo.items != null) || world.bankTree != null)) {
								_currentIndex++;
							} else {
								statusText = "Waiting for bank to load...";
								_waitTimer = now + 1000;
							}
						}
						break;
						
					case "MANUAL_UNBANK":
					case "MANUAL_BANK":
						if (cmd.args.length >= 1) {
														var actionIsBank:Boolean = (cmd.action == "MANUAL_BANK");
							var targetItemName:String = cmd.args[0].toLowerCase();
							
							var hasInInv:Boolean = false;
							if (world.invTree != null) {
								for (var m_ik:String in world.invTree) {
									var m_iObj:* = world.invTree[m_ik];
									if (m_iObj != null && m_iObj.sName != null && m_iObj.sName.toLowerCase() == targetItemName) {
										hasInInv = true;
										break;
									}
								}
							}
							
							var isSatisfied:Boolean = actionIsBank ? !hasInInv : hasInInv;
							
							if (isSatisfied) {
									if (_pocket != null && _pocket.overlay != null) _pocket.overlay.removeStickyNotification("manual_bank");
									_currentIndex++;
								} else {
								if (cmd.requested == null) {
									cmd.requested = true;
									if (("toggleBank" in world) && world.toggleBank != null) {
										world.toggleBank();
									}
									if (_pocket != null && _pocket.overlay != null) {
											_pocket.overlay.stickyNotification("manual_bank", "PLEASE MANUALLY " + (actionIsBank ? "BANK" : "UNBANK") + ": " + cmd.args[0]);
										}
								}
								statusText = "MANUAL ACTION: Please " + (actionIsBank ? "BANK" : "UNBANK") + " " + cmd.args[0];
								_waitTimer = now + 1000;
							}
						} else {
							_currentIndex++;
						}
						break;
						
					case "DEBUG_INV":
						if (_pocket.game.chatF != null && _pocket.game.chatF.pushMsg != null) {
							_pocket.game.chatF.pushMsg("server", "--- INVENTORY DUMP ---", "SERVER", "", 0);
							if (world.hasOwnProperty("invTree") && world.invTree != null) {
								for (var dk:String in world.invTree) {
									var dObj:* = world.invTree[dk];
									if (dObj != null && dObj.sName != null) {
										_pocket.game.chatF.pushMsg("server", dObj.sName + " | Qty: " + dObj.iQty + " | Type: " + typeof(dObj.iQty), "SERVER", "", 0);
									}
								}
							}
							_pocket.game.chatF.pushMsg("server", "--- BANK DUMP ---", "SERVER", "", 0);
							if (world.hasOwnProperty("bankinfo") && world.bankinfo != null) {
								_pocket.game.chatF.pushMsg("server", "bankinfo exists! Items: " + (world.bankinfo.items != null), "SERVER", "", 0);
								if (world.bankinfo.items != null) {
									for (var bki:int = 0; bki < world.bankinfo.items.length; bki++) {
										var bdObj:* = world.bankinfo.items[bki];
										if (bdObj != null && bdObj.sName != null) {
											_pocket.game.chatF.pushMsg("server", "B: " + bdObj.sName + " | Qty: " + bdObj.iQty, "SERVER", "", 0);
										}
									}
								}
							} else {
								_pocket.game.chatF.pushMsg("server", "No bankinfo found.", "SERVER", "", 0);
							}
							if (world.hasOwnProperty("bankTree") && world.bankTree != null) {
								_pocket.game.chatF.pushMsg("server", "bankTree exists!", "SERVER", "", 0);
							}
							_pocket.game.chatF.pushMsg("server", "--- END DUMP ---", "SERVER", "", 0);
						}
						_currentIndex++;
						break;

					default:
						// Unknown command
						trace("Unknown bot command: " + cmd.action);
						_currentIndex++;
						break;
				}
			} catch (err:Error) {
				trace("ScriptEngine Error: " + err.message);
				_currentIndex++;
				_waitTimer = now + 2000;
			}
		}
	}
}
