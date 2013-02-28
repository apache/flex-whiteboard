package org.apache.flex.utilities.developerToolSuite.executor.domain {

    public interface ISettingsValidationInProgressModel {
        function get isStarted():Boolean;

        function get nbSteps():uint;

        function get currentStep():uint;

        function get currentStepLabel():String;
    }
}
