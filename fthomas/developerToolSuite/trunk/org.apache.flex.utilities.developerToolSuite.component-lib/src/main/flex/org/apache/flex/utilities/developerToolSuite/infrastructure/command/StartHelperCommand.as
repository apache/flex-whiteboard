package org.apache.flex.utilities.developerToolSuite.infrastructure.command {
    import mx.logging.ILogger;

    import org.apache.flex.utilities.developerToolSuite.executor.domain.ISettingsModel;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command.CommandCallBackError;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateAntPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateCygwinPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateJavaPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateMavenPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.util.LogUtil;
    import org.apache.flex.utilities.developerToolSuite.infrastructure.message.StartHelperMessage;
    import org.apache.flex.utilities.developerToolSuite.presentation.graphic.settings.SettingsWindow;
    import org.spicefactory.parsley.core.context.Context;

    public class StartHelperCommand {

        private static var LOG:ILogger = LogUtil.getLogger(StartHelperCommand);

        [Inject]
        public var context:Context;

        [Inject]
        public var settings:ISettingsModel;

        [MessageDispatcher]
        public var dispatch:Function;

        public var callback:Function;

        public function execute(msg:StartHelperMessage):void {

            dispatch(new ValidateJavaPathMessage(settings.JAVA_HOME));
            dispatch(new ValidateAntPathMessage(settings.ANT_HOME));
            dispatch(new ValidateMavenPathMessage(settings.MAVEN_HOME));
            dispatch(new ValidateCygwinPathMessage(settings.CYGWIN_HOME));
        }

        [CommandError]
        public function validateJavaPathCommandError(error:CommandCallBackError, trigger:ValidateJavaPathMessage):void {
            SettingsWindow.show(context);
        }

        [CommandError]
        public function validateAntPathCommandError(error:CommandCallBackError, trigger:ValidateAntPathMessage):void {
            SettingsWindow.show(context);
        }

        [CommandError]
        public function validateMavenPathCommandError(error:CommandCallBackError, trigger:ValidateMavenPathMessage):void {
            SettingsWindow.show(context);
        }

        [CommandError]
        public function validateCygwinPathCommandError(error:CommandCallBackError, trigger:ValidateCygwinPathMessage):void {
            SettingsWindow.show(context);
        }
    }
}
