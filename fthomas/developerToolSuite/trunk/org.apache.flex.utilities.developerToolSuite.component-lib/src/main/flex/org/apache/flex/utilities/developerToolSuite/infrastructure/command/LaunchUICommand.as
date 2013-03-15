package org.apache.flex.utilities.developerToolSuite.infrastructure.command {
    import mx.logging.ILogger;
    import mx.resources.ResourceManager;

    import org.apache.flex.utilities.developerToolSuite.executor.application.util.LogUtil;
    import org.apache.flex.utilities.developerToolSuite.executor.domain.SettingModel;
    import org.apache.flex.utilities.developerToolSuite.executor.domain.SettingsValidationProgressModel;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command.CommandCallBack;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command.CommandCallBackError;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command.CommandCallBackResult;
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
        public var settings:SettingModel;

        [MessageDispatcher]
        public var dispatch:Function;

        public var callback:Function;

        private var _javaCompleted:Boolean;
        private var _antCompleted:Boolean;
        private var _mavenCompleted:Boolean;
        private var _cygwinCompleted:Boolean;
        private var _svnCompleted:Boolean;
        private var _gitCompleted:Boolean;

        private var _progress:SettingsValidationProgressModel;

        public function execute():void {

            _progress = settings.validationInProgress as SettingsValidationProgressModel;
            _progress.isStarted = true;
            _progress.nbSteps = 6;
            _progress.currentStepLabel = "VALIDATING_JAVA_HOME";
            _progress.currentStep = 1;

            dispatch(new ValidateJavaPathMessage(settings.JAVA_HOME));
            dispatch(new ValidateAntPathMessage(settings.ANT_HOME));
            dispatch(new ValidateMavenPathMessage(settings.MAVEN_HOME));
            dispatch(new ValidateCygwinPathMessage(settings.CYGWIN_HOME));
            dispatch(new ValidateSvnPathMessage());
            dispatch(new ValidateGitPathMessage());
        }

        [CommandResult]
        public function validateJavaPathCommandResult(result:CommandCallBackResult, trigger:ValidateJavaPathMessage):void {
            LOG.debug("Java path validation completed");
            _javaCompleted = true;
            _progress.currentStepLabel = "VALIDATING_ANT_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateJavaPathCommandError(fault:CommandCallBackError, trigger:ValidateJavaPathMessage):void {
            LOG.debug("Java path validation error");
            _javaCompleted = true;
            _progress.currentStepLabel = "VALIDATING_ANT_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandResult]
        public function validateAntPathCommandResult(result:CommandCallBackResult, trigger:ValidateAntPathMessage):void {
            LOG.debug("Ant path validation completed");
            _antCompleted = true;
            _progress.currentStepLabel = "VALIDATING_MAVEN_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateAntPathCommandError(fault:CommandCallBackError, trigger:ValidateAntPathMessage):void {
            LOG.debug("Ant path validation error");
            _antCompleted = true;
            _progress.currentStepLabel = "VALIDATING_MAVEN_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandResult]
        public function validateMavenPathCommandResult(result:CommandCallBackResult, trigger:ValidateMavenPathMessage):void {
            LOG.debug("Maven path validation completed");
            _mavenCompleted = true;
            _progress.currentStepLabel = "VALIDATING_CYGWIN_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateMavenPathCommandError(fault:CommandCallBackError, trigger:ValidateMavenPathMessage):void {
            LOG.debug("Maven path validation error");
            _mavenCompleted = true;
            _progress.currentStepLabel = "VALIDATING_CYGWIN_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandResult]
        public function validateCygwinPathCommandResult(result:CommandCallBackResult, trigger:ValidateCygwinPathMessage):void {
            LOG.debug("Cygwin path validation completed");
            _cygwinCompleted = true;
            _progress.currentStepLabel = "VALIDATING_SVN_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateCygwinPathCommandError(fault:CommandCallBackError, trigger:ValidateCygwinPathMessage):void {
            LOG.debug("Cygwin path validation error");
            _cygwinCompleted = true;
            _progress.currentStepLabel = "VALIDATING_SVN_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandResult]
        public function validateSvnPathCommandResult(result:CommandCallBackResult, trigger:ValidateSvnPathMessage):void {
            LOG.debug("SVN path validation completed");
            _svnCompleted = true;
            _progress.currentStepLabel = "VALIDATING_GIT_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateSvnPathCommandError(fault:CommandCallBackError, trigger:ValidateSvnPathMessage):void {
            LOG.debug("SVN path validation error");
            _svnCompleted = true;
            _progress.currentStepLabel = "VALIDATING_GIT_HOME";
            _progress.currentStep += 1;
            checkValidationsCompleted();
        }

        [CommandResult]
        public function validateGitPathCommandResult(result:CommandCallBackResult, trigger:ValidateGitPathMessage):void {
            LOG.debug("GIT path validation completed");
            _gitCompleted = true;
            checkValidationsCompleted();
        }

        [CommandError]
        public function validateGitPathCommandError(fault:CommandCallBackError, trigger:ValidateGitPathMessage):void {
            LOG.debug("GIT path validation error");
            _gitCompleted = true;
            checkValidationsCompleted();
        }

        private function checkValidationsCompleted():void {
            if (_antCompleted && _mavenCompleted && _javaCompleted && _cygwinCompleted && _svnCompleted && _gitCompleted) {
                _progress.isStarted = false;
                launchUI();
            }
        }

        private function launchUI():void {
            callback(CommandCallBack.DEFAULT_RESULT);

            with (settings) {
                if (javaEnabled && antEnabled && mavenEnabled && cygwinEnabled && (svnEnabled || gitEnabled)) {
                    // open last project or create project
                } else {
                    SettingsWindow.show(context);
                }
            }
        }
    }
}
