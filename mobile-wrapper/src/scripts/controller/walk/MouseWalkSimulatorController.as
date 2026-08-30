package controller.walk
{
   import flash.display.*;
   import flash.geom.*;
   import flash.utils.*;
   
   public class MouseWalkSimulatorController extends WalkController
   {
      
      public static var IS_DASHING_ON:Boolean = false;
      
      private static const SEND_EVERY_N_FRAMES:int = 5;
      
      private static const MOVE_SPEED_MULTIPLIER:Number = 8;
      
      private static const WALK_MAX_THRESHOLD:Number = 0.65;
      
      private static const DASH_THRESHOLD:Number = 0.85;
      
      private static const DASH_COOLDOWN_MS:int = 1000;
      
      private static const normalColor:ColorTransform = new ColorTransform();
      
      private static const dashColor:ColorTransform = new ColorTransform(0,0,0,1,0,145,0,0);
      
      private var isDashingVisual:Boolean = false;
      
      private var lastDashTime:int = 0;
      
      public function MouseWalkSimulatorController(pocket:Pocket)
      {
         super(pocket);
      }
      
      override public function update() : void
      {
         var joystick:* = undefined;
         var dirX:Number = NaN;
         var dirY:Number = NaN;
         var localX:Number = NaN;
         var localY:Number = NaN;
         var currentTime:int = 0;
         var myAvatar:* = undefined;
         var playerName:String = null;
         var dashCost:Number = NaN;
         if(!this.pocket.game.world || !this.pocket.game.world.myAvatar)
         {
            return;
         }
         var pMC:MovieClip = MovieClip(this.pocket.game.world.myAvatar.pMC);
         joystick = this.pocket.gameUI.joystickMouseSimulator;
         dirX = Number(joystick.dirX);
         dirY = Number(joystick.dirY);
         var directionMagnitude:Number = Math.sqrt(dirX * dirX + dirY * dirY);
         if(pMC == null || directionMagnitude == 0)
         {
            return;
         }
         if(!this.pocket.game.world.isMoveOK(this.pocket.game.world.myAvatar.dataLeaf) || !Boolean(this.pocket.game.world.bitWalk))
         {
            return;
         }
         var angle:Number = Math.atan2(dirY,dirX);
         var baseSpeed:Number = Number(this.pocket.game.world.WALKSPEED);
         var moveSpeed:Number = baseSpeed;
         if(IS_DASHING_ON && directionMagnitude >= DASH_THRESHOLD && !this.isDashingVisual)
         {
            if(joystick.knob)
            {
               joystick.knob.transform.colorTransform = dashColor;
            }
            this.isDashingVisual = true;
         }
         else if((!IS_DASHING_ON || directionMagnitude < DASH_THRESHOLD) && Boolean(this.isDashingVisual))
         {
            if(joystick.knob)
            {
               joystick.knob.transform.colorTransform = normalColor;
            }
            this.isDashingVisual = false;
         }
         if(directionMagnitude < WALK_MAX_THRESHOLD)
         {
            moveSpeed = Math.max(baseSpeed * 0.3,baseSpeed * (directionMagnitude / WALK_MAX_THRESHOLD));
         }
         else if(directionMagnitude >= WALK_MAX_THRESHOLD && directionMagnitude < DASH_THRESHOLD)
         {
            moveSpeed = baseSpeed;
         }
         else if(IS_DASHING_ON && !this.pocket.game.world.justRan2)
         {
            currentTime = int(getTimer());
            if(currentTime - this.lastDashTime >= DASH_COOLDOWN_MS)
            {
               myAvatar = this.pocket.game.world.myAvatar;
               playerName = myAvatar.pnm;
               dashCost = Number(Number(this.pocket.game.world.uoTree[playerName].sta.$dsh) || 100);
               if(myAvatar.dataLeaf.intSP >= dashCost)
               {
                  this.pocket.game.pDash = true;
                  this.lastDashTime = currentTime;
               }
            }
         }
         if(Boolean(this.pocket.game.pDash) && !this.pocket.game.world.justRan2)
         {
            this.pocket.game.world.justRan2 = true;
            this.pocket.game.pDash = false;
         }
         if(this.pocket.game.world.justRan2)
         {
            moveSpeed = baseSpeed * 3;
         }
         this.pocket.game.world.speed2 = moveSpeed;
         localX = pMC.x + Math.cos(angle) * MOVE_SPEED_MULTIPLIER * 10;
         localY = pMC.y + Math.sin(angle) * MOVE_SPEED_MULTIPLIER * 10;
         var stagePt:Point = Sprite(this.pocket.game.world.CHARS).localToGlobal(new Point(localX,localY));
         if(stagePt.x < 0 || stagePt.x > 960 || stagePt.y < 0 || stagePt.y > 550)
         {
            return;
         }
         var mvPT:Point = pMC.simulateTo(localX,localY,moveSpeed);
         if(mvPT == null)
         {
            return;
         }
         pMC.walkTo(mvPT.x,mvPT.y,moveSpeed);
         ++this.frameTick;
         if(this.frameTick >= SEND_EVERY_N_FRAMES)
         {
            this.frameTick = 0;
            this.pocket.game.world.moveRequest({
               "mc":pMC,
               "tx":mvPT.x,
               "ty":mvPT.y,
               "sp":moveSpeed
            });
         }
      }
      
      override public function stop() : void
      {
         var joystick:* = undefined;
         this.frameTick = 0;
         if(Boolean(this.pocket.game.world) && Boolean(this.pocket.game.world.myAvatar) && Boolean(this.pocket.game.world.myAvatar.pMC))
         {
            this.pocket.game.world.myAvatar.pMC.stopWalking();
         }
         if(this.isDashingVisual)
         {
            joystick = this.pocket.gameUI.joystickMouseSimulator;
            if(Boolean(joystick) && Boolean(joystick.knob))
            {
               joystick.knob.transform.colorTransform = normalColor;
            }
            this.isDashingVisual = false;
         }
      }
   }
}

