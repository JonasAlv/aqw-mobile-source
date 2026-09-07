package ui {

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;

	public class Notification extends Sprite {

		public function Notification(message:String) {
			this.messageTxt.htmlText = message;

			this.closeBtn.addEventListener(MouseEvent.CLICK, onClose, false, 0, true);
			
			// Auto close after 5 seconds
			_timer = new Timer(5000, 1);
			_timer.addEventListener(TimerEvent.TIMER, onClose, false, 0, true);
			_timer.start();
		}

		public var messageTxt:TextField;
		public var closeBtn:SimpleButton;
		private var _timer:Timer;

		private function onClose(e:Event = null):void {
			if (_timer != null) {
				_timer.stop();
				_timer = null;
			}
			if (this.parent) {
				var p:* = this.parent;
				p.removeChild(this);
				if (p.parent && p.parent.hasOwnProperty("rearrangeNotifications")) {
					p.parent.rearrangeNotifications();
				}
			}
		}

	}
}
