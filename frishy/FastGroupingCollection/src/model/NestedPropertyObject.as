package model
{
    public class NestedPropertyObject
    {
        public function NestedPropertyObject()
        {
        }
        
        [Bindable]
        public var propertyChangeBindableObject:PropertyChangeBindableObject;
        
        [Bindable]
        public var uniqueEventBindableObject:UniqueEventBindableObject;
    }
}