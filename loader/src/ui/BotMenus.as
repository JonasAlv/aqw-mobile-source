package ui {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.Overlay;
	import ui.option.Menu;
	import ui.option.Option;
	import ui.option.Button;
	import ui.option.Check;
	import com.aqwapi.modules.ScriptManager;
	import com.aqwapi.modules.CombatManager;
	import com.aqwapi.AQWApi;
	import util.HelperSetting;
	
	POCKET::IS_DESKTOP { 
		import flash.filesystem.File; 
		import flash.filesystem.FileStream; 
		import flash.filesystem.FileMode; 
		import flash.net.FileFilter; 
	}

	public class BotMenus {
		private static var _injected:Boolean = false;
		private static var _promptContainer:Sprite;
		private static var _promptInput:TextField;
		private static var _lastQuests:String = "";
		private static var _lastCombat:String = "";
		
		
		public static var anthonyMenus:Vector.<Menu>;
		public static var botMenus:Vector.<Menu>;
		
		public static function inject(overlay:Overlay):void {
			if (_injected) return;
			_injected = true;
			var pocket:* = overlay.parent;

			anthonyMenus = overlay.menus;

			var scriptsOpts:Vector.<Option> = new <Option>[
				new Button(null, "Paste Script", "Paste a raw text script.", "Paste", function(o:Option):void { pocket.overlay.gotoAndStop("Init"); showPastePrompt(pocket); })
			];
			
			POCKET::IS_DESKTOP {
				scriptsOpts.push(new Button(null, "Load Script (File)", "Load a script from a text file.", "Load", function(o:Option):void {
					var file:* = File.desktopDirectory;
					file.addEventListener(flash.events.Event.SELECT, function(ev:flash.events.Event):void {
						var stream:* = new FileStream();
						stream.open(file, FileMode.READ);
						var txt:String = stream.readUTFBytes(stream.bytesAvailable);
						stream.close();
						ScriptManager.SINGLETON.loadScript(txt, pocket);
						pocket.overlay.notification("Script loaded successfully!");
					});
					file.browseForOpen("Select Script", [new FileFilter("Text Files", "*.txt")]);
				}));
			}
			
			var startScriptCheck:Check = new Check(null, false, "Run Script", "Start or Stop the loaded script.", true, function(o:Option):void {
				var c:Check = o as Check;
				if (c.state) {
					ScriptManager.SINGLETON.reset();
					ScriptManager.SINGLETON.start(pocket);
					pocket.overlay.notification("Script Started!");
				} else {
					ScriptManager.SINGLETON.stop();
					pocket.overlay.notification("Script Stopped!");
				}
			});
			startScriptCheck.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				if (startScriptCheck.state != ScriptManager.SINGLETON.isRunning) {
					startScriptCheck.state = ScriptManager.SINGLETON.isRunning;
					startScriptCheck.syncState();
				}
			});
			scriptsOpts.push(startScriptCheck);

			var smartCombatCheck:Check = new Check(null, false, "Smart Combat", "Start smart auto combat.", true, function(o:Option):void { 
				var c:Check = o as Check;
				if (c.state) {
					AQWApi.combat.startSmart(); 
					pocket.overlay.notification("Smart Combat Started!"); 
				} else {
					AQWApi.combat.stopAuto();
					pocket.overlay.notification("Combat Stopped!");
				}
			});
			smartCombatCheck.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				if (AQWApi.combat != null && smartCombatCheck.state != AQWApi.combat.isAutoRunning) {
					smartCombatCheck.state = AQWApi.combat.isAutoRunning;
					smartCombatCheck.syncState();
				}
			});

			var customCombatCheck:Check = new Check(null, false, "Custom Combat", "Start custom combat sequence.", true, function(o:Option):void { 
				var c:Check = o as Check;
				if (c.state) {
					pocket.overlay.gotoAndStop("Init");
					showCombatPrompt(pocket); 
				} else {
					AQWApi.combat.stopAuto();
					pocket.overlay.notification("Combat Stopped!");
				}
			});
			customCombatCheck.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				if (AQWApi.combat != null && customCombatCheck.state != AQWApi.combat.isAutoRunning) {
					customCombatCheck.state = AQWApi.combat.isAutoRunning;
					customCombatCheck.syncState();
				}
			});

			var autoQuestCheck:Check = new Check(null, false, "Auto Quest", "Start accepting and completing quests.", true, function(o:Option):void { 
				var c:Check = o as Check;
				if (c.state) {
					pocket.overlay.gotoAndStop("Init");
					showQuestPrompt(pocket); 
				} else {
					AQWApi.quest.stopAuto();
					pocket.overlay.notification("Quests Stopped!");
				}
			});
			autoQuestCheck.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				if (AQWApi.quest != null && autoQuestCheck.state != AQWApi.quest.isAutoRunning) {
					autoQuestCheck.state = AQWApi.quest.isAutoRunning;
					autoQuestCheck.syncState();
				}
			});

			var levelingBotCheck:Check = new Check(null, false, "Leveling Bot", "Auto grind XP in shadowbattleon.", true, function(o:Option):void {
				var c:Check = o as Check;
				if (c.state) {
					var script:String = "JOIN shadowbattleon,Enter,Spawn\nAUTOQUEST 9421,9422,9423\nCOMBAT smart\n";
					ScriptManager.SINGLETON.reset();
					ScriptManager.SINGLETON.loadScript(script, pocket);
					ScriptManager.SINGLETON.start(pocket);
					pocket.overlay.notification("Leveling Bot Started!");
				} else {
					ScriptManager.SINGLETON.stop();
					pocket.overlay.notification("Leveling Bot Stopped!");
				}
			});
			levelingBotCheck.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				if (levelingBotCheck.state != ScriptManager.SINGLETON.isRunning) {
					levelingBotCheck.state = ScriptManager.SINGLETON.isRunning;
					levelingBotCheck.syncState();
				}
			});

			botMenus = new <Menu>[
				new Menu("Scripts", scriptsOpts),
				new Menu("Automation", new <Option>[
					levelingBotCheck,
					smartCombatCheck,
					customCombatCheck,
					autoQuestCheck
				]),
				new Menu("Settings", new <Option>[
					new Button(null, "Load Shop", "Load a shop by its ID.", "Load", function(o:Option):void { pocket.overlay.gotoAndStop("Init"); showShopPrompt(pocket); }),
					new Button(null, "Toggle Bank", "Open or close your bank.", "Toggle", function(o:Option):void { AQWApi.inventory.toggleBank(); }),
					new Check("bot_accept_loot", false, "Accept All Loot", "Automatically accept all dropped items.", true, function(o:Option):void {
						var c:Check = o as Check;
						if (AQWApi.drops != null) AQWApi.drops.acceptAll = c.state;
					}),
					new Check("bot_accept_ac_drops", false, "Accept AC Drops", "Automatically accept all AC-tagged (coin) drops.", true, function(o:Option):void {
						var c:Check = o as Check;
						if (AQWApi.drops != null) AQWApi.drops.acceptACs = c.state;
					})
				])
			];

			// Fix for timeline button recreation bug using Event Delegation
			overlay.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				if (overlay.currentFrameLabel == "Init" && overlay.showPanelBtn != null) {
					var isShowPanelBtn:Boolean = false;
					var curr:* = e.target;
					while (curr != null && curr != overlay) {
						if (curr == overlay.showPanelBtn) {
							isShowPanelBtn = true;
							break;
						}
						curr = curr.parent;
					}
					if (isShowPanelBtn) {
						overlay.menus = anthonyMenus;
					}
				}
			}, true); // Capture phase guarantees it runs before native handlers!

			var initialLootState:Boolean = HelperSetting.getBool("bot_accept_loot", false);
			if (AQWApi.drops != null) AQWApi.drops.acceptAll = initialLootState;

			var initialACState:Boolean = HelperSetting.getBool("bot_accept_ac_drops", false);
			if (AQWApi.drops != null) AQWApi.drops.acceptACs = initialACState;

			var icon:Sprite = new Sprite();
			icon.graphics.beginFill(0x990000, 0.95);
			icon.graphics.lineStyle(1, 0x660000);
			icon.graphics.drawRoundRect(0, 0, 80, 35, 8, 8); 
			icon.graphics.endFill();
			
			var txt:TextField = new TextField();
			txt.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
			txt.text = "Menu";
			txt.width = 80;
			txt.y = 8;
			txt.selectable = false;
			txt.mouseEnabled = false;
			icon.addChild(txt);
			
			icon.x = 80;
			icon.y = 10;
			icon.buttonMode = true;
			
			var theStage:* = pocket.stage;
			if (theStage != null) {
				theStage.addChild(icon);
			}

			var isDragging:Boolean = false;
			var hasDragged:Boolean = false;
			var dragStartX:Number = 0;
			var dragStartY:Number = 0;

			icon.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				isDragging = true;
				hasDragged = false;
				dragStartX = e.stageX - icon.x;
				dragStartY = e.stageY - icon.y;
			});

			if (theStage != null) {
				theStage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
					if (isDragging) {
						hasDragged = true;
						var nx:Number = e.stageX - dragStartX;
						var ny:Number = e.stageY - dragStartY;
						
						var sw:Number = theStage.stageWidth > 0 ? theStage.stageWidth : 960;
						var sh:Number = theStage.stageHeight > 0 ? theStage.stageHeight : 500;
						
						if (nx < 0) nx = 0;
						if (ny < 0) ny = 0;
						if (nx > sw - 80) nx = sw - 80;
						if (ny > sh - 35) ny = sh - 35;
						
						icon.x = nx;
						icon.y = ny;
					}
				});
				theStage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
					isDragging = false;
				});
			}

			icon.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				if (hasDragged) return;
				overlay.menus = botMenus;
				overlay.gotoAndStop("Panel");
			});
			
			overlay.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				if (pocket.config.option_disable_cutscenes && pocket.game != null && pocket.game.world != null) {
					if (("mcExtSWF" in pocket.game.world) && pocket.game.world.mcExtSWF != null && pocket.game.world.mcExtSWF.numChildren > 0) {
						var ext:* = pocket.game.world.mcExtSWF.getChildAt(0);
						if (ext != null && "totalFrames" in ext) {
							ext.gotoAndPlay(ext.totalFrames - 2);
							if ("showInterface" in pocket.game.world) {
								pocket.game.world.showInterface();
							}
						}
					}
				}

				var isPanelOpen:Boolean = (overlay.currentFrameLabel == "Panel");
				icon.visible = !isPanelOpen;
				
				if (isPanelOpen) {
					for (var i:int = 0; i < overlay.numChildren; i++) {
						var child:* = overlay.getChildAt(i);
						try {
							if (child.hasOwnProperty("text") && child["text"] == "Pocket") {
								child.visible = false;
							}
						} catch(err:*) {}
					}
					
					var isBotMenu:Boolean = (overlay.menus == botMenus);
					if (overlay.updateBtn != null) overlay.updateBtn.visible = !isBotMenu;
					if (overlay.discordBtn != null) overlay.discordBtn.visible = !isBotMenu;
					if (overlay.reportBugBtn != null) overlay.reportBugBtn.visible = !isBotMenu;
				}
			});
		}

		private static function showQuestPrompt(pocket:*):void {
			hidePrompt();
			_promptContainer = new Sprite();
			_promptContainer.graphics.beginFill(0x121212, 0.95);
			_promptContainer.graphics.lineStyle(1, 0x2A2A2A);
			_promptContainer.graphics.drawRoundRect(0, 0, 300, 160, 8, 8);
			_promptContainer.graphics.endFill();
			_promptContainer.x = (960 - 300) / 2;
			_promptContainer.y = (500 - 160) / 2;
			
			var title:TextField = new TextField();
			title.defaultTextFormat = new TextFormat("_sans", 14, 0xE0E0E0, true, null, null, null, null, TextFormatAlign.CENTER);
			title.text = "Enter Quest IDs (comma separated):";
			title.width = 300;
			title.y = 10;
			title.selectable = false;
			_promptContainer.addChild(title);
			
			_promptInput = new TextField();
			_promptInput.type = TextFieldType.INPUT;
			_promptInput.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF);
			_promptInput.border = true;
			_promptInput.borderColor = 0x555555;
			_promptInput.background = true;
			_promptInput.backgroundColor = 0x222222;
			_promptInput.x = 20;
			_promptInput.y = 40;
			_promptInput.width = 260;
			_promptInput.height = 25;
			_promptInput.text = _lastQuests;
			_promptContainer.addChild(_promptInput);
			
			var startBtn:Sprite = new Sprite();
			startBtn.graphics.beginFill(0x1E1E1E, 1);
			startBtn.graphics.lineStyle(1, 0x3A3A3A);
			startBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5);
			startBtn.graphics.endFill();
			startBtn.x = 20;
			startBtn.y = 80;
			startBtn.buttonMode = true;
			
			var startTxt:TextField = new TextField();
			startTxt.defaultTextFormat = new TextFormat("_sans", 12, 0xCCCCCC, true, null, null, null, null, TextFormatAlign.CENTER);
			startTxt.text = "Start";
			startTxt.width = 120;
			startTxt.y = 5;
			startTxt.selectable = false;
			startTxt.mouseEnabled = false;
			startBtn.addChild(startTxt);
			
			startBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { startBtn.graphics.clear(); startBtn.graphics.beginFill(0x333333, 1); startBtn.graphics.lineStyle(1, 0x555555); startBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); startBtn.graphics.endFill(); startTxt.textColor = 0xFFFFFF; });
			startBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { startBtn.graphics.clear(); startBtn.graphics.beginFill(0x1E1E1E, 1); startBtn.graphics.lineStyle(1, 0x3A3A3A); startBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); startBtn.graphics.endFill(); startTxt.textColor = 0xCCCCCC; });
			
			startBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				_lastQuests = _promptInput.text;
				var ids:Array = _lastQuests.split(",");
				var validIds:Array = [];
				for (var i:int = 0; i < ids.length; i++) {
					var qid:int = parseInt(String(ids[i]).replace(/^\s+|\s+$/g, ""));
					if (qid > 0) validIds.push(qid);
				}
				if (validIds.length > 0) {
					AQWApi.quest.startAuto(validIds.join(","));
					pocket.overlay.notification("Auto Quest started: " + validIds.join(", "));
				}
				hidePrompt();
			});
			_promptContainer.addChild(startBtn);
			
			var cancelBtn:Sprite = new Sprite();
			cancelBtn.graphics.beginFill(0x1E1E1E, 1);
			cancelBtn.graphics.lineStyle(1, 0x3A3A3A);
			cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5);
			cancelBtn.graphics.endFill();
			cancelBtn.x = 160;
			cancelBtn.y = 80;
			cancelBtn.buttonMode = true;
			
			var cancelTxt:TextField = new TextField();
			cancelTxt.defaultTextFormat = new TextFormat("_sans", 12, 0xCCCCCC, true, null, null, null, null, TextFormatAlign.CENTER);
			cancelTxt.text = "Cancel";
			cancelTxt.width = 120;
			cancelTxt.y = 5;
			cancelTxt.selectable = false;
			cancelTxt.mouseEnabled = false;
			cancelBtn.addChild(cancelTxt);
			
			cancelBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { cancelBtn.graphics.clear(); cancelBtn.graphics.beginFill(0x333333, 1); cancelBtn.graphics.lineStyle(1, 0x555555); cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); cancelBtn.graphics.endFill(); cancelTxt.textColor = 0xFFFFFF; });
			cancelBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { cancelBtn.graphics.clear(); cancelBtn.graphics.beginFill(0x1E1E1E, 1); cancelBtn.graphics.lineStyle(1, 0x3A3A3A); cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); cancelBtn.graphics.endFill(); cancelTxt.textColor = 0xCCCCCC; });
			
			cancelBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				hidePrompt();
			});
			_promptContainer.addChild(cancelBtn);
			
			if (pocket.overlay != null) {
				pocket.overlay.addChild(_promptContainer);
			}
		}

		private static function showCombatPrompt(pocket:*):void {
			hidePrompt();
			_promptContainer = new Sprite();
			_promptContainer.graphics.beginFill(0x121212, 0.95);
			_promptContainer.graphics.lineStyle(1, 0x2A2A2A);
			_promptContainer.graphics.drawRoundRect(0, 0, 300, 160, 8, 8);
			_promptContainer.graphics.endFill();
			_promptContainer.x = (960 - 300) / 2;
			_promptContainer.y = (500 - 160) / 2;
			
			var title:TextField = new TextField();
			title.defaultTextFormat = new TextFormat("_sans", 14, 0xE0E0E0, true, null, null, null, null, TextFormatAlign.CENTER);
			title.text = "Enter Skills (e.g. 1,2,3,4):";
			title.width = 300;
			title.y = 10;
			title.selectable = false;
			_promptContainer.addChild(title);
			
			_promptInput = new TextField();
			_promptInput.type = TextFieldType.INPUT;
			_promptInput.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF);
			_promptInput.border = true;
			_promptInput.borderColor = 0x555555;
			_promptInput.background = true;
			_promptInput.backgroundColor = 0x222222;
			_promptInput.x = 20;
			_promptInput.y = 40;
			_promptInput.width = 260;
			_promptInput.height = 25;
			_promptInput.text = _lastCombat;
			_promptContainer.addChild(_promptInput);
			
			var startBtn:Sprite = new Sprite();
			startBtn.graphics.beginFill(0x1E1E1E, 1);
			startBtn.graphics.lineStyle(1, 0x3A3A3A);
			startBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5);
			startBtn.graphics.endFill();
			startBtn.x = 20;
			startBtn.y = 80;
			startBtn.buttonMode = true;
			
			var startTxt:TextField = new TextField();
			startTxt.defaultTextFormat = new TextFormat("_sans", 12, 0xCCCCCC, true, null, null, null, null, TextFormatAlign.CENTER);
			startTxt.text = "Start";
			startTxt.width = 120;
			startTxt.y = 5;
			startTxt.selectable = false;
			startTxt.mouseEnabled = false;
			startBtn.addChild(startTxt);
			
			startBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { startBtn.graphics.clear(); startBtn.graphics.beginFill(0x333333, 1); startBtn.graphics.lineStyle(1, 0x555555); startBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); startBtn.graphics.endFill(); startTxt.textColor = 0xFFFFFF; });
			startBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { startBtn.graphics.clear(); startBtn.graphics.beginFill(0x1E1E1E, 1); startBtn.graphics.lineStyle(1, 0x3A3A3A); startBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); startBtn.graphics.endFill(); startTxt.textColor = 0xCCCCCC; });
			
			startBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				_lastCombat = _promptInput.text;
				var seq:Array = _lastCombat.split(",");
				var validSeq:Array = [];
				for (var i:int = 0; i < seq.length; i++) {
					var sid:String = String(seq[i]).replace(/^\s+|\s+$/g, "");
					if (sid.length > 0) validSeq.push(sid);
				}
				if (validSeq.length > 0) {
					AQWApi.combat.startCustom(validSeq.join(","));
					pocket.overlay.notification("Custom Combat started: " + validSeq.join(", "));
				}
				hidePrompt();
			});
			_promptContainer.addChild(startBtn);
			
			var cancelBtn:Sprite = new Sprite();
			cancelBtn.graphics.beginFill(0x1E1E1E, 1);
			cancelBtn.graphics.lineStyle(1, 0x3A3A3A);
			cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5);
			cancelBtn.graphics.endFill();
			cancelBtn.x = 160;
			cancelBtn.y = 80;
			cancelBtn.buttonMode = true;
			
			var cancelTxt:TextField = new TextField();
			cancelTxt.defaultTextFormat = new TextFormat("_sans", 12, 0xCCCCCC, true, null, null, null, null, TextFormatAlign.CENTER);
			cancelTxt.text = "Cancel";
			cancelTxt.width = 120;
			cancelTxt.y = 5;
			cancelTxt.selectable = false;
			cancelTxt.mouseEnabled = false;
			cancelBtn.addChild(cancelTxt);
			
			cancelBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { cancelBtn.graphics.clear(); cancelBtn.graphics.beginFill(0x333333, 1); cancelBtn.graphics.lineStyle(1, 0x555555); cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); cancelBtn.graphics.endFill(); cancelTxt.textColor = 0xFFFFFF; });
			cancelBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { cancelBtn.graphics.clear(); cancelBtn.graphics.beginFill(0x1E1E1E, 1); cancelBtn.graphics.lineStyle(1, 0x3A3A3A); cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); cancelBtn.graphics.endFill(); cancelTxt.textColor = 0xCCCCCC; });
			
			cancelBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				hidePrompt();
			});
			_promptContainer.addChild(cancelBtn);
			
			if (pocket.overlay != null) {
				pocket.overlay.addChild(_promptContainer);
			}
		}

		private static function showShopPrompt(pocket:*):void {
			hidePrompt();
			_promptContainer = new Sprite();
			_promptContainer.graphics.beginFill(0x121212, 0.95);
			_promptContainer.graphics.lineStyle(1, 0x2A2A2A);
			_promptContainer.graphics.drawRoundRect(0, 0, 300, 160, 8, 8);
			_promptContainer.graphics.endFill();
			_promptContainer.x = (960 - 300) / 2;
			_promptContainer.y = (500 - 160) / 2;
			
			var title:TextField = new TextField();
			title.defaultTextFormat = new TextFormat("_sans", 14, 0xE0E0E0, true, null, null, null, null, TextFormatAlign.CENTER);
			title.text = "Enter Shop ID:";
			title.width = 300;
			title.y = 10;
			title.selectable = false;
			_promptContainer.addChild(title);
			
			_promptInput = new TextField();
			_promptInput.type = TextFieldType.INPUT;
			_promptInput.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF);
			_promptInput.border = true;
			_promptInput.borderColor = 0x555555;
			_promptInput.background = true;
			_promptInput.backgroundColor = 0x222222;
			_promptInput.x = 20;
			_promptInput.y = 40;
			_promptInput.width = 260;
			_promptInput.height = 25;
			_promptInput.text = "";
			_promptContainer.addChild(_promptInput);
			
			var startBtn:Sprite = new Sprite();
			startBtn.graphics.beginFill(0x1E1E1E, 1);
			startBtn.graphics.lineStyle(1, 0x3A3A3A);
			startBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5);
			startBtn.graphics.endFill();
			startBtn.x = 20;
			startBtn.y = 80;
			startBtn.buttonMode = true;
			
			var startTxt:TextField = new TextField();
			startTxt.defaultTextFormat = new TextFormat("_sans", 12, 0xCCCCCC, true, null, null, null, null, TextFormatAlign.CENTER);
			startTxt.text = "Load";
			startTxt.width = 120;
			startTxt.y = 5;
			startTxt.selectable = false;
			startTxt.mouseEnabled = false;
			startBtn.addChild(startTxt);
			
			startBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { startBtn.graphics.clear(); startBtn.graphics.beginFill(0x333333, 1); startBtn.graphics.lineStyle(1, 0x555555); startBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); startBtn.graphics.endFill(); startTxt.textColor = 0xFFFFFF; });
			startBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { startBtn.graphics.clear(); startBtn.graphics.beginFill(0x1E1E1E, 1); startBtn.graphics.lineStyle(1, 0x3A3A3A); startBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); startBtn.graphics.endFill(); startTxt.textColor = 0xCCCCCC; });
			
			startBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				var sid:int = parseInt(String(_promptInput.text).replace(/^\s+|\s+$/g, ""));
				if (sid > 0) {
					AQWApi.shop.loadShop(sid);
					pocket.overlay.notification("Loading Shop: " + sid);
				}
				hidePrompt();
			});
			_promptContainer.addChild(startBtn);
			
			var cancelBtn:Sprite = new Sprite();
			cancelBtn.graphics.beginFill(0x1E1E1E, 1);
			cancelBtn.graphics.lineStyle(1, 0x3A3A3A);
			cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5);
			cancelBtn.graphics.endFill();
			cancelBtn.x = 160;
			cancelBtn.y = 80;
			cancelBtn.buttonMode = true;
			
			var cancelTxt:TextField = new TextField();
			cancelTxt.defaultTextFormat = new TextFormat("_sans", 12, 0xCCCCCC, true, null, null, null, null, TextFormatAlign.CENTER);
			cancelTxt.text = "Cancel";
			cancelTxt.width = 120;
			cancelTxt.y = 5;
			cancelTxt.selectable = false;
			cancelTxt.mouseEnabled = false;
			cancelBtn.addChild(cancelTxt);
			
			cancelBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { cancelBtn.graphics.clear(); cancelBtn.graphics.beginFill(0x333333, 1); cancelBtn.graphics.lineStyle(1, 0x555555); cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); cancelBtn.graphics.endFill(); cancelTxt.textColor = 0xFFFFFF; });
			cancelBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { cancelBtn.graphics.clear(); cancelBtn.graphics.beginFill(0x1E1E1E, 1); cancelBtn.graphics.lineStyle(1, 0x3A3A3A); cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); cancelBtn.graphics.endFill(); cancelTxt.textColor = 0xCCCCCC; });
			
			cancelBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				hidePrompt();
			});
			_promptContainer.addChild(cancelBtn);
			
			if (pocket.overlay != null) {
				pocket.overlay.addChild(_promptContainer);
			}
		}

		private static function showPastePrompt(pocket:*):void {
			hidePrompt();
			
			_promptContainer = new Sprite();
			_promptContainer.graphics.beginFill(0x121212, 0.95);
			_promptContainer.graphics.lineStyle(1, 0x2A2A2A);
			_promptContainer.graphics.drawRoundRect(0, 0, 600, 400, 8, 8);
			_promptContainer.graphics.endFill();
			
			_promptContainer.x = (960 - 600) / 2;
			_promptContainer.y = (500 - 400) / 2;
			
			var title:TextField = new TextField();
			title.defaultTextFormat = new TextFormat("_sans", 16, 0xE0E0E0, true, null, null, null, null, TextFormatAlign.CENTER);
			title.text = "Paste Bot Script Below";
			title.width = 600;
			title.y = 10;
			title.selectable = false;
			title.mouseEnabled = false;
			_promptContainer.addChild(title);
			
			_promptInput = new TextField();
			_promptInput.type = TextFieldType.INPUT;
			_promptInput.multiline = true;
			_promptInput.wordWrap = true;
			_promptInput.defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF);
			_promptInput.border = true;
			_promptInput.borderColor = 0x555555;
			_promptInput.background = true;
			_promptInput.backgroundColor = 0x222222;
			_promptInput.x = 20;
			_promptInput.y = 40;
			_promptInput.width = 560;
			_promptInput.height = 300;
			_promptContainer.addChild(_promptInput);
			
			var loadBtn:Sprite = new Sprite();
			loadBtn.graphics.beginFill(0x1E1E1E, 1);
			loadBtn.graphics.lineStyle(1, 0x3A3A3A);
			loadBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5);
			loadBtn.graphics.endFill();
			loadBtn.x = 160;
			loadBtn.y = 350;
			loadBtn.buttonMode = true;
			
			var loadTxt:TextField = new TextField();
			loadTxt.defaultTextFormat = new TextFormat("_sans", 12, 0xCCCCCC, true, null, null, null, null, TextFormatAlign.CENTER);
			loadTxt.text = "Load Script";
			loadTxt.width = 120;
			loadTxt.y = 5;
			loadTxt.selectable = false;
			loadTxt.mouseEnabled = false;
			loadBtn.addChild(loadTxt);
			
			loadBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { loadBtn.graphics.clear(); loadBtn.graphics.beginFill(0x333333, 1); loadBtn.graphics.lineStyle(1, 0x555555); loadBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); loadBtn.graphics.endFill(); loadTxt.textColor = 0xFFFFFF; });
			loadBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { loadBtn.graphics.clear(); loadBtn.graphics.beginFill(0x1E1E1E, 1); loadBtn.graphics.lineStyle(1, 0x3A3A3A); loadBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); loadBtn.graphics.endFill(); loadTxt.textColor = 0xCCCCCC; });
			
			loadBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				var text:String = _promptInput.text;
				hidePrompt();
				ScriptManager.SINGLETON.loadScript(text, pocket);
				pocket.overlay.notification("Script loaded successfully!");
			});
			_promptContainer.addChild(loadBtn);
			
			var cancelBtn:Sprite = new Sprite();
			cancelBtn.graphics.beginFill(0x1E1E1E, 1);
			cancelBtn.graphics.lineStyle(1, 0x3A3A3A);
			cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5);
			cancelBtn.graphics.endFill();
			cancelBtn.x = 320;
			cancelBtn.y = 350;
			cancelBtn.buttonMode = true;
			
			var cancelTxt:TextField = new TextField();
			cancelTxt.defaultTextFormat = new TextFormat("_sans", 12, 0xCCCCCC, true, null, null, null, null, TextFormatAlign.CENTER);
			cancelTxt.text = "Cancel";
			cancelTxt.width = 120;
			cancelTxt.y = 5;
			cancelTxt.selectable = false;
			cancelTxt.mouseEnabled = false;
			cancelBtn.addChild(cancelTxt);
			
			cancelBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { cancelBtn.graphics.clear(); cancelBtn.graphics.beginFill(0x333333, 1); cancelBtn.graphics.lineStyle(1, 0x555555); cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); cancelBtn.graphics.endFill(); cancelTxt.textColor = 0xFFFFFF; });
			cancelBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { cancelBtn.graphics.clear(); cancelBtn.graphics.beginFill(0x1E1E1E, 1); cancelBtn.graphics.lineStyle(1, 0x3A3A3A); cancelBtn.graphics.drawRoundRect(0, 0, 120, 30, 5, 5); cancelBtn.graphics.endFill(); cancelTxt.textColor = 0xCCCCCC; });
			
			cancelBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				hidePrompt();
			});
			_promptContainer.addChild(cancelBtn);
			
			if (pocket.overlay != null) {
				pocket.overlay.addChild(_promptContainer);
			}
		}

		private static function hidePrompt():void {
			if (_promptContainer != null && _promptContainer.parent != null) {
				_promptContainer.parent.removeChild(_promptContainer);
			}
			_promptContainer = null;
			_promptInput = null;
		}

		public static function stickyNotification(overlay:Overlay, id:String, message:String):void {
			if (overlay == null || overlay.notifications == null) return;
			removeStickyNotification(overlay, id);
			
			var notif:ui.Notification = new ui.Notification(message, true);
			notif.name = id;
			notif.id = id;
			overlay.notifications.addChild(notif);
			
			rearrangeNotifications(overlay);
		}

		public static function removeStickyNotification(overlay:Overlay, id:String):void {
			if (overlay == null || overlay.notifications == null) return;
			var existing:* = overlay.notifications.getChildByName(id);
			if (existing != null) {
				if (existing is ui.Notification) {
					ui.Notification(existing).onClose();
				} else {
					overlay.notifications.removeChild(existing);
				}
				rearrangeNotifications(overlay);
			}
		}

		private static function rearrangeNotifications(overlay:Overlay):void {
			if (overlay == null || overlay.notifications == null) return;
			var currentY:Number = 0;
			for (var i:int = 0; i < overlay.notifications.numChildren; i++) {
				var child:* = overlay.notifications.getChildAt(i);
				child.x = 0;
				child.y = currentY;
				currentY += child.height + 10;
			}
			if (overlay.notifications.numChildren > 0 && overlay.stage != null) {
				overlay.notifications.x = overlay.stage.stageWidth - overlay.notifications.getChildAt(0).width - 10;
				overlay.notifications.y = 10;
			}
		}
	}
}
