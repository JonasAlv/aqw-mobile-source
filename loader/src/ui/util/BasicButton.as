package ui.util {

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;

	public class BasicButton extends Sprite {
		public function BasicButton(buttonLabel:String) {
			if (this.buttonTxt == null) {
				this.buttonTxt = new TextField();
				var tf:TextFormat = new TextFormat("_sans", 14, 0xFFFFFF, true);
				tf.align = TextFormatAlign.CENTER;
				this.buttonTxt.defaultTextFormat = tf;
				this.buttonTxt.text = buttonLabel;
				this.buttonTxt.autoSize = TextFieldAutoSize.LEFT;
				this.buttonTxt.selectable = false;
				this.buttonTxt.mouseEnabled = false;
				
				this.graphics.beginFill(0x333333, 0.9);
				this.graphics.lineStyle(2, 0x666666);
				var w:Number = this.buttonTxt.width + 20;
				var h:Number = this.buttonTxt.height + 10;
				this.graphics.drawRoundRect(0, 0, w, h, 10, 10);
				this.graphics.endFill();
				
				this.buttonTxt.x = 10;
				this.buttonTxt.y = 5;
				this.addChild(this.buttonTxt);
				
				this.buttonMode = true;
				this.mouseChildren = false;
			} else {
				this.buttonTxt.text = buttonLabel;
				this.buttonTxt.mouseEnabled = false;
			}
		}

		public var button:Sprite;
		public var buttonTxt:TextField;

	}
}
