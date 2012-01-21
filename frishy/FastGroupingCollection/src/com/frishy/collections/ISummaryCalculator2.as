package com.frishy.collections
{
    import mx.collections.ISummaryCalculator;
    import mx.collections.SummaryField2;
    
    /**
     *  This interface is an extension of ISummaryCalculator that provides support 
     *  for non-numerical summary values.  Currently, it is supported by FastGroupingCollection, 
     *  but not GroupingCollection or GroupingCollection2.
     */
    public interface ISummaryCalculator2 extends ISummaryCalculator
    {
        /**
         *  Flex calls this method to end the computation of the summary value. 
         * 
         *  <p>Note: the only difference between this method and 
         *  <code>returnSummary</code> is that this method is typed to return 
         *  an Object rather than a Number.</p>
         *
         *  @param data The Object returned by the call to the <code>calculateSummary()</code> method.
         *  Use this Object to hold information necessary to perform the calculation.
         * 
         *  @param field The SummaryField2 for which the summary needs to calculated.
         *
         *  @return The summary value.
         */
        function returnSummary2(data:Object, field:SummaryField2):Object;
        
        /**
         *  Flex calls this method to end the summary calculation.
         * 
         *  <p>Note: the only difference between this method and 
         *  <code>returnSummaryOfSummary</code> is that this method is typed to return 
         *  an Object rather than a Number.</p> 
         *
         *  @param value The Object returned by a call to the <code>calculateSummaryOfSummary()</code> method
         *  that is used to store the summary calculation results. 
         *  This method modifies this Object; it does not return a value.
         *
         *  @param field The SummaryField2 for which the summary needs to calculated.
         *
         *  @return The summary value.
         */
        function returnSummaryOfSummary2(value:Object, field:SummaryField2):Object;
    }
}