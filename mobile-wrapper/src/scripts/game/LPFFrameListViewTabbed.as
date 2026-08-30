package game
{
   import flash.display.*;
   import flash.events.*;
   import ui.util.*;
   
   public class LPFFrameListViewTabbed
   {
      
      private var pocket:Pocket;
      
      public function LPFFrameListViewTabbed(pocket:Pocket)
      {
         super();
         this.pocket = pocket;
      }
      
      public function fDraw(state:Object, lpf:Object, reset:Boolean) : Object
      {
         var needPagination:Boolean;
         var listA:Array = null;
         var i:int = 0;
         var itemData:Object = null;
         var iSel:Object = null;
         var iList:MovieClip = null;
         var listMask:MovieClip = null;
         var scr:Object = null;
         var lpfElementListItemItemCls:Class = null;
         var itemConfig:Object = null;
         var listLength:int = 0;
         var matchesFilter:Boolean = false;
         var isExcludedPot:Boolean = false;
         var pagination:DisplayObject = null;
         listA = [];
         var sortedGroup:Array = [];
         var filteredItems:Array = [];
         var tSel:Object = state.tSel;
         iSel = state.iSel;
         var filterMap:Object = state.filterMap;
         var itemList:Array = state.itemList;
         var sortOrder:Array = state.sortOrder;
         var onDemand:Boolean = Boolean(state.onDemand);
         var bLimited:Boolean = Boolean(state.bLimited);
         var itemEventType:String = state.itemEventType;
         var allowDesel:Boolean = Boolean(state.allowDesel);
         var multiSelect:Boolean = Boolean(state.multiSelect);
         iList = lpf.iList;
         var bgTabs:MovieClip = lpf.bgTabs;
         listMask = lpf.listMask;
         scr = lpf.scr;
         lpfElementListItemItemCls = this.pocket.game.world.getClass("LPFElementListItemItem");
         while(iList.numChildren > 0)
         {
            MovieClip(iList.getChildAt(0)).fClose();
         }
         if(reset)
         {
            iList.y = bgTabs.height - 1;
         }
         if(tSel == null)
         {
            state.setMessage("No Tab Selected");
            scr.fOpen({
               "subject":iList,
               "subjectMask":listMask,
               "reset":reset
            });
            return {"listA":listA};
         }
         state.setMessage("");
         if(tSel.filter != "*")
         {
            for each(itemData in itemList)
            {
               matchesFilter = filterMap[tSel.filter].indexOf(itemData.sType) > -1 || itemData.sType == "Enhancement" && itemData.sES.indexOf(tSel.filter) > -1;
               isExcludedPot = tSel.filter == "pots" && itemData.sLink != "potion" && itemData.sLink != "elixir" && itemData.sLink != "tonic" && itemData.sLink != "scroll";
               if(matchesFilter && !isExcludedPot)
               {
                  filteredItems.push(itemData);
               }
            }
         }
         else
         {
            filteredItems = itemList;
         }
         if(onDemand && filteredItems.length == 0)
         {
            state.setMessage("No items of this type");
            scr.fOpen({
               "subject":iList,
               "subjectMask":listMask,
               "reset":reset
            });
            return {"listA":listA};
         }
         for(i = 0; i < sortOrder.length; i++)
         {
            sortedGroup = [];
            for each(itemData in filteredItems)
            {
               if(itemData.sType == sortOrder[i])
               {
                  sortedGroup.push(itemData);
               }
            }
            if(sortedGroup.length > 0)
            {
               sortedGroup.sortOn(["sName","iLvl"],[undefined,Array.DESCENDING | Array.NUMERIC]);
               listA = listA.concat(sortedGroup);
            }
         }
         sortedGroup = [];
         for each(itemData in filteredItems)
         {
            if(listA.indexOf(itemData) == -1)
            {
               sortedGroup.push(itemData);
            }
         }
         if(sortedGroup.length > 0)
         {
            sortedGroup.sortOn(["sType","sName"]);
            listA = listA.concat(sortedGroup);
         }
         itemConfig = {};
         itemConfig.eventType = itemEventType;
         itemConfig.allowDesel = allowDesel;
         itemConfig.multiSelect = multiSelect;
         itemConfig.bLimited = bLimited && state.getLayout().sMode == "shopBuy";
         needPagination = false;
         listLength = int(listA.length);
         for(i = 0; i < listLength; i++)
         {
            if(i > 100)
            {
               needPagination = true;
               break;
            }
            this.addListItem(iList,lpf,lpfElementListItemItemCls,itemConfig,listA,iSel,i);
         }
         if(needPagination)
         {
            pagination = DisplayObject(iList.addChild(new Pagination()));
            pagination.y = iList.height - 5;
            pagination.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void
            {
               var dRun:int = 0;
               var buttonY:int = pagination.y;
               iList.removeChild(pagination);
               var ii:int = 0;
               for(var j:int = i; j < listLength; j++)
               {
                  if(ii > 100)
                  {
                     break;
                  }
                  addListItem(iList,lpf,lpfElementListItemItemCls,itemConfig,listA,iSel,j);
                  ii++;
               }
               i += ii;
               if(i < listLength)
               {
                  iList.addChild(pagination);
                  pagination.y = iList.height - 5;
               }
               var hRun:int = scr.b.height - scr.h.height;
               dRun = iList.height - listMask.height + 20;
               var targetY:Number = Math.max(iList.oy - dRun,iList.oy - buttonY);
               iList.y = targetY;
               scr.h.y = hRun > 0 ? -(targetY - iList.oy) * hRun / dRun : 0;
               scr.fOpen({
                  "subject":iList,
                  "subjectMask":listMask,
                  "reset":false
               });
            },false,0,true);
         }
         scr.fOpen({
            "subject":iList,
            "subjectMask":listMask,
            "reset":reset
         });
         return {"listA":listA};
      }
      
      private function addListItem(iList:Object, lpf:Object, cls:Class, itemConfig:Object, listA:Array, iSel:Object, key:int) : void
      {
         itemConfig.fData = listA[key];
         var listItem:Object = iList.addChild(new cls());
         listItem.subscribeTo(lpf);
         listItem.fOpen(itemConfig);
         if(listItem.fData == iSel)
         {
            listItem.select();
         }
         if(key != 0)
         {
            listItem.y = iList.height;
         }
      }
   }
}

