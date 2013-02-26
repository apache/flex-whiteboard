package org.apache.flex.utilities.developerToolSuite.infrastructure.command {
    import flash.data.SQLResult;
    import flash.errors.SQLError;
    import flash.events.SQLEvent;

    import mx.utils.ObjectUtil;

    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command.AbstractDBCommand;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command.CommandCallBackError;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command.CommandCallBackResult;
    import org.apache.flex.utilities.developerToolSuite.infrastructure.message.ApplicationExitReadyMessage;
    import org.apache.flex.utilities.developerToolSuite.infrastructure.message.ExitApplicationMessage;

    public class ExitUICommand extends AbstractDBCommand {

        private var _msg:ExitApplicationMessage;
        private var _terminateCommand:Function;

        public function execute(msg:ExitApplicationMessage):void {
            log.debug("Executing Command with message: " + ObjectUtil.toString(msg));
            this._msg = msg;
            executeAsync();
        }

        override protected function prepareSql():void {
            sql = "";
            for (var property:String in _msg.settings) {
                sql += "UPDATE setting SET value='" + _msg.settings[property] + "' WHERE name='" + property + "';";
            }

            super.prepareSql();
        }

        override protected function result(result:SQLResult, terminateCommand:Boolean = true):void {
            super.result(result, false);

            db.addEventListener(SQLEvent.CLOSE, onDBClosed);

            if (terminateCommand) {
                _terminateCommand = function ():void {
                    callback(new CommandCallBackResult(result));
                }
            }
        }

        override protected function error(error:SQLError, terminateCommand:Boolean = true):void {
            super.error(error, false);

            dispatch(new ApplicationExitReadyMessage());

            if (terminateCommand) {
                callback(new CommandCallBackError(error.message, error.detailID));
            }
        }

        private function onDBClosed(event:SQLEvent):void {
            dispatch(new ApplicationExitReadyMessage());

            if (_terminateCommand) {
                _terminateCommand();
            }
        }
    }
}
