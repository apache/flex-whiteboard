package com.frishy.collections
{
import com.frishy.utils.LayoutManagerClientHelper;

import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

import mx.binding.utils.ChangeWatcher;
import mx.collections.ArrayCollection;
import mx.collections.DefaultSummaryCalculator;
import mx.collections.Grouping;
import mx.collections.GroupingField;
import mx.collections.HierarchicalData;
import mx.collections.ICollectionView;
import mx.collections.IGroupingCollection2;
import mx.collections.IHierarchicalCollectionView;
import mx.collections.IList;
import mx.collections.ISummaryCalculator;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.SummaryField2;
import mx.collections.SummaryObject;
import mx.collections.SummaryRow;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;

use namespace mx_internal;

public class FastGroupingCollection extends HierarchicalData 
    implements IGroupingCollection2
{
    
    //--------------------------------------------------------------------------
    //
    //  Class Members
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static const DEFAULT_SUMMARY_CALCULATOR:DefaultSummaryCalculator = new DefaultSummaryCalculator();
    
    /**
     *  @private
     *  Label to use when no grouping data can be found on a particular object
     */
    private static const NO_VALID_GROUPING_FIELD_VALUE:String = "Not Available";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     */
    public function FastGroupingCollection()
    {
        super();
        
        rootItemLookupObject = new ItemLookupObject();
        rootItemLookupObject.node = new ArrayCollection();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Helper class to defer validation as part of the normal layout manager pass
     */
    private var layoutManagerClientHelper:LayoutManagerClientHelper = 
        new LayoutManagerClientHelper(commitProperties);
    
    /**
     *  @private 
     *  Indicates if events should be dispatched.
     *  calls to enableEvents() and disableEvents() effect the value when == 0
     *  events should be dispatched. 
     */
    private var _dispatchEvents:int = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Variables: Basic group data structure storage
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Root item lookup.  ItemLookupObjects store the 
     *  node, the childrenLookupDictionary, and the childrenCollection.  
     *  The childrenCollection is usually hanging on to node[childrenField], but 
     *  for the root, the node is the childrenCollection.
     */
    private var rootItemLookupObject:ItemLookupObject;
    
    /**
     *  @private
     *  An automatic sort gets applied to all groups that get 
     *  created.  Since we just keep the root ArrayCollection as 
     *  the exact same reference on a complete reset/refresh() call, 
     *  we need to keep track of the sort that was applied on the root 
     *  collection so on a complete reset, we know whether the user applied 
     *  a new sort to the root or not.  If they applied a new sort, 
     *  we shouldn't apply our auto-sort anymore.
     */
    private var autoAppliedSortOnRoot:Sort;
    
    /**
     *  @private
     *  Keeps track of whether a complete recalculation is needed
     */
    private var needToRecalculateGroups:Boolean = false;
    
    /**
     *  Maps nodes to parents
     */
    mx_internal var itemToParentNode:Dictionary;
    
    //--------------------------------------------------------------------------
    //
    //  Variables: ChangeWatchers and dealing with property changes
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Maps items to an Array of ChangeWatchers installed on that particular item
     */
    private var itemToChangeWatchers:Dictionary;
    
    /**
     *  Keeps track of items whose groupingFields have changed.  We don't
     *  handle them synchronously in the grouping field change watcher in case
     *  multiple grouping properties change at the same time
     */
    private var itemsInNeedOfRegrouping:Dictionary;
    
    //--------------------------------------------------------------------------
    //
    //  Variables: Summaries
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  A Dictionary to maintain summaries
     *  Key is in format: 
     *      summariesTracker[node][summaryField.summaryOperation.toString()][summaryField.dataField]
     *  Value is a SummaryObjectHolder:
     *      {summaryObject:summaryObject, summaryValue:summaryValue};
     */
    private var summariesTracker:Dictionary;
    
    /**
     *  Maps depth level to summary fields that need calculation
     *  at that level.  0 is root level.  grouping.fields.length is
     *  leaf group.
     */
    private var summaryFieldsByDepth:Dictionary;
    
    /**
     *  Keeps track of whether there are any summaries that need 
     *  to be calculated
     */
    private var hasSummaryFields:Boolean = false;
    
    /**
     *  List of internal groups whose summaries need to be recalculated.
     *  It is in PriorityQueue form so that the ones further down the tree
     *  get calculated first so that the ones higher up in the tree can 
     *  depend on them.  Leaf group nodes get calculated first, but are kept 
     *  in separate queues to distinguish between needing to be copied
     *  vs. needing to be recalculated.
     */
    private var internalGroupsInNeedOfSummaryRecalculation:PriorityQueue;
    
    /**
     *  Leaf groups that need to have their summary moved from the tracker 
     *  summary object and pushed into the actual collection.  This may be 
     *  the case when items just get added and the summary is kept up-to-date 
     *  as the item(s) get added.
     */ 
    private var leafGroupsInNeedOfSummaryCopy:Dictionary;
    
    /**
     *  Leaf groups that need to have their summary completely recalculated
     *  (for instance because an item got removed).
     */ 
    private var leafGroupsInNeedOfSummaryRecalculation:Dictionary;
    
    /**
     *  If some summaries need to be recalculated.  By deferring it and just keeping 
     *  track of the variable, if 2 items are removed from the same group, that groups
     *  summaries are only calculated once.
     */ 
    private var needToRecalculateSummaries:Boolean;
    
    /**
     *  Maps nodes to SummaryObject instances.  This is used to know what to remove 
     *  when recalculating the summary objects.
     */
    private var objectSummaryMap:Dictionary = new Dictionary(true);
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // grouping
    //----------------------------------
    
    private var _grouping:Grouping;
    
    [Bindable("groupingChanged")]
    
    /**
     *  @copy mx.collections.IGroupingCollection2#grouping
     */
    public function get grouping():Grouping
    {
        return _grouping;
    }
    
    /**
     *  @private
     */
    public function set grouping(value:Grouping):void
    {
        _grouping = value;
        
        needToRecalculateGroups = true;
        layoutManagerClientHelper.invalidateProperties();
        
        dispatchEvent(new Event("groupingChanged"));
    }
    
    //----------------------------------
    // maxDepth
    //----------------------------------
    
    // TODO (frishbry): separate subclass for this add-on behavior?? 
    private var _maxDepth:int = -1;
    
    /**
     *  The maximum depth of children to display for this grouping collection.
     *  Set to -1 to display all groups, set to 0 to just show the root level 
     *  groups, set to 1 to show two levels of groups, etc...
     * 
     *  <p>This can be useful when you are using summaries to calculate values at 
     *  the group level, but you might not necessarily want to show all leaf nodes
     *  to the user.  This can hide some of the complexity of the initial data source 
     *  to the user.</p>
     * 
     *  @default -1
     */  
    public function get maxDepth():int
    {
        return _maxDepth;
    }
    
    /**
     *  @private
     */
    public function set maxDepth(value:int):void
    {
        if (value == _maxDepth)
            return;
        
        _maxDepth = value;
        
        needToRecalculateGroups = true;
        layoutManagerClientHelper.invalidateProperties();
    }
    
    //----------------------------------
    // summaries
    //----------------------------------
    
    /**
     *  @private
     */
    private var _summaries:Array;
    
    /**
     *  @copy mx.collections.GroupingCollection2#summaries
     */
    public function get summaries():Array
    {
        return _summaries;
    }
    
    /**
     *  @private
     */
    public function set summaries(value:Array):void
    {
        _summaries = value;
        
        // really don't need to recalculate groups, but the summaries flag today 
        // is just used to loop through nodes on the list(s) that need recalculation, 
        // whereas here we need to add all groups to that list first.
        // It's not worth the code to do a simple loop through all the groups, though.
        needToRecalculateGroups = true;
        layoutManagerClientHelper.invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overriden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // source
    //----------------------------------
    
    private var sourceCollection:ICollectionView;
    
    /**
     *  The source collection containing the flat data to be grouped.
     *  
     *  If the source is not a collection, it will be auto-wrapped into a collection.
     */
    override public function get source():Object
    {
        return sourceCollection;
    }
    
    /**
     *  @private
     */
    override public function set source(value:Object):void
    {
        if (sourceCollection)
        {
            sourceCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, 
                sourceCollection_collectionChangeHandler);
        }
        
        sourceCollection = CollectionUtil.convertObjectToCollectionView(value);
        
        if (sourceCollection)
        {
            sourceCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, 
                sourceCollection_collectionChangeHandler);
        }
        
        needToRecalculateGroups = true;
        layoutManagerClientHelper.invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy mx.collections.IGroupingCollection2#refresh
     *  TODO: asynch isn't handled here...
     */
    public function refresh(async:Boolean=false, dispatchCollectionEvents:Boolean=false):Boolean
    {
        if (!sourceCollection)
            return true;
        
        // refresh() always recalculates everything...maybe it shouldn't, but that 
        // is the traditional Flex collection model 
        needToRecalculateGroups = true; 
        layoutManagerClientHelper.validateNow();
        
        return true;
    }
    
    /**
     *  @copy mx.collections.IGroupingCollection2#cancelRefresh
     *  TODO: asynch isn't handled here...
     */
    public function cancelRefresh():void
    {
        //TODO: implement function...only needed for async though
    }
    
    /**
     *  Handles validation
     */
    protected function commitProperties():void
    {
        if (needToRecalculateGroups)
        {
            performCompleteRecalculationOfGroups(true);
            // performCompleteRecalculationOfGroups() will set needToRecalculateGroups to false
        }
        
        if (itemsInNeedOfRegrouping)
        {
            for (var item:Object in itemsInNeedOfRegrouping)
            {
                removeItemAndRemoveEmptyGroups(item);
                insertItemAndCreateGroups(item);
            }
            
            itemsInNeedOfRegrouping = null;
        }
        
        if (needToRecalculateSummaries)
        {
            performRecalculateSummaries();
            // performRecalculateSummaries() will set needToRecalculateSummaries to false
        }
    }
    
    /**
     *  @private
     *  Can be used for testing purposes or if you absolutely need to get absolute data 
     *  right now and can't wait for the normal validation pass.  Calling this 
     *  instead of refresh() is preferred since refresh() goes through and recalculates
     *  everything anew, rather than just validating what has become invalid.
     */
    mx_internal function validateNow():void
    {
        layoutManagerClientHelper.validateNow();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: Grouping
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Completely recalculates all the groups in the source collection.
     *  This is for startup, when grouping fields change, or when a RESET occurs
     */
    protected function performCompleteRecalculationOfGroups(dispatchCollectionEvents:Boolean=true):void
    {
        if (!needToRecalculateGroups)
            return;
        
        needToRecalculateGroups = false;
        
        // disable events for now -- we will dispatch one big reset at the end
        disableEvents();
        
        initializeVariables();
        
        // loop through source collection...using an IList is much faster 
        // than ICollectionView interface
        var sourceList:IList = sourceCollection as IList;
        var currentItem:Object;
        var len:int = 0;
        if (sourceList)
        {
            len = sourceList.length;
            for (var i:int = 0; i < len; i++)
            {
                currentItem = sourceList.getItemAt(i);
                
                insertItemAndCreateGroups(currentItem);
            }
        }
        else if (sourceCollection)
        {
            var cursor:IViewCursor = sourceCollection.createCursor();
            var hasNext:Boolean = !cursor.afterLast;
            while (hasNext)
            {
                currentItem = cursor.current;
                
                insertItemAndCreateGroups(currentItem);
                
                hasNext = cursor.moveNext();
                len++;
            }
        }
        
        enableEvents();
        
        if (len > 0 && dispatchCollectionEvents)
            internalDispatchEvent(CollectionEventKind.RESET);
    }
    
    /**
     *  Initializes variables during a complete reset
     */
    protected function initializeVariables():void
    {
        // clear out root node
        ArrayCollection(rootItemLookupObject.node).removeAll();
        
        // what about when sort is null?  Does that mean they explicitly don't want a sort, or that 
        // they want the "auto" behavior???  I think it's the former, and atleast that way, 
        // they can always just explicitly set it 
        if (ArrayCollection(rootItemLookupObject.node).sort == autoAppliedSortOnRoot) 
        { 
            autoAppliedSortOnRoot = applyDefaultGroupingFieldSortToCollection(
                ArrayCollection(rootItemLookupObject.node), -1);
        } 
        
        rootItemLookupObject.childrenToItemLookup = new Dictionary();
        itemToParentNode =  new Dictionary();
        
        // clear out change watchers 
        if (itemToChangeWatchers) 
        { 
            var changeWatchersArray:Array; 
            var cw:ChangeWatcher; 
            for (var item:Object in itemToChangeWatchers) 
            { 
                changeWatchersArray = itemToChangeWatchers[item];
                
                var len:int = changeWatchersArray.length; 
                for (var i:int = 0; i < len; i++) 
                { 
                    cw = changeWatchersArray[i]; 
                    cw.unwatch(); 
                } 
            } 
        } 
        itemToChangeWatchers = new Dictionary(); 

        // handle summary fields
        prepareSummaryFields();
        
        if (hasSummaryFields)
        {
            summariesTracker = new Dictionary();
            
            if (internalGroupsInNeedOfSummaryRecalculation)
                internalGroupsInNeedOfSummaryRecalculation.removeAll();
            else
                internalGroupsInNeedOfSummaryRecalculation = new PriorityQueue();
            
            leafGroupsInNeedOfSummaryCopy = new Dictionary();
            leafGroupsInNeedOfSummaryRecalculation = new Dictionary();
            
            var groupingFieldLen:int = ((grouping && grouping.fields) ? grouping.fields.length : 0);
            if (groupingFieldLen == 0)
                startCalculationForLeafGroup(rootItemLookupObject.node);
        }
        else
        {
            summariesTracker = null;
            
            if (internalGroupsInNeedOfSummaryRecalculation)
                internalGroupsInNeedOfSummaryRecalculation.removeAll();
            
            leafGroupsInNeedOfSummaryCopy = null;
            leafGroupsInNeedOfSummaryRecalculation = null;
        }
    }
    
    /**
     *  Inserts the item and creates the parent groups as necessary.
     * 
     *  <p>Starts out at root and moves way downward through the grouping fields.  
     *  If it can't find a grouping field, one will be created.  Along the way down, 
     *  it will figure out what groups have a summary that should be recalculated.</p>
     */
    protected function insertItemAndCreateGroups(item:Object):void
    {
        var currentItemLookupObject:ItemLookupObject = rootItemLookupObject;
        var currentChildrenLookup:Dictionary = currentItemLookupObject.childrenToItemLookup;
        
        // for root, node is node and also ArrayCollection
        var currentNode:Object = currentItemLookupObject.node;
        var currentChildrenCollection:ArrayCollection = ArrayCollection(currentNode);
        var rootItemWasEmpty:Boolean = (currentChildrenCollection.length == 0); 

        var groupingFieldsLen:int = (grouping && grouping.fields ? grouping.fields.length : 0);
        
        // if we are inserting a new item, at some level, we'll need to recalculate summaries
        // if they do exist for this grouping collection
        if (hasSummaryFields)
        {
            needToRecalculateSummaries = true;
            layoutManagerClientHelper.invalidateProperties();
            
            // add in root node 
            if (groupingFieldsLen == 0) 
                leafGroupsInNeedOfSummaryCopy[currentNode] = true; 
            else 
                internalGroupsInNeedOfSummaryRecalculation.addObject(currentNode, 0);
        }
        
        // loop through all grouping fields
        for (var i:int = 0; i < groupingFieldsLen; i++)
        {
            var groupingField:GroupingField = grouping.fields[i];
            var dataField:String = groupingField.name;
            var value:String = getGroupingLabel(item, groupingField);
            
            if (!value)
                return;
            
            // check to see if we have a parent group for this item at this level already
            if (!currentChildrenLookup[value])
            {
                // create a new grouped object
                var newGroupedObject:Object = createGroupedObject(grouping, groupingField, value, i);
                
                // add it into collection and into map as well
                currentChildrenCollection.addItem(newGroupedObject);
                var itemLookupObject:ItemLookupObject = new ItemLookupObject();
                currentChildrenLookup[value] = itemLookupObject;
                itemLookupObject.node = newGroupedObject;
                
                // add this group into the parent map
                itemToParentNode[newGroupedObject] = currentItemLookupObject;
                
                if (i == groupingFieldsLen - 1)
                { 
                    // if leaf group, then start calculations on it
                    if (hasSummaryFields)
                        startCalculationForLeafGroup(newGroupedObject);
                }
            }
            
            currentItemLookupObject = ItemLookupObject(currentChildrenLookup[value]);
            currentChildrenLookup = currentItemLookupObject.childrenToItemLookup;
            currentNode = currentItemLookupObject.node;
            currentChildrenCollection = currentNode[childrenField];
            
            // every item on the chain down is in need of recalculation for summaries, 
            // if that is applicable.
            
            // theoretically, rather than checking hasSummaryFields, it could check hasSummaryField at 
            // index i
            if (hasSummaryFields)
            {
                if (i == groupingFieldsLen - 1)
                { 
                    leafGroupsInNeedOfSummaryCopy[currentNode] = true;
                }
                else
                {
                    // On addition of items into an internal group, we can't just calculate the 
                    // summary here, like we do for leaf groups, and then just copy it over later.
                    // This is because when an item gets added, it might not necessarily be a new
                    // item for the new group (whereas for the leaf group it always is a new item);
                    // instead, it could just mean the summary value for one of its child groups
                    // has changed.  For this reason, we need to just mark the whole internal group
                    // as invalid and revisit all of the children to completely recalculate the summaries.
                    
                    // i == groupingFieldsLen is leafGroup
                    // i == groupingFieldsLen - 1 is first internal group
                    // i == 0 is root
                    // i == 1 is first group
                    internalGroupsInNeedOfSummaryRecalculation.addObject(currentNode, i + 1);
                }
            }
        }
        
        // now add the item in the last collection and dictionary if it's not there already
        // usually currentChildrenLookup maps grouping values to ItemLookupObjects.
        // However, at leaf nodes, it's just use a hashset to store items
        if (!currentChildrenLookup[item])
        {
            currentChildrenCollection.addItem(item);
            currentChildrenLookup[item] = item;
            itemToParentNode[item] = currentItemLookupObject;
            
            // if don't need to recalculate the summaries, then add this summary
            if (hasSummaryFields)
            {
                addDataObjectToLeafGroupSummary(currentNode, item);
            }
            
            // change watchers
            addChangeWatchersForItem(item);
        }
        
        // TODO (frishbry): workaround bug in HCV where sorts aren't getting 
        //                  applied, unless we do this... *sigh* 
        if (rootItemWasEmpty) 
        { 
            internalDispatchEvent(CollectionEventKind.RESET); 
        }
    }
    
    /**
     *  Removes the item and removes empty parent groups as necessary.
     * 
     *  <p>Starts out at leaf node and moves its way up.  Along the way up, 
     *  it will figure out what groups have a summary that should be recalculated
     *  (hint: it's all of them).</p>
     */
    protected function removeItemAndRemoveEmptyGroups(item:Object):void
    {
        // every item on the chain down is in need of recalculation for summaries, if that
        // is applicable.  no need to put the root down, since that is always the case...
        if (hasSummaryFields)
        {
            needToRecalculateSummaries = true;
            layoutManagerClientHelper.invalidateProperties();
        }
        
        var currentItem:Object = item;
        var prevItemLookupObject:ItemLookupObject = null;
        var currentItemLookupObject:ItemLookupObject = itemToParentNode[currentItem];
        
        var currentChildrenLookup:Dictionary;
        var currentNode:Object;
        var isRoot:Boolean;
        var currentChildrenCollection:ArrayCollection;
        
        
        // i == groupingFieldsLen is leafGroup
        // i == groupingFieldsLen - 1 is first internal group
        // i == 0 is root
        // i == 1 is first group
        var groupingFieldsLen:int = grouping && grouping.fields ? grouping.fields.length : 0;
        var currentDepth:int = groupingFieldsLen;
        var shouldRemoveGroup:Boolean = true; // first one starts out as true as we need to remove the item
        
        while (currentItemLookupObject != null)
        {
            currentChildrenLookup = currentItemLookupObject.childrenToItemLookup;
            currentNode = currentItemLookupObject.node;
            isRoot = (currentNode is ArrayCollection);
            currentChildrenCollection = (isRoot ? ArrayCollection(currentNode) : currentNode[childrenField]);
            
            if (shouldRemoveGroup)
            {
                // item may be filtered out at this exact moment, so try removing from underlying collection 
                var currentItemIndexInChildrenCollection:int = currentChildrenCollection.list.getItemIndex(currentItem); 
                // TODO (frishbry): should we add a check for -1 here? 
                currentChildrenCollection.list.removeItemAt(currentItemIndexInChildrenCollection);
                
                delete itemToParentNode[currentItem];
                
                if (!prevItemLookupObject)
                {
                    // at leaf group
                    delete currentChildrenLookup[currentItem];
                    
                    // change watchers
                    removeChangeWatchersForItem(currentItem);
                }
                else
                {
                    if (hasSummaryFields)
                    {
                        delete objectSummaryMap[currentItem];
                    }
                    
                    // want to delete from currentChildrenLookup as well, but the mapping is 
                    // currentChildrenLookup[itemValueForGroupingField] = currentItemLookupObject
                    // but we don't have itemValueForGroupingField and we can't rely on getting the 
                    // same value back since the groupingField may have changed, so similar to the 
                    // currentChildrenCollection, we're forced to do another O(n) lookup here
                    for (var key:String in currentChildrenLookup)
                    {
                        if (currentChildrenLookup[key] == prevItemLookupObject)
                        {
                            delete currentChildrenLookup[key];
                            break;
                        }
                    }
                }
                
            }
            
            prevItemLookupObject = currentItemLookupObject;
            currentItemLookupObject = itemToParentNode[currentNode];
            currentItem = currentNode;
            var currentChildrenCollectionLen:int = currentChildrenCollection.length; 
            shouldRemoveGroup = (currentChildrenCollectionLen == 0); 
            
            // check again if there are summaries and the collection isn't empty 
            if (hasSummaryFields && !shouldRemoveGroup) 
            { 
                var currentNodeSummaries:Array = objectSummaryMap[currentNode]; 
                if (currentNodeSummaries) 
                { 
                    // need to check <= because summary placement may be "row", so there 
                    // could be more summaries than extra rows 
                    if (currentChildrenCollectionLen <= currentNodeSummaries.length) 
                    { 
                        shouldRemoveGroup = true; 
                        
                        // assume shouldRemoveGroup is now true, but need to check 
                        // to make sure all items in the currentChildrenCollection are 
                        // in currentNodeSummaries 
                        for (var i:int = 0; i < currentChildrenCollectionLen; i++) 
                        { 
                            var currentChildItem:Object = currentChildrenCollection.getItemAt(i); 
                            
                            if (currentNodeSummaries.indexOf(currentChildItem == -1)) 
                            { 
                                shouldRemoveGroup = false; 
                                break; 
                            } 
                        } 
                    } 
                } 
            }
            
            // every item on the chain down is in need of recalculation for summaries, if that
            // is applicable.
            if (hasSummaryFields && !shouldRemoveGroup)
            {
                // i == groupingFieldsLen is leafGroup
                // i == groupingFieldsLen - 1 is first internal group
                // i == 0 is root
                // i == 1 is first group
                if (currentDepth == groupingFieldsLen)
                    leafGroupsInNeedOfSummaryRecalculation[currentNode] = true;
                else
                    internalGroupsInNeedOfSummaryRecalculation.addObject(currentNode, currentDepth);
            }
            
            currentDepth--;
        }
        
        // if we've exited the loop and shouldRemoveGroup is true,
        // then we should remove summaries from the root group as well
        if (shouldRemoveGroup)
        {
            ArrayCollection(rootItemLookupObject.node).removeAll();
            delete objectSummaryMap[rootItemLookupObject.node];
        }
    }
    
    /**
     *  @private
     *  Get the grouping label for a particular GroupingField for 
     *  a data item
     */ 
    private function getGroupingLabel(data:Object, field:GroupingField):String
    {
        if (field.groupingFunction != null) 
            return field.groupingFunction(data, field);
        
        var dataField:String = field.name; 
        var dataFieldValue:Object = CollectionUtil.getDataFieldValue(data, dataField);
        
        if (dataFieldValue != null) 
            return dataFieldValue.toString();
        
        return NO_VALID_GROUPING_FIELD_VALUE; 
    }
    
    /**
     *  @private
     *  Creates the object to be used for the particular group
     */ 
    private function createGroupedObject(grouping:Grouping, 
                                         groupingField:GroupingField, 
                                         groupValue:String,
                                         depth:int):Object
    {
        var newGroupedObject:Object;
        
        if (groupingField && groupingField.groupingObjectFunction != null)
            newGroupedObject = groupingField.groupingObjectFunction(groupValue);
        else if (grouping.groupingObjectFunction != null)
            newGroupedObject = grouping.groupingObjectFunction(groupValue);
        else
            newGroupedObject = {};
        
        var groupingArrayCollection:ArrayCollection = new ArrayCollection();
        
        applyDefaultGroupingFieldSortToCollection(groupingArrayCollection, depth);
        
        newGroupedObject[childrenField] = groupingArrayCollection;
        
        newGroupedObject[grouping.label] = groupValue;
        
        return newGroupedObject;
    }
    
    /**
     *  Applies a default sort to an ArrayCollection based on the grouping 
     *  fields properties.
     * 
     *  <p>In order of precedence, the sort that is applied is based on:
     *      <ol>
     *          <li>compareFunction = groupingField.compareFunction</li>
     *          <li>compareFunction = grouping.compareFunction</li>
     *          <li>compareField = grouping.label</li>
     *      </ol>
     *  </p>
     * 
     *  <p>Note that when a wrapping HierarchicalCollectionView wraps a grouping collection 
     *  and applies a Sort, it will override the default Sort that is being applied here.</p>
     * 
     *  TODO (frishbry): This default sort gets whacked by the HCV anyway with:
     *      
     *       // apply sort to all the collections including the child collections
     *       if (sortCanBeApplied(treeData) && !(treeData.sort == null && sort == null))
     *       {
     *           treeData.sort = sort;
     *           treeData.refresh();
     *           dispatch = true;
     *       }
     *  
     *  So what's the point of applying the sort here anyways???  It does maintain some compatibility
     *  with GroupingCollection2 and looks nice, but because it gets wiped out, 
     *  it won't handle any updates, so.....
     * 
     *  @param collection the collection to apply the default sort to
     *  @param depth the depth in the hierarchy that this collection represents
     *  @return the sort that got applied on the collection
     */
    protected function applyDefaultGroupingFieldSortToCollection(
        collection:ArrayCollection, depth:int):Sort
    {
        var groupingFieldLen:int = ((grouping && grouping.fields) ? grouping.fields.length : 0);
        
        // If no grouping or this collection represents the leaf collection 
        // (that holds the source items directly), no need to apply any sort
        if (groupingFieldLen == 0 || depth == groupingFieldLen - 1)
        {
            if (collection.sort)
            {
                collection.sort = null;
                collection.refresh();
            }
            
            return null;
        }
        
        // -1 depth is root (which holds items sorted by grouping.fields[0]
        var groupingField:GroupingField = grouping.fields[depth + 1];
        
        // apply a sort to the arraycollection to order them appropriately
        // TODO: can we use spark SortField and Sort...? 
        var sortField:SortField = new SortField(grouping.label, 
            groupingField.caseInsensitive, 
            groupingField.descending, groupingField.numeric);
        
        if (groupingField.compareFunction != null)
            sortField.compareFunction = groupingField.compareFunction;
        else if (grouping.compareFunction != null)
            sortField.compareFunction = grouping.compareFunction;
        
        var sort:Sort = new Sort();
        sort.fields = [sortField];
        
        collection.sort = sort;
        collection.refresh();
        
        return sort;
    }
    
    //-------------------------------------------------------------------------- 
    // 
    //  Methods: IHierarchicalCollectionView (though, FastGroupingCollection 
    //           doesn't implement the whole interface) 
    // 
    //-------------------------------------------------------------------------- 
    
    /** 
     *  Returns the parent of a node. 
     *  The parent of a top-level node is <code>null</code>. 
     * 
     *  @param node The Object that defines the node. 
     * 
     *  @return The parent node containing the node as child, 
     *  <code>null</code> for a top-level node, 
     *  and <code>undefined</code> if the parent cannot be determined. 
     */ 
    public function getParentItem(node:Object):* 
    { 
        // TODO (frishbry): is this the right API??  The root object is represented 
        // by an ArrayCollection directly, which is what getRoot() returns.  Because of that, 
        // getChildren() is overridden to deal with the root object... 
        var itemLookupObject:ItemLookupObject = itemToParentNode[node]; 
        
        if (itemLookupObject) 
            return itemLookupObject.node; 
        
        return null; 
    } 
    
    /** 
     *  @private 
     *  Overridden to deal with the root node and maxDepth 
     */ 
    override public function getChildren(node:Object):Object 
    { 
        if (maxDepth != -1 && getDepthOfNode(node) >= maxDepth) 
            return null;
        
        var isRoot:Boolean = (node is ArrayCollection);
        
        // the children for the root is the node (the ArrayCollection) directly 
        if (isRoot) 
            return node;
        
        return super.getChildren(node); 
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods: Summary Calculations
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Goes through the group nodes on the invalidation queues 
     *  (leafGroupsInNeedOfSummaryRecalculation, leafGroupsInNeedOfSummaryCopy, 
     *  internalGroupsInNeedOfSummaryRecalculation) and performs the appropriate 
     *  action.
     */
    protected function performRecalculateSummaries():void
    {
        if (!needToRecalculateSummaries)
            return;
        
        needToRecalculateSummaries = false;
        
        var leafGroupNode:Object;
        // first recalculate the leaf nodes...then go up by priority
        for (leafGroupNode in leafGroupsInNeedOfSummaryRecalculation)
        {
            calculateSummariesForLeafGroup(leafGroupNode);
        }
        
        // need to go through leaf groups and finish them off
        for (leafGroupNode in leafGroupsInNeedOfSummaryCopy)
        {
            finishCalculationForLeafGroup(leafGroupNode);
        }
        
        // always calculate bottom-up so top ones can take advantage of the fact that the bottom ones 
        // are computed
        var currentMaxPriority:int = internalGroupsInNeedOfSummaryRecalculation.getMaxPriority();
        var currentParentGroup:Object = internalGroupsInNeedOfSummaryRecalculation.removeLargest();
        while (currentParentGroup)
        {
            calculateSummariesForInternalGroup(currentParentGroup, currentMaxPriority);
            
            currentMaxPriority = internalGroupsInNeedOfSummaryRecalculation.getMaxPriority();
            currentParentGroup = internalGroupsInNeedOfSummaryRecalculation.removeLargest();
        }
        
        internalGroupsInNeedOfSummaryRecalculation.removeAll();
        leafGroupsInNeedOfSummaryCopy = new Dictionary();
        leafGroupsInNeedOfSummaryRecalculation = new Dictionary();
        
        // TODO (frishbry): either make this a public event or make a specific event for each item changing, 
        // where the item that changed can be gotten through event.relatedObject, so people can check for 
        // event.relatedObject == this || fgc.getChildren(event.relatedObject).contains(this) 
        dispatchEvent(new Event("summaryValueChanged"));
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods: Summary Calculations - leaf node calculations
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Completely calculate the summaries for the leaf node, including looping through 
     *  the items to calculate the values.
     */
    private function calculateSummariesForLeafGroup(node:Object):void
    {
        startCalculationForLeafGroup(node);
        
        var childrenCollection:ArrayCollection;
        
        // check to see if we are root or not (we are root if we are an ArrayCollection 
        // directly and don't have a real node)
        var isRoot:Boolean = (node is ArrayCollection);
        if (isRoot)
            childrenCollection = ArrayCollection(node);
        else
            childrenCollection = node[childrenField];
        
        var oldSummaryObjects:Array = objectSummaryMap[node];
        
        var len:int = childrenCollection.length;
        for (var i:int = 0; i < len; i++)
        {
            var item:Object = childrenCollection.getItemAt(i);
            
            // if it's a summary object, skip it
            if (oldSummaryObjects && oldSummaryObjects.indexOf(item) >= 0)
                continue;
            
            addDataObjectToLeafGroupSummary(node, item);
        }
        
        finishCalculationForLeafGroup(node);
    }
    
    /**
     *  @private
     *  Initialize summary for a leaf group
     */
    private function startCalculationForLeafGroup(node:Object):void
    {
        var leafNodeDepth:int = (grouping && grouping.fields ? grouping.fields.length : 0);
        var summaryFields:Array = summaryFieldsByDepth[leafNodeDepth];
        var summaryFieldsLen:int = summaryFields ? summaryFields.length : 0;
        
        for (var i:int = 0; i < summaryFieldsLen; i++)
        {
            var summaryField:SummaryField2 = summaryFields[i];
            var summaryCalculator:ISummaryCalculator;
            
            if (!(summaryField.summaryOperation is String) &&
                summaryField.summaryOperation is ISummaryCalculator)
                summaryCalculator = ISummaryCalculator(summaryField.summaryOperation);
            else
                summaryCalculator = DEFAULT_SUMMARY_CALCULATOR;
            
            var summaryObject:Object = summaryCalculator.summaryCalculationBegin(summaryField);
            populateSummary(node, summaryField, summaryObject, undefined);
        }
    }
    
    /**
     *  @private
     *  Add the values for a particular item to the leaf group's summaries
     */
    private function addDataObjectToLeafGroupSummary(group:Object, item:Object):void
    {
        var leafNodeDepth:int = (grouping && grouping.fields ? grouping.fields.length : 0);
        var summaryFields:Array = summaryFieldsByDepth[leafNodeDepth];
        var summaryFieldsLen:int = summaryFields ? summaryFields.length : 0;
        
        for (var i:int = 0; i < summaryFieldsLen; i++)
        {
            var summaryField:SummaryField2 = summaryFields[i];
            var summaryCalculator:ISummaryCalculator;
            
            if (!(summaryField.summaryOperation is String) &&
                summaryField.summaryOperation is ISummaryCalculator)
                summaryCalculator = ISummaryCalculator(summaryField.summaryOperation);
            else
                summaryCalculator = DEFAULT_SUMMARY_CALCULATOR;
            
            var summaryObjectHolder:SummaryObjectHolder = getSummaryObjectHolder(group, summaryField);
            var summaryObject:Object = summaryObjectHolder.summaryObject;
            summaryCalculator.calculateSummary(summaryObject, summaryField, item);
        }
    }
    
    /**
     *  @private
     *  Finish up the calculation for a particular leaf group
     */
    private function finishCalculationForLeafGroup(node:Object):void
    {
        var leafNodeDepth:int = (grouping && grouping.fields ? grouping.fields.length : 0);
        var summaryFields:Array = summaryFieldsByDepth[leafNodeDepth];
        var summaryFieldsLen:int = summaryFields ? summaryFields.length : 0;
        
        for (var i:int = 0; i < summaryFieldsLen; i++)
        {
            var summaryField:SummaryField2 = summaryFields[i];
            var summary:Object = 0.0;
            
            var summaryCalculator:ISummaryCalculator;
            
            if (!(summaryField.summaryOperation is String) &&
                summaryField.summaryOperation is ISummaryCalculator)
                summaryCalculator = ISummaryCalculator(summaryField.summaryOperation);
            else
                summaryCalculator = DEFAULT_SUMMARY_CALCULATOR;
            
            var summaryObjectHolder:SummaryObjectHolder = getSummaryObjectHolder(node, summaryField);
            var summaryObject:Object = summaryObjectHolder.summaryObject;
            
            if (summaryCalculator is ISummaryCalculator2) 
                summary = ISummaryCalculator2(summaryCalculator).returnSummary2(summaryObject, summaryField); 
            else 
                summary = summaryCalculator.returnSummary(summaryObject, summaryField);
            
            populateSummary(node, summaryField, summaryObject, summary);
        }
        
        var leafDepth:int = grouping && grouping.fields ? grouping.fields.length : 0;
        createAndInsertSummaryObjectIntoCollection(node, leafDepth);
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods: Summary Calculations - internal node calculations
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Calculate summaries for an internal node.  This means looping through all the 
     *  children groups and then using those to calculate the summary from.
     */
    private function calculateSummariesForInternalGroup(node:Object, depth:int):void
    {
        var summaryField:SummaryField2;
        var summaryCalculator:ISummaryCalculator;
        var summaryObject:Object;
        var summaryMap:Dictionary = new Dictionary(false);
        
        var childrenCollection:ArrayCollection;
        
        // check to see if we are root or not (we are root if we are an ArrayCollection 
        // directly and don't have a real node)
        var isRoot:Boolean = (node is ArrayCollection);
        if (isRoot)
            childrenCollection = ArrayCollection(node);
        else
            childrenCollection = node[childrenField];
        
        var oldSummaryObjects:Array = objectSummaryMap[node];
        
        var len:int = childrenCollection.length;
        var summaryFields:Array = summaryFieldsByDepth[depth];
        var summaryFieldsLen:int = summaryFields ? summaryFields.length : 0;
        
        if (summaryFieldsLen == 0 || len == 0)
            return;
        
        for (var i:int = 0; i < len; i++)
        {
            var item:Object = childrenCollection.getItemAt(i);
            
            // if it's a summary object, skip it
            if (oldSummaryObjects && oldSummaryObjects.indexOf(item) >= 0)
                continue;
            
            // for all summary fields
            for (var j:int = 0; j < summaryFieldsLen; j++)
            {
                summaryField = summaryFields[j];
                
                if (!(summaryField.summaryOperation is String) &&
                    summaryField.summaryOperation is ISummaryCalculator)
                    summaryCalculator = ISummaryCalculator(summaryField.summaryOperation);
                else
                    summaryCalculator = DEFAULT_SUMMARY_CALCULATOR;
                
                // grab summary object and extract the actual summary object out of it...just ignore the value
                // since the summary calculator can handle the summary object directly
                var childSummaryObjectHolder:SummaryObjectHolder = getSummaryObjectHolder(item, summaryField);
                var childSummaryObject:Object = childSummaryObjectHolder.summaryObject;
                
                // if the first one (it may be i == 0 or may not b/c of summary rows)
                if (!summaryMap[summaryField])
                {
                    summaryObject = 
                        summaryCalculator.summaryOfSummaryCalculationBegin(childSummaryObject, summaryField);
                    summaryMap[summaryField] = summaryObject;
                }
                else
                {
                    summaryObject = summaryMap[summaryField];
                    summaryCalculator.calculateSummaryOfSummary(summaryObject, 
                        childSummaryObject, summaryField);
                }
            }
        }
        
        // for all summary fields
        for (j = 0; j < summaryFieldsLen; j++)
        {
            summaryField = summaryFields[j];
            summaryObject = summaryMap[summaryField];
            
            if (!(summaryField.summaryOperation is String) &&
                summaryField.summaryOperation is ISummaryCalculator)
                summaryCalculator = ISummaryCalculator(summaryField.summaryOperation);
            else
                summaryCalculator = DEFAULT_SUMMARY_CALCULATOR;
            
            var summary:Object;
            if (summaryCalculator is ISummaryCalculator2) 
                summary = ISummaryCalculator2(summaryCalculator).returnSummaryOfSummary2(summaryObject, summaryField); 
            else 
                summary = summaryCalculator.returnSummaryOfSummary(summaryObject, summaryField);
            
            populateSummary(node, summaryField, summaryObject, summary);
        }
        
        createAndInsertSummaryObjectIntoCollection(node, depth);
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods: Summary Calculations - pushing summary to output and other basic admin
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Creates the appropriate summary object for the node, and inserts it into the 
     *  output ArrayCollection (or copies it into the group object, depending on summaryPlacement).
     */
    private function createAndInsertSummaryObjectIntoCollection(node:Object, depth:int):void
    {
        var summaries:Array = this.summaries;
        
        var isRoot:Boolean = (depth == 0); //(node is ArrayCollection);
        
        if (!isRoot)
        {
            // need to use depth - 1 since depth of 0 is root and depth of 1 is first group
            summaries = grouping.fields[depth - 1].summaries;
        }
        
        if (!summaries)
            return;
        
        var childrenCollection:ArrayCollection;
        
        // check to see if we are root or not (we are root if we are an ArrayCollection 
        // directly and don't have a real node)
        if (isRoot)
            childrenCollection = ArrayCollection(node);
        else
            childrenCollection = node[childrenField];
        
        // remove old summary objects first
        var oldSummaryObjects:Array = objectSummaryMap[node];
        if (oldSummaryObjects)
        {
            var oldSummaryObjectsLen:int = oldSummaryObjects.length;
            for (var k:int = 0; k < oldSummaryObjectsLen; k++)
            {
                var oldSummaryObject:Object = oldSummaryObjects[k];
                var oldSummaryIndex:int = childrenCollection.list.getItemIndex(oldSummaryObject);
                
                if (oldSummaryIndex >= 0)
                    childrenCollection.list.removeItemAt(oldSummaryIndex);
            }
        }
        
        // now go through and add the new ones
        var summaryObjects:Array = [];
        objectSummaryMap[node] = summaryObjects;
        
        var summariesLen:int = summaries.length;
        for (var i:int = 0; i < summariesLen; i++)
        {
            var summaryRow:SummaryRow = summaries[i];
            summaryObjects[i] = 
                summaryRow.summaryObjectFunction != null ? 
                summaryRow.summaryObjectFunction() : new SummaryObject();
            
            // for all summary fields
            var summaryRowFieldsLen:int = summaryRow.fields.length;
            for (var j:int = 0; j < summaryRowFieldsLen; j++)
            {
                var summaryField:SummaryField2 = summaryRow.fields[j];
                var label:String = getSummaryFieldLabel(summaryField);
                
                var summaryObjectHolder:SummaryObjectHolder = getSummaryObjectHolder(node, summaryField);
                
                if (summaryObjectHolder != null)
                {
                    // populate the summary object
                    summaryObjects[i][label] = summaryObjectHolder.summaryValue;
                }
            }
        }
        
        // insert the summary
        if (summariesLen > 0)
            copyCalculatedSummaryToCollection(node, summaryObjects, summaries);
    }
    
    /**
     *  Takes the actual SummaryObject and either push it into the output ArrayCollection or 
     *  copy the values into the group node, depending on summaryPlacement.
     */
    private function copyCalculatedSummaryToCollection(node:Object, summaryObj:Array, summaries:Array):void
    {
        var collectionToInsertInto:ArrayCollection;
        
        // check to see if we are root or not (we are root if we are an ArrayCollection 
        // directly and don't have a real node)
        var isRoot:Boolean = (node is ArrayCollection);
        if (isRoot)
            collectionToInsertInto = ArrayCollection(node);
        else
            collectionToInsertInto = node[childrenField];
        
        var len:int = summaries.length;
        for (var i:int = 0; i < len; i++)
        {
            var summaryRow:SummaryRow = summaries[i];
            
            // can't copy into the root node
            var copyIntoGroup:Boolean = (!isRoot && summaryRow.summaryPlacement.indexOf("group") != -1);
            var insertIntoFirst:Boolean = (summaryRow.summaryPlacement.indexOf("first") != -1);
            var insertIntoLast:Boolean = (summaryRow.summaryPlacement.indexOf("last") != -1);
            
            if (copyIntoGroup)
            {
                for (var p:String in summaryObj[i])
                    node[p] = summaryObj[i][p];
            }
            
            if (insertIntoFirst)
            {
                collectionToInsertInto.addItemAt(summaryObj[i], 0);
            }
            
            if (insertIntoLast)
            {
                collectionToInsertInto.addItem(summaryObj[i]);
            }
        }
    }
    
    /**
     *  @private
     *  Store the summary in a dictionary for later use.
     */
    private function populateSummary(node:Object, summaryField:SummaryField2, 
                                     summaryObject:Object, summaryValue:Object):void
    {
        if (summariesTracker == null)
            summariesTracker = new Dictionary(false);
        
        var uniqueSummaryFieldLabel:String = getSummaryFieldLabel(summaryField);
        
        if (summariesTracker[node] == undefined)
            summariesTracker[node] = new Dictionary(false);
        if (summariesTracker[node][uniqueSummaryFieldLabel] == undefined)
            summariesTracker[node][uniqueSummaryFieldLabel] = new Dictionary(false);
        
        var summaryObjectHolder:SummaryObjectHolder = new SummaryObjectHolder(summaryObject, summaryValue);
        summariesTracker[node][uniqueSummaryFieldLabel] = summaryObjectHolder;
    }
    
    /**
     *  @private
     *  Get the summary from the dictionary 
     */
    private function getSummaryObjectHolder(node:Object, summaryField:SummaryField2):SummaryObjectHolder
    {
        var uniqueSummaryFieldLabel:String = getSummaryFieldLabel(summaryField);
        
        if (summariesTracker == null || 
            summariesTracker[node] == undefined ||
            summariesTracker[node][uniqueSummaryFieldLabel] == undefined)
            return null;
        
        return summariesTracker[node][uniqueSummaryFieldLabel];
    }
    
    /** 
     *  Grabs the summary value.  
     * 
     *  <p>Node: As items change, this may not be updated immidiatly, but it 
     *  should update with the normal Flex validation lifecycle.  If you must have an up-to-date 
     *  value, you can extend FastGroupingCollection and call layoutManagerClientHelper.validateNow(). 
     *  Calling fastGroupingCollection.refresh() is absolutely not recommended for this purpose 
     *  as it can be super-expensive.</p>
     * 
     *  @param node The publicly exposed node to grab the summary for
     *  @param summaryField the summary field to grab the summary for
     *  @return the summary value for the particular summaryField and node
     */ 
    public function getSummaryValue(node:Object, summaryField:SummaryField2):Object 
    { 
        var summaryObjectHolder:SummaryObjectHolder = getSummaryObjectHolder(node, summaryField);
        
        if (summaryObjectHolder != null) 
        { 
            // populate the summary object 
            return summaryObjectHolder.summaryValue; 
        }
        
        return NaN; 
    }
    
    /**
     *  @private
     *  Get all the summary fields and store them in an Array
     *  Summaries that are required at the top-level must be computed at all
     *  levels below it.  Summaries that are required by the lower levels
     *  don't necessarily have to be computed by the groups above it.
     */
    private function prepareSummaryFields():void
    {
        summaryFieldsByDepth = new Dictionary();
        var summaryFields:Array;
        var sr:SummaryRow;
        
        // for root level summaries
        if (summaries != null)
        {
            summaryFields = [];
            summaryFieldsByDepth[0] = summaryFields;
            
            for (var i:int = 0; i < summaries.length; i++)
            {
                sr = summaries[i];
                if (sr.fields != null)
                {
                    for (j = 0; j < sr.fields.length; j++)
                    {
                        addSummaryField(summaryFields, sr.fields[j] as SummaryField2);
                        hasSummaryFields = true;
                    }
                }
            }
        }
        
        // for grouping fields summaries
        if (grouping && grouping.fields != null)
        {
            for (i = 0; i < grouping.fields.length; i++)
            {
                var gf:GroupingField = grouping.fields[i];
                if (gf.summaries != null)
                {
                    summaryFields = summaryFields ? summaryFields.concat() : [];
                    for (var j:int = 0; j < gf.summaries.length; j++)
                    {
                        sr = gf.summaries[j];
                        if (sr.fields != null)
                        {
                            for (var k:int = 0; k < sr.fields.length; k++)
                            {
                                addSummaryField(summaryFields, sr.fields[k] as SummaryField2);
                                hasSummaryFields = true;
                            }
                        }
                    }
                }
                
                summaryFieldsByDepth[i + 1] = summaryFields;
            }
        }
    }
    
    /**
     *  Adds a summary field to the array of already-existing summary fields.
     *  This method helps deal with duplicates appropriately.
     */
    private function addSummaryField(summaryFields:Array, newSummaryField:SummaryField2):void 
    { 
        var len:int = summaryFields.length; 
        var newSummaryFieldLabel:String = getSummaryFieldLabel(newSummaryField); 
        
        for (var i:int = 0; i < len; i++) 
        { 
            var oldSummaryField:SummaryField2 = summaryFields[i] as SummaryField2; 
            var oldSummaryFieldLabel:String =  getSummaryFieldLabel(oldSummaryField);
            
            if (newSummaryFieldLabel == oldSummaryFieldLabel) 
            { 
                // TODO (frishbry): should I do below...?
                // new summary field replaces summary field at this level 
                // summaryFields.splice(i, 1, newSummaryField); 
                return; 
            } 
        }
        
        summaryFields.push(newSummaryField); 
    }
    
    /**
     *  @private
     *  Returns the label and unique value for the summary field
     */
    private function getSummaryFieldLabel(summaryField:SummaryField2):String
    {
        return summaryField.label ? summaryField.label : summaryField.dataField;;
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods: Change Watchers
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Adds change watchers for the summary fields and grouping fields on 
     *  to a particular item
     */
    private function addChangeWatchersForItem(item:Object):void
    {
        var changeWatchersArray:Array;
        var cw:ChangeWatcher;
        var dataField:String;
        var isComplex:Boolean;
        
        var leafNodeDepth:int = (grouping && grouping.fields ? grouping.fields.length : 0);
        var summaryFields:Array = summaryFieldsByDepth[leafNodeDepth];
        var summaryFieldsLen:int = summaryFields ? summaryFields.length : 0;
        var summaryField:SummaryField2;
        
        for (var i:int = 0; i < summaryFieldsLen; i++)
        {
            if (!changeWatchersArray)
            {
                changeWatchersArray = [];
                itemToChangeWatchers[item] = changeWatchersArray;
            }
            
            summaryField = summaryFields[i];
            dataField = summaryField.dataField;
            
            if (dataField)
            {
                isComplex = (dataField.indexOf(".") >= 0);
                
                if (isComplex)
                {
                    cw = ChangeWatcher.watch(item, dataField.split("."), 
                        item_summaryField_changeWatcherHandlerForComplexItem(item));
                }
                else
                {
                    cw = ChangeWatcher.watch(item, dataField, 
                        item_summaryField_changeWatcherHandlerForSimpleItem);
                }
                
                changeWatchersArray.push(cw);
            }
        }
        
        var groupingFieldsLen:int = grouping && grouping.fields ? grouping.fields.length : 0;
        var groupingField:GroupingField;
        for (i = 0; i < groupingFieldsLen; i++)
        {
            if (!changeWatchersArray)
            {
                changeWatchersArray = [];
                itemToChangeWatchers[item] = changeWatchersArray;
            }
            
            groupingField = grouping.fields[i];
            dataField = groupingField.name;
            
            if (dataField)
            {
                isComplex = (dataField.indexOf(".") >= 0);
                
                if (isComplex)
                {
                    cw = ChangeWatcher.watch(item, dataField.split("."), 
                        item_groupingField_changeWatcherHandlerForComplexItem(item));
                }
                else
                {
                    cw = ChangeWatcher.watch(item, dataField, 
                        item_groupingField_changeWatcherHandlerForSimpleItem);
                }
                
                changeWatchersArray.push(cw);
            }
        }
    }
    
    /**
     *  Removes all change watchers installed by FastGroupingCollection
     */
    private function removeChangeWatchersForItem(item:Object):void
    {
        var changeWatchersArray:Array = itemToChangeWatchers[item];
        
        if (changeWatchersArray)
        {
            var cw:ChangeWatcher;
            var len:int = changeWatchersArray.length;
            for (var i:int = 0; i < len; i++)
            {
                cw = changeWatchersArray[i];
                cw.unwatch();
            }
            
            delete itemToChangeWatchers[item];
        }
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods and Overridden Methods: Max Depth support
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function canHaveChildren(node:Object):Boolean 
    { 
        if (super.canHaveChildren(node)) 
        { 
            if (maxDepth != -1 && getDepthOfNode(node) >= maxDepth) 
                return false;
            
            return true; 
        }
        
        return false; 
    }
    
    /**
     *  @private
     */
    override public function hasChildren(node:Object):Boolean 
    { 
        if (super.hasChildren(node)) 
        { 
            if (maxDepth != -1 && getDepthOfNode(node) >= maxDepth) 
                return false;
            
            return true; 
        }
        
        return false; 
    }
    
    /**
     *  Calculates the depth of a particular publicly exposed node. 
     *  
     *  <p>It returns -1 for the root collection, 0 for a node that is 
     *  at the top-level, 1 for a node that is one level deep, etc...</p>
     *  
     *  @param node the node to calculate the depth for
     *  @return the depth that the node is at in the tree
     */
    public function getDepthOfNode(node:Object):int 
    { 
        var currentDepth:int = -1;
        
        var currentNode:ItemLookupObject = itemToParentNode[node]; 
        while (currentNode) 
        { 
            currentDepth++; 
            currentNode = ItemLookupObject(itemToParentNode[currentNode.node]); 
        }
        
        return currentDepth; 
    }
    
    //--------------------------------------------------------------------------
    //
    // Overridden methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function getRoot():Object
    {
        // for our root, the node is actually an ArrayCollection
        return rootItemLookupObject.node;
    }
    
    //--------------------------------------------------------------------------
    //
    // Event Handlers
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Watch the source collection for changes
     */
    protected function sourceCollection_collectionChangeHandler(event:CollectionEvent):void
    {
        // if need to do a recalculation, then just ignore this, as it'll get 
        // handled later
        if (needToRecalculateGroups)
            return;
        
        var len:int;
        var i:int;
        var currentItem:Object;
        
        switch(event.kind)
        {
            case CollectionEventKind.ADD:
                len = event.items.length;
                for (i = 0; i < len; i++)
                {
                    currentItem = event.items[i];
                    
                    insertItemAndCreateGroups(currentItem);
                }
                break;
            case CollectionEventKind.REMOVE:
                len = event.items.length;
                for (i = 0; i < len; i++)
                {
                    currentItem = event.items[i];
                    
                    removeItemAndRemoveEmptyGroups(currentItem);
                }
                break;
            case CollectionEventKind.REPLACE:
                len = event.items.length;
                for (i = 0; i < len; i++)
                {
                    var updateInfo:PropertyChangeEvent = event.items[i];
                    var oldItem:Object = updateInfo.oldValue;
                    var newItem:Object = updateInfo.newValue;
                    
                    removeItemAndRemoveEmptyGroups(oldItem);
                    
                    insertItemAndCreateGroups(newItem);
                }
            case CollectionEventKind.REFRESH:
                // can be a filter, so need to just recalculate everything
            case CollectionEventKind.RESET:
                needToRecalculateGroups = true;
                layoutManagerClientHelper.invalidateProperties();
                break;
            case CollectionEventKind.UPDATE:
                // can ignore since using ChangeWatchers
                break;
            case CollectionEventKind.MOVE:
                // no need to do anything on move
            default:
                // do nothing
        }
    }
    
    // TODO (frishbry): for the event listeners below, closures can be expensive.
    // Should we just subclass ChangeWatchers and add the item property directly?
    
    /**
     *  Change watcher for when a grouping field property changes for a 
     *  particular item.  Use a closure here, so we can invalidate the correct item 
     *  on the itemsInNeedOfRegrouping list because when dealing with sub-items, we can't
     *  easily grab the parent item we are concerned with.
     */
    private function item_groupingField_changeWatcherHandlerForComplexItem(item:Object):Function
    {
        return function(event:Event):void
        {
            handleGroupingFieldChangeForItem(item);
        }
    }
    
    private function handleGroupingFieldChangeForItem(item:Object):void
    {
        if (needToRecalculateGroups)
            return;
        
        if (!itemsInNeedOfRegrouping)
            itemsInNeedOfRegrouping = new Dictionary();
        
        itemsInNeedOfRegrouping[item] = true; // might not be real item but besubitem
        layoutManagerClientHelper.invalidateProperties();
    }
    
    private function item_groupingField_changeWatcherHandlerForSimpleItem(event:Event):void
    {
        handleGroupingFieldChangeForItem(event.target);
    }
    
    /**
     *  Change watcher for when a summary field property changes for a 
     *  particular item.
     */
    private function item_summaryField_changeWatcherHandlerForComplexItem(item:Object):Function
    {
        return function(event:Event):void
        {
            handleSummaryFieldChangeForItem(item);
        }
    }
    
    private function item_summaryField_changeWatcherHandlerForSimpleItem(event:Event):void
    {
        handleSummaryFieldChangeForItem(event.target);
    }
    
    private function handleSummaryFieldChangeForItem(item:Object):void
    {
        if (needToRecalculateGroups)
            return;
        
        var currentItemLookupObject:ItemLookupObject = itemToParentNode[item];
        var currentNode:Object;
        var groupingFieldsLen:int = grouping && grouping.fields ? grouping.fields.length : 0;
        var currentDepth:int = groupingFieldsLen;
        
        while (currentItemLookupObject != null)
        {
            currentNode = currentItemLookupObject.node;
            
            // i == groupingFieldsLen is leafGroup
            // i == groupingFieldsLen - 1 is first internal group
            // i == 0 is root
            // i == 1 is first group
            if (currentDepth == groupingFieldsLen)
                leafGroupsInNeedOfSummaryRecalculation[currentNode] = true;
            else
                internalGroupsInNeedOfSummaryRecalculation.addObject(currentNode, currentDepth);
            
            currentItemLookupObject = itemToParentNode[currentNode];
            currentDepth--;
        }
        
        needToRecalculateSummaries = true;
        layoutManagerClientHelper.invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods for event dispatching
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Enables event dispatch for this list.
     */
    private function enableEvents():void
    {
        _dispatchEvents++;
        if (_dispatchEvents > 0)
            _dispatchEvents = 0;
    }
    
    /**
     *  Disables event dispatch for this list.
     *  To re-enable events call enableEvents(), enableEvents() must be called
     *  a matching number of times as disableEvents().
     */
    private function disableEvents():void
    {
        _dispatchEvents--;
    }
    
    /**
     *  Dispatches a collection event with the specified information.
     *
     *  @param kind String indicates what the kind property of the event should be
     *  @param item Object reference to the item that was added or removed
     *  @param location int indicating where in the source the item was added.
     */
    private function internalDispatchEvent(kind:String, item:Object = null, location:int = -1):void
    {
        if (_dispatchEvents == 0)
        {
            if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
            {
                var event:CollectionEvent =
                    new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
                event.kind = kind;
                event.items.push(item);
                event.location = location;
                dispatchEvent(event);
            }
            
            // now dispatch a complementary PropertyChangeEvent
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE) && 
                (kind == CollectionEventKind.ADD || kind == CollectionEventKind.REMOVE))
            {
                var objEvent:PropertyChangeEvent =
                    new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
                objEvent.property = location;
                if (kind == CollectionEventKind.ADD)
                    objEvent.newValue = item;
                else
                    objEvent.oldValue = item;
                dispatchEvent(objEvent);
            }
        }
    }
}
}

import flash.utils.Dictionary;

/**
 *  Helper class to hold the publicly exposed node and a children 
 *  dictionary that helps do O(1) lookups
 */
class ItemLookupObject
{
    public var node:Object;
    public var childrenToItemLookup:Dictionary = new Dictionary();
}

/**
 *  Helper class to hold summary data for the grouping collection
 */
class SummaryObjectHolder
{
    public function SummaryObjectHolder(summaryObject:Object, summaryValue:Object)
    {
        super();
        
        this.summaryObject = summaryObject;
        this.summaryValue = summaryValue;
    }
    
    /**
     *  The "summary object" used by ISummaryCalculator
     */
    public var summaryObject:Object;
    
    /**
     *  The output summary value
     */
    public var summaryValue:Object;
}