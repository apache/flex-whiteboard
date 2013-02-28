package org.apache.flex.utilities.developerToolSuite.presentation.behavior.setting {
    import com.adobe.cairngorm.popup.PopUpBase;
    import com.adobe.cairngorm.popup.PopUpEvent;

    import flash.display.DisplayObject;

    import flash.events.Event;

    import mx.core.FlexGlobals;

    import mx.core.IFlexDisplayObject;

    public class KeepCenteredBehavior extends PlayEffectsBehavior {
        private var popup:IFlexDisplayObject;

        private var base:PopUpBase;

        override public function apply(base:PopUpBase):void {
            super.apply(base);
            this.base = base;
            base.addEventListener(PopUpEvent.OPENED, onOpened);
        }

        private function onOpened(event:PopUpEvent):void {
            popup = event.popup;
            popup.addEventListener(Event.RESIZE, onResize);
            popup.stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
            base.addEventListener(PopUpEvent.CLOSING, onClosing);
        }

        private function onResize(event:Event):void {
            popup.x = (popup.stage.width - popup.width) / 2;
            popup.y = (popup.stage.height - popup.height) / 2;
        }

        private function onClosing(event:Event):void {
            base.removeEventListener(PopUpEvent.CLOSING, onClosing);
            popup.removeEventListener(Event.RESIZE, onResize);
            if (popup.stage) {
                popup.stage.removeEventListener(Event.RESIZE, onResize);
            }
        }
    }
}
