package com.frishy.collections.summarycalculators
{
    import com.frishy.collections.CollectionUtil;
    import com.frishy.collections.ISummaryCalculator2;
    
    import mx.collections.SummaryField2;
    
    /**
     *  Special summary calculator for use in FastGroupingCollection that creates an array 
     *  of values from the children.  This can be useful if you are implementing the composite
     *  pattern.  If the values are themselves arrays, it will 
     *  not create an array of arrays, but instead will create a single array out of 
     *  those values.  This way, multiple levels will still calculate summaries easily.
     */
    public class ReturnArrayOfChildValuesSummaryCalculator implements ISummaryCalculator2 
    { 
        //-------------------------------------------------------------------------- 
        // 
        // Class Members 
        // 
        //--------------------------------------------------------------------------
        
        private static function addUniqueValuesToArray(newValue:Object, currentValueArray:Array):void 
        { 
            var newValues:Array = newValue as Array;
            
            if (newValues) 
            { 
                for (var i:int = 0; i < newValues.length; i++) 
                { 
                    if (currentValueArray.indexOf(newValues[i]) == -1) 
                    { 
                        currentValueArray.push(newValues[i]); 
                    } 
                } 
            } 
            else 
            { 
                if (currentValueArray.indexOf(newValue) == -1) 
                { 
                    currentValueArray.push(newValue); 
                } 
            } 
        }
        
        //-------------------------------------------------------------------------- 
        // 
        // Constructor 
        // 
        //--------------------------------------------------------------------------
        
        public function ReturnArrayOfChildValuesSummaryCalculator() 
        { 
            super(); 
        }
        
        //-------------------------------------------------------------------------- 
        // 
        // Methods: ISummaryCalculator 
        // 
        //--------------------------------------------------------------------------
        
        /** 
         *  @inheritDoc 
         */ 
        public function summaryCalculationBegin(field:SummaryField2):Object 
        { 
            return {value: []}; 
        }
        
        /** 
         *  @inheritDoc 
         */ 
        public function calculateSummary(data:Object, field:SummaryField2, rowData:Object):void 
        { 
            var newValue:Object = CollectionUtil.getDataFieldValue(rowData, field.dataField); 
            var currentValueArray:Array = data.value;
            
            addUniqueValuesToArray(newValue, currentValueArray) 
        }
        
        /** 
         *  @inheritDoc 
         */ 
        public function returnSummary(data:Object, field:SummaryField2):Number 
        { 
            return returnSummary2(data, field) as Number; 
        }
        
        /** 
         *  @inheritDoc 
         */ 
        public function returnSummary2(data:Object, field:SummaryField2):Object 
        { 
            return data.value; 
        }
        
        /** 
         *  @inheritDoc 
         */ 
        public function summaryOfSummaryCalculationBegin(value:Object, field:SummaryField2):Object 
        { 
            return {value: value.value.concat()}; 
        }
        
        /** 
         *  @inheritDoc 
         */ 
        public function calculateSummaryOfSummary(value:Object, newValue:Object, field:SummaryField2):void 
        { 
            var newValue:Object = newValue.value; 
            var currentValueArray:Array = value.value;
            
            addUniqueValuesToArray(newValue, currentValueArray); 
        }
        
        /** 
         *  @inheritDoc 
         */ 
        public function returnSummaryOfSummary(value:Object, field:SummaryField2):Number 
        { 
            return returnSummaryOfSummary2(value, field) as Number; 
        }
        
        /** 
         *  @inheritDoc 
         */ 
        public function returnSummaryOfSummary2(value:Object, field:SummaryField2):Object 
        { 
            return value.value; 
        } 
    }
}