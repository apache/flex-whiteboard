package org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command {
    public class CommandCallBackResult implements ICommandCallBack {

        private var _result:*;

        public function CommandCallBackResult(result:*) {
            _result = result;
        }

        public function get result():* {
            return _result;
        }
    }
}
