package org.apache.flex.utilities.developerToolSuite.executor.domain {

    [Bindable]
    public class ProjectDefinition {

        public var flexSdkVersion:String;
        public var airSdkVersion:String;
        public var fpVersion:String;

        public var name:String;
        public var location:String;
        public var vcsType:VCSType;

        public var id:uint;
        public var creationDate:Date;

        public function ProjectDefinition(name:String, location:String, vcsType:VCSType, flexSdkVersion:String, airSdkVersion:String, fpVersion:String) {
            this.name = name;
            this.location = location;
            this.vcsType = vcsType;
            this.flexSdkVersion = flexSdkVersion;
            this.airSdkVersion = airSdkVersion;
            this.fpVersion = fpVersion;
        }
    }
}
