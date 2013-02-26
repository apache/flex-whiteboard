package org.apache.flex.utilities.developerToolSuite.infrastructure.command {
    import mx.logging.ILogger;

    import org.apache.flex.utilities.developerToolSuite.executor.application.util.LogUtil;
    import org.apache.flex.utilities.developerToolSuite.executor.domain.ISettingsModel;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command.CommandCallBack;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateAntPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateCygwinPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateGitPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateJavaPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateMavenPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateSvnPathMessage;
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
        private var _svnCompleted:Boolean;
        private var _gitCompleted:Boolean;

        public function execute():void {

            dispatch(new ValidateJavaPathMessage(settings.JAVA_HOME));
            dispatch(new ValidateAntPathMessage(settings.ANT_HOME));
            dispatch(new ValidateMavenPathMessage(settings.MAVEN_HOME));
            dispatch(new ValidateCygwinPathMessage(settings.CYGWIN_HOME));
            dispatch(new ValidateSvnPathMessage());
            dispatch(new ValidateGitPathMessage());
        }

        [CommandComplete]
        public function validateJavaPathCommandCompleted(trigger:ValidateJavaPathMessage):void {
            _javaCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateJavaPathCommandError(trigger:ValidateJavaPathMessage):void {
            _javaCompleted = true;
            checkValidationsCompleted();
        }

        [CommandComplete]
        public function validateAntPathCommandCompleted(trigger:ValidateAntPathMessage):void {
            _antCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateAntPathCommandError(trigger:ValidateAntPathMessage):void {
            _antCompleted = true;
            checkValidationsCompleted();
        }

        [CommandComplete]
        public function validateMavenPathCommandCompleted(trigger:ValidateMavenPathMessage):void {
            _mavenCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateMavenPathCommandError(fault:Error, trigger:ValidateMavenPathMessage):void {
            _mavenCompleted = true;
            checkValidationsCompleted();
        }

        [CommandComplete]
        public function validateCygwinPathCommandCompleted(trigger:ValidateCygwinPathMessage):void {
            _cygwinCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateCygwinPathCommandError(fault:Error, trigger:ValidateCygwinPathMessage):void {
            _cygwinCompleted = true;
            checkValidationsCompleted();
        }

        [CommandComplete]
        public function validateSvnPathCommandCompleted(trigger:ValidateSvnPathMessage):void {
            _svnCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateSvnPathCommandError(fault:Error, trigger:ValidateSvnPathMessage):void {
            _svnCompleted = true;
            checkValidationsCompleted();
        }

        [CommandComplete]
        public function validateGitPathCommandCompleted(trigger:ValidateGitPathMessage):void {
            _gitCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateGiyPathCommandError(fault:Error, trigger:ValidateGitPathMessage):void {
            _gitCompleted = true;
            checkValidationsCompleted();
        }

        private function checkValidationsCompleted():void {
            if (_antCompleted && _mavenCompleted && _javaCompleted && _cygwinCompleted && _svnCompleted && _gitCompleted) {
                launchUI();
            }
        }

        private function launchUI():void {
            callback(CommandCallBack.DEFAULT_RESULT);

            with (settings) {
                if (javaEnabled && antEnabled && mavenEnabled && cygwinEnabled && (_svnCompleted || _gitCompleted)) {
                    // open last project or create project
                } else {
                    SettingsWindow.show(context);
                }
            }
        }
    }
}
