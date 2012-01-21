////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.frishy.collections
{
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.utils.Dictionary;
    
    
    /**
     *  The PriorityQueue class mx.managers.layoutClasses.PriorityQueue, but it has been
     *  made slightly more general purpose so that it can hold non-ILayoutManagerClients, 
     *  removeSmallestChild() and removeLargestChild() have been axed, and
     *  so that it can return the current largest or smallest priority number
     */
    public class PriorityQueue
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         */
        public function PriorityQueue()
        {
            super();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        private var priorityBins:Array = [];
        
        /**
         *  @private
         *  The smallest occupied index in arrayOfDictionaries.
         */
        private var minPriority:int = 0;
        
        /**
         *  @private
         *  The largest occupied index in arrayOfDictionaries.
         */
        private var maxPriority:int = -1;
        
        //--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        public function addObject(obj:Object, priority:int):void
        {       
            // Update our min and max priorities.
            if (maxPriority < minPriority)
            {
                minPriority = maxPriority = priority;
            }
            else
            {
                if (priority < minPriority)
                    minPriority = priority;
                if (priority > maxPriority)
                    maxPriority = priority;
            }
            
            var bin:PriorityBin = priorityBins[priority];
            
            if (!bin)
            {
                // If no hash exists for the specified priority, create one.
                bin = new PriorityBin();
                priorityBins[priority] = bin;
                bin.items[obj] = true;
                bin.length++;
            }
            else
            {
                // If we don't already hold the obj in the specified hash, add it
                // and update our item count.
                if (bin.items[obj] == null)
                { 
                    bin.items[obj] = true;
                    bin.length++;
                }
            }
            
        }
        
        /**
         *  @private
         */
        public function removeLargest():Object
        {
            var obj:Object = null;
            
            if (minPriority <= maxPriority)
            {
                var bin:PriorityBin = priorityBins[maxPriority];
                while (!bin || bin.length == 0)
                {
                    maxPriority--;
                    if (maxPriority < minPriority)
                        return null;
                    bin = priorityBins[maxPriority];
                }
                
                // Remove the item with largest priority from our priority queue.
                // Must use a for loop here since we're removing a specific item
                // from a 'Dictionary' (no means of directly indexing).
                for (var key:Object in bin.items )
                {
                    obj = key;
                    removeItem(key, maxPriority);
                    break;
                }
                
                // Update maxPriority if applicable.
                while (!bin || bin.length == 0)
                {
                    maxPriority--;
                    if (maxPriority < minPriority)
                        break;
                    bin = priorityBins[maxPriority];
                }
                
            }
            
            return obj;
        }
        
        /**
         *  @private
         */
        public function removeSmallest():Object
        {
            var obj:Object = null;
            
            if (minPriority <= maxPriority)
            {
                var bin:PriorityBin = priorityBins[minPriority];
                while (!bin || bin.length == 0)
                {
                    minPriority++;
                    if (minPriority > maxPriority)
                        return null;
                    bin = priorityBins[minPriority];
                }           
                
                // Remove the item with smallest priority from our priority queue.
                // Must use a for loop here since we're removing a specific item
                // from a 'Dictionary' (no means of directly indexing).
                for (var key:Object in bin.items )
                {
                    obj = key;
                    removeItem(key, minPriority);
                    break;
                }
                
                // Update minPriority if applicable.
                while (!bin || bin.length == 0)
                {
                    minPriority++;
                    if (minPriority > maxPriority)
                        break;
                    bin = priorityBins[minPriority];
                }           
            }
            
            return obj;
        }
        
        /**
         *  @private
         */
        protected function removeItem(client:Object, priority:int):Object
        {
            var bin:PriorityBin = priorityBins[priority];
            if (bin && bin.items[client] != null)
            {
                delete bin.items[client];
                bin.length--;
                return client;
            }
            return null;
        }
        
        /**
         *  @private
         */
        public function removeAll():void
        {
            priorityBins.length = 0;
            minPriority = 0;
            maxPriority = -1;
        }
        
        /**
         *  @private
         */
        public function isEmpty():Boolean
        {
            return minPriority > maxPriority;
        }
        
        /**
         *  Returns the max priority an item as it or -1 if there is none
         */
        public function getMaxPriority():int
        {
            var bin:PriorityBin = priorityBins[maxPriority];
            
            // TODO (frishbry): not sure if we need to do this loop 
            // since it's done at the end of removeSmallest() and removeLargest()
            // but it's done in the beginning, so perhaps there's a reason why it's in there
            while (!bin || bin.length == 0)
            {
                maxPriority--;
                if (maxPriority < minPriority)
                    return -1;
                bin = priorityBins[maxPriority];
            }
            
            return maxPriority;
        }
        
        /**
         *  Returns the min priority an item as it or -1 if there is none
         */
        public function getMinPriority():int
        {
            var bin:PriorityBin = priorityBins[minPriority];
            
            // TODO (frishbry): not sure if we need to do this loop 
            // since it's done at the end of removeSmallest() and removeLargest()
            // but it's done in the beginning, so perhaps there's a reason why it's in there
            while (!bin || bin.length == 0)
            {
                minPriority++;
                if (minPriority > maxPriority)
                    return -1;
                bin = priorityBins[minPriority];
            }
            
            return minPriority;
        }
    }
    
}

import flash.utils.Dictionary;

/**
 *  Represents one priority bucket of entries.
 *  @private
 */
class PriorityBin 
{
    public var length:int;
    public var items:Dictionary = new Dictionary();
    
}
