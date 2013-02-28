package org.apache.flex.utilities.developerToolSuite.presentation.behavior.setting {
    import com.adobe.cairngorm.popup.IPopUpBehavior;
    import com.adobe.cairngorm.popup.PopUpBase;
    import com.adobe.cairngorm.popup.PopUpEvent;

    import mx.core.UIComponent;
    import mx.effects.Effect;
    import mx.events.EffectEvent;
    import mx.events.FlexEvent;

    /**
     * Plays effects when a popup opens and closes. The effects need to be
     * specified with the <code>openEffect</code> and <code>closeEffect</code>
     * properties.
     */
    public class PlayEffectsBehavior implements IPopUpBehavior {
        //------------------------------------------------------------------------
        //
        //  Private Variables
        //
        //------------------------------------------------------------------------

        private var closingEvent:PopUpEvent;

        //------------------------------------------------------------------------
        //
        //  Public Properties
        //
        //------------------------------------------------------------------------

        /** The effect to play as the popup opens. */
        public var openEffect:Effect;

        /** The effect to play as the popup closes. */
        public var closeEffect:Effect;

        private var popup:PopUpBase;

        //------------------------------------------------------------------------
        //
        //  Implementation : IPopUpBehavior
        //
        //------------------------------------------------------------------------

        public function apply(base:PopUpBase):void {
            this.popup = base;

            base.addEventListener(PopUpEvent.OPENING, onOpening);
            base.addEventListener(PopUpEvent.CLOSING, onClosing);
        }

        //------------------------------------------------------------------------
        //
        //  Event Listeners
        //
        //------------------------------------------------------------------------

        private function onOpening(event:PopUpEvent):void {
            UIComponent(event.popup).callLater(handleStart, [ event ]);
        }

        private function handleStart(event:PopUpEvent):void {
            popup.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
            if (openEffect) {
                openEffect.play([ event.popup ]);
            }
        }

        private function onClosing(event:PopUpEvent):void {
            if (closeEffect) {
                closingEvent = event;
                closingEvent.suspendClosure();

                closeEffect.startDelay = 100;
                closeEffect.play([ event.popup ]);
                closeEffect.addEventListener(EffectEvent.EFFECT_END, onCloseEffectEnd);
            }
        }

        private function onCloseEffectEnd(event:EffectEvent):void {
            popup.dispatchEvent(new FlexEvent(FlexEvent.HIDE));

            closeEffect.removeEventListener(EffectEvent.EFFECT_END, onCloseEffectEnd);

            closingEvent.resumeClosure();
            closingEvent = null;
        }
    }
}
