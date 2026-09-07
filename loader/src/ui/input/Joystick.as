package ui.input {

	import controller.LayoutController;
	import controller.walk.WalkController;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	//noinspection JSUnresolvedReference
	POCKET::IS_MOBILE {
		import flash.events.TouchEvent;
	}

	//noinspection JSUnresolvedReference
	POCKET::IS_DESKTOP {
		import flash.events.MouseEvent;
	}

	public class Joystick extends Sprite {

		public function Joystick(walkController:WalkController) {
			addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);

			this.walkController = walkController;
		}

		public var knob:Sprite;
		public var dirX:Number = 0;
		public var dirY:Number = 0;

		private var _limit:Number;

		private var walkController:WalkController;

		//noinspection JSUnresolvedReference
		POCKET::IS_MOBILE {
			private var activeTouchID:int = -1;
		}

		public function move(stageX:Number, stageY:Number):void {
			const local:Point = globalToLocal(new Point(stageX, stageY));

			var dx:Number = local.x;
			var dy:Number = local.y;

			const dist:Number = Math.sqrt(dx * dx + dy * dy);

			if (dist > this._limit) {
				dx = dx / dist * this._limit;
				dy = dy / dist * this._limit;
			}

			this.knob.x = dx;
			this.knob.y = dy;

			this.dirX = dx / this._limit;
			this.dirY = dy / this._limit;
		}

		public function snapHome():void {
			this.knob.x = 0;
			this.knob.y = 0;

			this.dirX = 0;
			this.dirY = 0;
		}

		private function onAdded(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);

			//noinspection JSUnresolvedReference
			POCKET::IS_MOBILE {
				addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin, false, 0, true);
			}

			//noinspection JSUnresolvedReference
			POCKET::IS_DESKTOP {
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			}

			this._limit = (this.width >> 1) - (this.knob.width >> 1) * 0.4;
		}

		//noinspection JSUnresolvedReference
		POCKET::IS_MOBILE {
			private function onTouchBegin(e:TouchEvent):void {
				if (!this.visible || LayoutController.editMode || this.activeTouchID != -1) {
					return;
				}

				this.activeTouchID = e.touchPointID;

				stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
				stage.removeEventListener(Event.ENTER_FRAME, onEnterFrameJoystick);

				stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove, false, 0, true);
				stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd, false, 0, true);
				stage.addEventListener(Event.ENTER_FRAME, onEnterFrameJoystick, false, 0, true);

				this.move(e.stageX, e.stageY);
			}

			private function onTouchMove(e:TouchEvent):void {
				if (e.touchPointID != this.activeTouchID) {
					return;
				}

				if (this.dirX != 0 || this.dirY != 0) {
					this.move(e.stageX, e.stageY);
				}
			}

			private function onTouchEnd(e:TouchEvent):void {
				if (e.touchPointID != this.activeTouchID) {
					return;
				}

				stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
				stage.removeEventListener(Event.ENTER_FRAME, onEnterFrameJoystick);

				this.activeTouchID = -1;

				if (this.dirX == 0 && this.dirY == 0) {
					return;
				}

				this.snapHome();

				this.walkController.stop();
			}

		}

		//noinspection JSUnresolvedReference
		POCKET::IS_DESKTOP {
			private function onMouseDown(e:MouseEvent):void {
				if (!this.visible || LayoutController.editMode) {
					return;
				}

				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.removeEventListener(Event.ENTER_FRAME, onEnterFrameJoystick);

				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
				stage.addEventListener(Event.ENTER_FRAME, onEnterFrameJoystick, false, 0, true);

				this.move(e.stageX, e.stageY);
			}

			private function onMouseMove(e:MouseEvent):void {
				if (this.dirX != 0 || this.dirY != 0) {
					this.move(e.stageX, e.stageY);
				}
			}

			private function onMouseUp(e:MouseEvent):void {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.removeEventListener(Event.ENTER_FRAME, onEnterFrameJoystick);

				if (this.dirX == 0 && this.dirY == 0) {
					return;
				}

				this.snapHome();

				this.walkController.stop();
			}
		}

		private function onEnterFrameJoystick(e:Event):void {
			this.walkController.update();
		}

	}
}
