package org.apache.flex.utilities.developerToolSuite.infrastructure.event {
    import flash.events.Event;

    public class ModalWindowEvent extends Event {

        public static const OPENED:String = "opened";
        public static const CLOSED:String = "closed";

        public function ModalWindowEvent(type:String) {
            super(type);
        }
    }
}
