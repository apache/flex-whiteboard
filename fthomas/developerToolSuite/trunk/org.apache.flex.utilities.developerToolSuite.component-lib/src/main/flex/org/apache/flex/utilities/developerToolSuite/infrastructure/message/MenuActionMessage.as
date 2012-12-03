package org.apache.flex.utilities.developerToolSuite.infrastructure.message {
    public class MenuActionMessage {

        private var _item:Object;

        public function MenuActionMessage(item:Object) {
            this._item = item;
        }

        public function get item():Object {
            return _item;
        }
    }
}
