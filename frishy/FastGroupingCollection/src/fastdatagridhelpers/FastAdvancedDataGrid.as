package fastdatagridhelpers
{
    import flash.events.Event;
    
    import mx.controls.AdvancedDataGrid;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    
    public class FastAdvancedDataGrid extends AdvancedDataGrid
    {
        public function FastAdvancedDataGrid()
        {
            super();
        }
        
        override protected function collectionChangeHandler(event:Event):void
        {
            var ce:CollectionEvent = CollectionEvent(event);
            if (ce.kind != CollectionEventKind.UPDATE)
            {
                super.collectionChangeHandler(event);
            }
        }
    }
}