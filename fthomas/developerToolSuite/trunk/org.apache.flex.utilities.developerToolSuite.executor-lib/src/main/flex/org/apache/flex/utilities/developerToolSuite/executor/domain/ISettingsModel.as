package org.apache.flex.utilities.developerToolSuite.executor.domain {
    [Bindable]
    public interface ISettingsModel extends ISettingsToSave {
        function get validationInProgress():ISettingsValidationInProgressModel;
    }
}
