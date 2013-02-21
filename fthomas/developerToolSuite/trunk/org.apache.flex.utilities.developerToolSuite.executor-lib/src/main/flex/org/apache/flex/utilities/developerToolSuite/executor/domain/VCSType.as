package org.apache.flex.utilities.developerToolSuite.executor.domain {

    public class VCSType {

        public static const SVN:VCSType = new VCSType(new PrivateConstructor(), "SVN");
        public static const GIT:VCSType = new VCSType(new PrivateConstructor(), "GIT");

        private var _name:String;

        public function VCSType(cantInstantiate:PrivateConstructor, name:String) {
            _name = name;
        }

        public function get name():String {
            return _name;
        }
    }
}
internal class PrivateConstructor {};
