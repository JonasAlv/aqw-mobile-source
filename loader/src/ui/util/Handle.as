package ui.util {

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Handle extends Sprite {
		public var drag: SimpleButton;
		public var up: SimpleButton;
		public var down: SimpleButton;
		
		public function Handle() {
			if (this.drag == null) {
				// Drag button (Center crosshair)
				this.drag = createSimpleBtn(0x3498db, "O", -20, -20, 40, 40); 
				// Up button (Plus sign, right top)
				this.up = createSimpleBtn(0x2ecc71, "+", 25, -30, 25, 25);
				// Down button (Minus sign, right bottom)
				this.down = createSimpleBtn(0xe74c3c, "-", 25, 5, 25, 25);
				
				this.addChild(this.drag);
				this.addChild(this.up);
				this.addChild(this.down);
			}
		}
		
		private function createSimpleBtn(color:uint, label:String, ox:Number, oy:Number, w:Number, h:Number):SimpleButton {
			var upState:Sprite = drawState(color, label, w, h);
			var overState:Sprite = drawState(color, label, w, h, 0.8);
			var downState:Sprite = drawState(color, label, w, h, 0.5);
			var btn:SimpleButton = new SimpleButton(upState, overState, downState, upState);
			btn.x = ox;
			btn.y = oy;
			return btn;
		}
		
		private function drawState(color:uint, label:String, w:Number, h:Number, alpha:Number = 1.0):Sprite {
			var s:Sprite = new Sprite();
			s.graphics.beginFill(color, alpha);
			s.graphics.lineStyle(2, 0xFFFFFF, alpha);
			s.graphics.drawRoundRect(0, 0, w, h, w/2, h/2);
			s.graphics.endFill();
			
			var tf:TextField = new TextField();
			var fmt:TextFormat = new TextFormat("_sans", h/1.5, 0xFFFFFF, true);
			fmt.align = "center";
			tf.defaultTextFormat = fmt;
			tf.text = label;
			tf.width = w;
			tf.height = h;
			tf.y = (h - tf.textHeight) / 2 - 2;
			tf.selectable = false;
			tf.mouseEnabled = false;
			s.addChild(tf);
			
			return s;
		}
	}
}
