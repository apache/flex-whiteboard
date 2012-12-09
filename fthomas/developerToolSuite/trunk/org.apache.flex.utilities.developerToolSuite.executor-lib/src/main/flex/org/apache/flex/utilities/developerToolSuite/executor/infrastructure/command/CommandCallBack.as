package org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command {
    public class CommandCallBack {
        public static const DEFAULT_RESULT:ICommandCallBack = new CommandCallBackResult("Default Result Command");
        public static const DEFAULT_ERROR:ICommandCallBack = new CommandCallBackError("Default Error Command");
    }
}
