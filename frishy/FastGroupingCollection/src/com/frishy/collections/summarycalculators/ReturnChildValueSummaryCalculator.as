package com.frishy.collections.summarycalculators
{
    import com.frishy.collections.CollectionUtil;
    import com.frishy.collections.ISummaryCalculator2;
    
    import mx.collections.SummaryField2;

    /**
     *  Special summary calculator for use in FastGroupingCollection that returns 
     *  the same value as one of its children.  This is useful if you are attempting to 
     *  implement the composite pattern and all children have the same value for a particular 
     *  property.  If children have unique values for the property, this class is not as 
     *  as useful, and it may return a random children's value.
     */
    public class ReturnChildValueSummaryCalculator implements ISummaryCalculator2
    {
        
        //-------------------------------------------------------------------------- 
        // 
        // Constructor 
        // 
        //--------------------------------------------------------------------------
        
        public function ReturnChildValueSummaryCalculator() 
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
            return {}; 
        }
        
        /** 
         *  @inheritDoc 
         */ 
        public function calculateSummary(data:Object, field:SummaryField2, rowData:Object):void 
        { 
            data.value = CollectionUtil.getDataFieldValue(rowData, field.dataField); 
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
            return {value: value.value}; 
        }
        
        /** 
         *  @inheritDoc 
         */ 
        public function calculateSummaryOfSummary(value:Object, newValue:Object, field:SummaryField2):void 
        { 
            value.value = newValue.value; 
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