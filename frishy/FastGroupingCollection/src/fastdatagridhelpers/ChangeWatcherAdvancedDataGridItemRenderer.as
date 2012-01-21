package fastdatagridhelpers
{
    import flash.events.Event;
    
    import mx.binding.utils.ChangeWatcher;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridItemRenderer;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
    import mx.core.UIComponentGlobals;
    import mx.core.mx_internal;
    
    use namespace mx_internal;
    
    public class ChangeWatcherAdvancedDataGridItemRenderer extends AdvancedDataGridItemRenderer
    {
        public function ChangeWatcherAdvancedDataGridItemRenderer()
        {
            super();
        }
        
        private var invalidatePropertiesFlag:Boolean = false;
        
        private var invalidateSizeFlag:Boolean = false;
        
        private var changeWatcher:ChangeWatcher;
        
        override public function set data(value:Object):void
        {
            if (data)
            {
                removeChangeWatcher();
            }
            
            super.data = value;
            
            if (data)
            {
                addChangeWatcher();
            }
        }
        
        protected function addChangeWatcher():void
        {
            var adgListData:AdvancedDataGridListData = AdvancedDataGridListData(listData);
            if (adgListData.dataField)
            {
                changeWatcher = ChangeWatcher.watch(data, adgListData.dataField.split("."), dataHasUpdated);
            }
        }
        
        protected function removeChangeWatcher():void
        {
            if (changeWatcher)
            {
                changeWatcher.unwatch();
                changeWatcher = null;
            }
        }
        
        protected function dataHasUpdated(event:Event = null):void
        {
            if (nestLevel && !invalidatePropertiesFlag)
            {
                UIComponentGlobals.layoutManager.invalidateProperties(this);
                invalidatePropertiesFlag = true;
//                UIComponentGlobals.layoutManager.invalidateSize(this);
//                invalidateSizeFlag = true;
            }
        }
        
        override public function validateProperties():void
        {
            invalidatePropertiesFlag = false;
            
            // update listData.label so super.validateProperties() will update the text correctly
            var _listData:AdvancedDataGridListData = listData as AdvancedDataGridListData;
            if (_listData)
            {
                var label:String;
                try 
                {
                    var isComplexDataField:Boolean = (_listData.dataField.indexOf(".") >= 0);
                    if (isComplexDataField)
                    {
                        var pathElements:Array = _listData.dataField.split(".");
                        var currentItemData:Object = data;
                        
                        for each (var pathElement:String in pathElements)
                        {
                            currentItemData = currentItemData[pathElement];
                        }
                        
                        if (currentItemData != null)
                            label = currentItemData.toString();
                    }
                    else if (data.hasOwnProperty(_listData.dataField))
                    {
                        label = data[_listData.dataField];
                    }
                }
                catch(ignored:Error)
                {
                }
                
                _listData.label = label;
            }
            super.validateProperties();
        }
    }
}