package org.apache.flex.utilities.developerToolSuite.infrastructure.command {
    import mx.logging.ILogger;

    import org.apache.flex.utilities.developerToolSuite.executor.domain.ISettingsModel;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command.CommandCallBack;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateAntPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateCygwinPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateJavaPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateMavenPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.application.util.LogUtil;
    import org.apache.flex.utilities.developerToolSuite.infrastructure.message.LaunchUIMessage;
    import org.apache.flex.utilities.developerToolSuite.presentation.graphic.settings.SettingsWindow;
    import org.spicefactory.parsley.core.context.Context;

    public class LaunchUICommand {

        private static var LOG:ILogger = LogUtil.getLogger(LaunchUICommand);

        [Inject]
        public var context:Context;

        [Inject]
        public var settings:ISettingsModel;

        [MessageDispatcher]
        public var dispatch:Function;

        public var callback:Function;

        private var _javaCompleted:Boolean;
        private var _antCompleted:Boolean;
        private var _mavenCompleted:Boolean;
        private var _cygwinCompleted:Boolean;

        public function execute(msg:LaunchUIMessage):void {

            dispatch(new ValidateJavaPathMessage(settings.JAVA_HOME));
            dispatch(new ValidateAntPathMessage(settings.ANT_HOME));
            dispatch(new ValidateMavenPathMessage(settings.MAVEN_HOME));
            dispatch(new ValidateCygwinPathMessage(settings.CYGWIN_HOME));
        }

        [CommandComplete]
        public function validateJavaPathCommandError(trigger:ValidateJavaPathMessage):void {
            _javaCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateJavaPathCommand(trigger:ValidateJavaPathMessage):void {
            _javaCompleted = true;
            checkValidationsCompleted();
        }

        [CommandComplete]
        public function validateAntPathCommand(trigger:ValidateAntPathMessage):void {
            _antCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateAntPathCommandError(trigger:ValidateAntPathMessage):void {
            _antCompleted = true;
            checkValidationsCompleted();
        }

        [CommandComplete]
        public function validateMavenPathCommand(trigger:ValidateMavenPathMessage):void {
            _mavenCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateMavenPathCommandError(fault:Error, trigger:ValidateMavenPathMessage):void {
            _mavenCompleted = true;
            checkValidationsCompleted();
        }

        [CommandComplete]
        public function validateCygwinPathCommand(trigger:ValidateCygwinPathMessage):void {
            _cygwinCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateCygwinPathCommandError(fault:Error, trigger:ValidateCygwinPathMessage):void {
            _cygwinCompleted = true;
            checkValidationsCompleted();
        }

        private function checkValidationsCompleted():void {
            if (_antCompleted && _mavenCompleted && _javaCompleted && _cygwinCompleted)
                launchUI();
        }

        private function launchUI():void {
            with (settings) {
                if (javaEnabled && antEnabled && mavenEnabled && cygwinEnabled) {
                    // open last project or create project
                } else {
                    SettingsWindow.show(context);
                }
            }
            callback(CommandCallBack.DEFAULT_RESULT);
        }
    }
}
