package ui {

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class Notification extends Sprite {

		public function Notification(message:String, sticky:Boolean = false) {
			this.isSticky = sticky;
			this.messageTxt.htmlText = message;

			this.closeBtn.addEventListener(MouseEvent.CLICK, onClose, false, 0, true);
			
			if (!sticky) {
				// Auto close after 5 seconds
			_timer = new Timer(5000, 1);
			_timer.addEventListener(TimerEvent.TIMER, onClose, false, 0, true);
			_timer.start();
			}

		}

		public var messageTxt:TextField;
		public var closeBtn:SimpleButton;
		public var isSticky:Boolean = false;
		public var id:String = "";
		private var _timer:Timer;

		public function onClose(e:Event = null):void {
			if (_timer != null) {
				_timer.stop();
				_timer = null;
			}

			if (this.parent) {
				this.parent.removeChild(this);
			}
		}

	}
}
