package org.apache.flex.utilities.developerToolSuite.executor.domain {
    import flash.utils.Dictionary;

    import mx.collections.ArrayCollection;

    [Bindable]
    public interface ISettingsModel {
        function get availableLanguages():ArrayCollection;

        function get currentLanguage():Object;

        function get environmentVariables():Dictionary;

        function get locale():String;

        function get JAVA_HOME():String;

        function get ANT_HOME():String;

        function get MAVEN_HOME():String;

        function get javaEnabled():Boolean;

        function get antEnabled():Boolean;

        function get mavenEnabled():Boolean;
    }
}
