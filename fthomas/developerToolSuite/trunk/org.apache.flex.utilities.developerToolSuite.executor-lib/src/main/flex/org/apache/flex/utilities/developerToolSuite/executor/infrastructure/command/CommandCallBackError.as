package org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command {
    public class CommandCallBackError extends Error implements ICommandCallBack {

        public function CommandCallBackError(message:*, id:* = 0) {
            super(message);
        }
    }
}
