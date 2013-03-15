package org.apache.flex.utilities.developerToolSuite.executor.domain {
    import flash.utils.Dictionary;

    import mx.collections.ArrayCollection;

    public interface ISettingsModel extends ISettingsToSave {

        function get javaEnabled():Boolean;

        function get antEnabled():Boolean;

        function get mavenEnabled():Boolean;

        function get cygwinEnabled():Boolean;

        function get svnEnabled():Boolean;

        function get gitEnabled():Boolean;

        function get availableLanguages():ArrayCollection;

        function get environmentVariables():Dictionary;

        function get currentLanguage():Object;

        function get validationInProgress():ISettingsValidationInProgressModel;
    }
}
