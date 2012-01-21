package com.frishy.collections
{
    import flash.xml.XMLNode;
    
    import mx.collections.ArrayCollection;
    import mx.collections.ICollectionView;
    import mx.collections.XMLListCollection;

    /**
     *  Utility helper class to perform some common operations that collection classes 
     *  might need.
     */
    public class CollectionUtil
    {
        //--------------------------------------------------------------------------
        //
        //  Class Methods
        //
        //--------------------------------------------------------------------------
     
        /**
         *  Helper method to convert an object into an ICollectionView
         * 
         *  @param value object to convert to a collection
         *  @return a collection that represents the passed in value
         */
        public static function convertObjectToCollectionView(value:Object):ICollectionView
        {
            if (value == null)
                return null;
            
            // rest is same as GroupingCollection2.getCollection()
            
            // handle strings and xml
            if (typeof(value)=="string")
                value = new XML(value);
            else if (value is XMLNode)
                value = new XML(XMLNode(value).toString());
            else if (value is XMLList)
                value = new XMLListCollection(value as XMLList);
            
            if (value is XML)
            {
                var xl:XMLList = new XMLList();
                xl += value;
                return new XMLListCollection(xl);
            }
                //if already a collection dont make new one
            else if (value is ICollectionView)
            {
                return ICollectionView(value);
            }
            else if (value is Array)
            {
                return new ArrayCollection(value as Array);
            }
                //all other types get wrapped in an ArrayCollection
            else if (value is Object)
            {         
                // convert to an array containing this one item
                var tmp:Array = [];
                tmp.push(value);
                return new ArrayCollection(tmp);
            }
            else
            {
                return new ArrayCollection();
            }
        }
        
        /**
         *  Grabs a property from an object.  This property may be a nested property.
         *  
         *  <p>Because it supports nested properties, it doesn't just do data[dataField].</p>
         * 
         *  @param data the object to grab the value from
         *  @param dataField the data field property to use.  This may be a nested data field, 
         *                   like "foo.bar"
         * 
         *  @return the appropriate property value from the data object.
         */
        public static function getDataFieldValue(data:Object, dataField:String):Object
        {
            try 
            {
                var isComplexDataField:Boolean = (dataField.indexOf(".") >= 0);
                if (isComplexDataField)
                {
                    var pathElements:Array = dataField.split(".");
                    var currentItemData:Object = data;
                    
                    for each (var pathElement:String in pathElements)
                    {
                        currentItemData = currentItemData[pathElement];
                    }
                    
                    if (currentItemData != null)
                        return currentItemData.toString();
                }
                else if (data.hasOwnProperty(dataField))
                {
                    return data[dataField];
                }
            }
            catch(ignored:Error)
            {
            }
            
            return null;
        }
    }
}