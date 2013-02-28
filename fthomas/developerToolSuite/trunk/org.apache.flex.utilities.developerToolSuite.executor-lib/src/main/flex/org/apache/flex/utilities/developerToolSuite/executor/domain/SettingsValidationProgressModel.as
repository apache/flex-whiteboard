package org.apache.flex.utilities.developerToolSuite.executor.domain {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.ProgressEvent;

    public class SettingsValidationProgressModel extends EventDispatcher implements ISettingsValidationInProgressModel {

        private var _isStarted:Boolean;
        private var _nbSteps:uint;
        private var _currentStep:uint;
        private var _currentStepLabel:String = "";

        public function get isStarted():Boolean {
            return _isStarted;
        }

        public function get nbSteps():uint {
            return _nbSteps;
        }

        public function get currentStep():uint {
            return _currentStep;
        }

        public function get currentStepLabel():String {
            return _currentStepLabel;
        }

        [Bindable]
        public function set isStarted(value:Boolean):void {
            _isStarted = value;
        }

        public function set nbSteps(value:uint):void {

            var evt:Event;

            if (value != _nbSteps && value != _currentStep) {
                evt = new ProgressEvent(ProgressEvent.PROGRESS);
                ProgressEvent(evt).bytesLoaded = _currentStep;
                ProgressEvent(evt).bytesTotal = value;
            } else {
                evt = new Event(Event.COMPLETE);
            }

            _nbSteps = value;

            dispatchEvent(evt);
        }

        public function set currentStep(value:uint):void {

            var evt:Event;

            if (value != _currentStep && value != _nbSteps) {
                evt = new ProgressEvent(ProgressEvent.PROGRESS);
                ProgressEvent(evt).bytesLoaded = value;
                ProgressEvent(evt).bytesTotal = _nbSteps;
            } else {
                evt = new Event(Event.COMPLETE);
            }

            _currentStep = value;

            dispatchEvent(evt);
        }

        [Bindable]
        public function set currentStepLabel(value:String):void {
            _currentStepLabel = value;
        }
    }
}
