////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;

import mx.collections.ArrayList;
import mx.collections.IList;
import mx.core.EventPriority;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IIMESupport;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.managers.IFocusManagerComponent;
import mx.styles.IAdvancedStyleClient;

import spark.components.calendarClasses.DateChooserSelectionMode;
import spark.components.calendarClasses.DateRange;
import spark.components.calendarClasses.DateSelection;
import spark.components.calendarClasses.DateSet;
import spark.components.calendarClasses.DateUtil;
import spark.components.calendarClasses.IDateItemRenderer;
import spark.components.calendarClasses.MonthArrayList;
import spark.components.calendarClasses.SixWeekLayoutMode;
import spark.components.calendarClasses.WeekOrientation;
import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.DropDownListBase;
import spark.components.supportClasses.GroupBase;
import spark.core.NavigationUnit;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.Linear;
import spark.events.DateChooserEvent;
import spark.events.DropDownEvent;
import spark.events.IndexChangeEvent;
import spark.events.MonthGridEvent;
import spark.events.RendererExistenceEvent;
import spark.formatters.DateTimeFormatter;
import spark.globalization.supportClasses.CalendarDate;
import spark.globalization.supportClasses.DateTimeFormatterEx;
import spark.layouts.HorizontalLayout;
import spark.layouts.TileLayout;
import spark.layouts.supportClasses.LayoutBase;
import spark.skins.spark.MonthGridItemRenderer;

use namespace mx_internal;
    
//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the caret position, or
 *  visibility has changed due to user interaction or being programmatically set.
 *  Use <code>caretDate</code> to determine the position of the caret.
 *
 *  @eventType spark.events.DateChooserEvent.CARET_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Event(name="caretChange", type="spark.events.DateChooserEvent")]

/**
 *  Dispatched when the months are finished animating.
 *  If no animation occurred, this event will not be dispatched.
 *
 *  @eventType mx.events.FlexEvent.CHANGE_END
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Event(name="changeEnd", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the month or year changes due to user interaction.
 *  Use <code>displayedDate</code> to determine which month is being displayed.
 *
 *  @eventType spark.events.DateChooserEvent.MONTH_SCROLL
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Event(name="monthScroll", type="spark.events.DateChooserEvent")]

/**
 *  Dispatched when the selection has changed. 
 *  
 *  <p>This event is dispatched when the user interacts with the control.
 *  When you change the selection programmatically, 
 *  the component does not dispatch the <code>selectionChange</code> event. 
 *  In either case it dispatches the <code>valueCommit</code> event as well.</p>
 *
 *  @eventType spark.events.DateChooserEvent.SELECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Event(name="selectionChange", type="spark.events.DateChooserEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicInheritingTextStyles.as"

/**
 *  The alpha value of the border for this component.
 *  Valid values are 0.0 to 1.0. 
 *
 *  @default 1.0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="borderAlpha", type="Number", inherit="no", theme="spark", minValue="0.0", maxValue="1.0")]

/**
 *  The color of the border for this component.
 *
 *  @default #696969
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
//[Style(name="borderColor", type="uint", format="Color", inherit="no", theme="spark")]

/**
 *  Controls the visibility of the border for this component.
 *
 *  @default true
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="borderVisible", type="Boolean", inherit="no", theme="spark")]

/**
 *  Color of the caret indicator when navigating thru the days of the month.
 *
 *  @default 0x0167FF
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="caretColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:chromeColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="chromeColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  The alpha of the content background for this component.
 *  Valid values are 0.0 to 1.0. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark", minValue="0.0", maxValue="1.0")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *   
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Number of milliseconds between scroll events
 *  if the user presses and holds the next month or previous month buttons in the header.
 *  
 *  @default 400
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="repeatInterval", type="Number", format="Time", inherit="no", minValueExclusive="0.0")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:rollOverColor
 *   
 *  @default 0xCEDBEF
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.List#style:selectionColor
 *
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="selectionColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 * This style determines whether the month display will animate
 * smoothly when stepping thru the months. When false, step
 * operations will jump directly to the stepped location. 
 * When true, the month display will animate to that location.
 *  
 *  @default true
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="smoothScrolling", type="Boolean", inherit="no")]


/**
 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
 *   
 *  @default 0x000000
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Color of the background of today's date in the calendar.
 * 
 *  @default 0xF9EB21
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Style(name="todayColor", type="uint", format="Color", inherit="yes")]


//--------------------------------------
//  Excluded APIs
//--------------------------------------

//--------------------------------------
//  Other metadata
//--------------------------------------

//[AccessibilityClass(implementation="spark.accessibility.DateChooserImpl")]

[DefaultProperty("displayedDate")]

[DefaultTriggerEvent("selectionChange")]
        
//[IconFile("DateChooser.png")]

// FIXME: timezone issues - generate dates with time in mid-day to get around DST issues
// FIXME: embedded fonts, getting styles down to renderers
// FIXME: update this with what is in the spec
/**
 *  DateChooser is a Spark component that displays a scrollable list of Gregorian calendar months 
 *  using a familiar calendar-style layout. 
 *  By default the current month is displayed and one date (year, month and day) may be selected. 
 *  Much like the Spark DataGrid, it is skinnable and highly customizable.
 *
 *  The DateChooser displays in the header, next/previous month navigation buttons and the name of 
 *  the month and the year, and in the body, a grid of the days of the month labeled with the days 
 *  of the week. 
 *  Depending on the value of the <code>weekOrientation<coode> property, the reading order of the 
 *  body is either by rows, each week in a row, or by columns, with each week in a column.
 * 
 *  The header displays the name of the month and year being displayed.
 *  It can also be used for direct navigation to any month and year which is between
 *  the selectableDate <code>minDate</code> and selectableDate <code>maxDate<code>.
 *  The month control, <code>monthDropDownList</code> is a drop-down list which contains the list 
 *  of all navigable months for the given year.
 *  You can specify the format of the month name using the <code>monthNameFormatter</code> so that 
 *  it can be formatted in a locale-aware manner.
 *  The year control, <code>yearDropDownListBase</code> when clicked, will display a text input 
 *  control which allows you to enter a year directly.
 *  The monthDropDownList control and the yearDropDownListBase control are placed relative to each 
 *  other based on the locale.
 *  The parts must have the same parent and be in a group controlled 
 *  by a layout that does relative positioning, such as a <code>HorizontalLayout</code>.
 *  The forward and back arrow buttons can be used for scrolling to the 
 *  previous and next month. 
 *  Depending on the value of the <code>smoothScrolling</code> style, the month transition
 *  will be animated or jump directly to the new month.
 * 
 *  The DateChooser skin is responsible for laying out the header, grid of days in the month, 
 *  and scroller and for configuring the graphic elements used to render visual elements used as 
 *  indicators, separators, and backgrounds. 
 *  The DateChooser skin can also specify the default day of the week formatter and day of the 
 *  week renderer, and the default day of the month formatter and default day of the month renderer. 
 *  Although typically they contain text, the cells in the grid may contain any Flex visual 
 *  components.
 *
 *  There are several properties that allow you to easily customize what days are displayed.
 *  For example, you can specify that a fixed number of weeks be used for every month, that
 *  days from the previous and next month are displayed if they fit, and that if there is an
 *  entire week of extra days they are displayed at the end of the month.
 *  You can also customize the <code>MonthGridItemRenderer</code> if you would like
 *  more control over the layout of the month display.
 *
 *  Users can specify the set of selectable dates in several different ways, using a
 *  <code>DateSet</code> so they can choose the way that works best for their application.
 *  Only dates which are in the <code>selectableDate</code> set can be selected interactively.
 *  By default all dates are selectable.
 *  Using the mouse or the keyboard, depending on the <coe>selectionMode</code> the user can select 
 *  a single date, a range of consecutive dates, or multiple disjoint dates, providing those 
 *  dates are in the set of selectable dates.
 *  
 *  Users can use the keyboard to navigate within the month being displayed, between
 *  the months and within the header.  
 *  The keyboard can also be used for selection.
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;spark:DateChooser&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;spark:DateChooser
 *    FIXME
 *    <strong>Properties</strong>
 *    caretDate="null"
 *    displayedDate="<i>Current year, month and day</i>"
 *    displayedDates="<i>one Date which is <i>Current year, month and day</i>"
 *    displayMode="date"
 *    imeMode="none"
 *    monthNameFormatter="yMMMM"
 *    selectableDates="null"
 *    selectedDate="null"
 *    selectedDates="null"
 *    selectionMode="singleDate"
 *    showDaysInOtherMonths="true"
 *    showTodayIndicator="true"
 *    sixWeekLayoutMode="extraWeekAfter"
 *    typicalDate="null"
 *    weekOrientation="rows"
 * 
 *    <strong>Styles</strong>
 *    FIXME
 * 
 *    <strong>Skin Parts</strong>
 *    FIXME
 * 
 *    <strong>Events</strong>
 *    caretChange="<i>No default</i>"
 *    changeEnd="<i>No default</i>"
 *    monthYearChange="<i>No default</i>"
 *    selectionChange="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.DateField
 *
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
public class DateChooser extends SkinnableDataContainer 
    implements IFocusManagerComponent, IIMESupport
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Placeholder for mixin by DateSetAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;
    
    //--------------------------------------------------------------------------
    //
    //  Class initialization
    //
    //--------------------------------------------------------------------------
            

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    // PARB doesn't want MIN_DATE_DEFAULT/MAX_DATE_DEFAULT public.  
    // Currently DateSet, DateRange and MonthArrayList reference them.  
    // These classes should be standalone and not have references to the DateChooser class.
    // FIXME: replace references to constants in ASdoc with the strings they represent.
    
    /**
     *  @private
     *  The default minDate that can be selected or displayed.
     */ 
    mx_internal static const MIN_DATE_DEFAULT:Date = new Date(1900, 0, 1);
    
    /**
     *  @private
     *  The default maxDate that can be selected or displayed.
     */ 
    mx_internal static const MAX_DATE_DEFAULT:Date = new Date(2100, 11, 31, 23, 59, 59, 999);

    /**
     *  @private
     *  The earliest month and year that can be selected or displayed.
     */ 
    mx_internal static const MIN_DATE:Date = new Date(DateTimeFormatterEx.MIN_YEAR, 0, 1);
    
    /**
     *  @private
     *  The latest month and year that can be selected or displayed.
     */ 
    mx_internal static const MAX_DATE:Date = new Date(9999, 11, 31, 23, 59, 59, 999);

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function DateChooser()
    {
        super();
                
        const now:Date = new Date();
        displayedMonth = now.month;
        displayedYear = now.fullYear;
        
        monthYearPositionFormatter = new DateTimeFormatterEx();
        DateTimeFormatterEx(monthYearPositionFormatter).dateTimeSkeletonPattern = 
            DateTimeFormatterEx.DATESTYLE_yMMMM;

        // Hook the formatter into the style chain so it will be notified if locale changes.
        const asc:IAdvancedStyleClient = monthYearPositionFormatter as IAdvancedStyleClient;
        if (asc && (asc.styleParent != this))
            addStyleClient(asc);            
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    // Selection drag state variables.
    private var pendingAnchorDate:Date;    
    private var dragInProgress:Boolean = false;
    
    /**
     *  This is set whenever one of the properties which "covers" a property in the monthGrid
     *  is changed.  In commitProperties, if set, this will update each visible monthGrid
     *  renderer.  It is not necessary for renderers which aren't visible since they are
     *  re-initialized when they become visible.
     */ 
    private var monthGridPropertyChanged:Boolean;
    
    /**
     *  If not all the months are in the month drop-down list we need a way to map the name of the
     *  month to the month index.  The index in the drop-down list won't work.  At least for
     *  Gregorian calendars, if there are 12 months in the drop-down list we can use the
     *  selectedIndex directly.
     */
    private var monthNames:Vector.<String>;
    
    /**
     * @private
     * Used for the monthScroll animations. It is responsible for running the operation 
     * (animating from the beginning to whenever it ends or the user stops the action).
     */
    private var _animateScrollPosition:Animate = null;
    
    /**
     *  If the locale changes, we have to wait for the formatters to update before reformatting
     *  the headers.  They update after our styleChanged is called when the children are notified.
     */
    private var localeChanged:Boolean;
    
    /**
     *  @private
     *  Note: PARB removed this from the public API.
     * 
     *  If true, the monthDropDrowList and yearDropDownListBase skin parts will be positioned
     *  appropriately for the locale by swapping them so that they are in the correct
     *  relative position.
     */ 
    mx_internal var adjustHeaderForLocale:Boolean = true;
    
    /**
     *  @private
     *  Note: PARB removed this from the public API.
     * 
     *  Formatter to use to determine the relative position of the month and the year header parts. 
     **/
    //mx_internal var headerPartsFormatter:DateTimeFormatterEx = new DateTimeFormatterEx();
    mx_internal var monthYearPositionFormatter:DateTimeFormatterEx = new DateTimeFormatterEx();
        
    /**
     *  @private
     *  If the month and year headers are swapped, these save their original indexes so
     *  they can be restored.
     **/
    private var initialMonthPositionIndex :int = -1;
    private var initialYearPositionIndex:int = -1;
    

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private 
     *  IFactory valued skin parts that require special handling, see findSkinParts().
     */
    private static const factorySkinPartNames:Array = [
        "caretIndicator",
        "columnSeparator",
        "hoverIndicator",
        "rowSeparator",
        "hoverIndicator",
        "selectionIndicator",
        "todayIndicator",
        "weekOrientationRowsLayout",
        "weekOrientationColumnsLayout"];
    
    //----------------------------------
    //  caretIndicator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     *  The IVisualElement class used to render the caret indicator in the date chooser.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var caretIndicator:IFactory;
    
    //----------------------------------
    //  columnSeparator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     *  The IVisualElement class used to render the vertical separator between columns in the
     *  date chooser. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var columnSeparator:IFactory;
                
    //----------------------------------
    //  hoverIndicator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     *  The IVisualElement class used to provide hover feedback in the 
     *  the date chooser.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var hoverIndicator:IFactory;
    
    //----------------------------------
    //  monthDropDownList
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    
    /**
     *  A reference to the drop-down list that displays the name of the month that is displayed.
     *  The list contains the names of the months that are within the range of 
     *  <code>selectableDates</code> <code>minDate<code> and <code>maxDate</code> for the 
     *  given year.
     *  If you select a different month, the month displayed will change to the that month
     *  within the current year.
     * 
     *  <p>The month and year will be ordered correctly for the locale.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var monthDropDownList:DropDownListBase; 
    
    //----------------------------------
    //  nextMonthButton
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    
    /**
     *  A reference to the Button that is pressed to display month + 1 in the date chooser.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var nextMonthButton:ButtonBase;   
            
    //----------------------------------
    //  previousMonthButton
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    
    /**
     *  A reference to the Button that is pressed to display month - 1 in the date chooser.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var previousMonthButton:ButtonBase;   
        
    //----------------------------------
    //  rowSeparator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     *  The IVisualElement class used to render the horizontal separator between the rows
     *  in the date chooser.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var rowSeparator:IFactory;
    
    //----------------------------------
    //  scroller
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    
    /**
     *  A reference to the Scroller control in the skin class that wraps the DataGroup.
     *  It is used to transition the month when navigating between the months.
     *  The scroll bars should not be enabled.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var scroller:Scroller;    
    
    //----------------------------------
    //  selectionIndicator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     *  The IVisualElement class used to render selected days in the date chooser.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
    */
    public var selectionIndicator:IFactory;
    
    //----------------------------------
    //  weekOrientationRowsLayout
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     *  The IVisualElement class used for the dataGroup layout when weekOrientation="rows".
     *  This must be specified if weekOrientation="rows".
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var weekOrientationRowsLayout:IFactory;
    
    //----------------------------------
    //  weekOrientationColumnsLayout
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     *  The IVisualElement class used for the dataGroup layout when weekOrientation="columns".
     *  This must be specified if weekOrientation="columns".
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var weekOrientationColumnsLayout:IFactory;
    
    //----------------------------------
    //  todayIndicator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IVisualElement")]
    
    /**
     *  The IVisualElement class used to render today in the date chooser.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var todayIndicator:IFactory;
     
    //----------------------------------
    //  yearDropDownListBase
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    
    /**
     *  A reference to the control that displays the year of the displayed month.
     * 
     *  <p>If you enter a new year which puts the month and year between
     *  the selectableDate <code>minDate</code> and selectableDate <code>maxDate<code>.
     *  the month displayed will change to the same month of the new year.
     *  Otherwise, the prior value of this field will remain.
     * 
     *  <p>The month and year will be ordered correctly for the locale.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public var yearDropDownListBase:DropDownListBase; 
        
    //--------------------------------------------------------------------------
    //
    //  Skin Part Property Internals
    //
    //-------------------------------------------------------------------------- 
            
    /**
     *  @private
     *  This var is an object whose properties temporarily record the values of DateChooser 
     *  properties that just "cover" monthGrid properties.  commitProperties() will look
     *  for all visible monthGrids and push the updated values down to them. If a monthGrid
     *  isn't visible it will be updated later before it is made visible so it will get the
     *  updates at that time.
     */
//    private var monthGridProperties:Object = {};
//            
//    private function setMonthGridProperty(propertyName:String, value:*):void
//    {
//        monthGridProperties[propertyName] = value;
//    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------
    
    // FIXME - what goes here
        
    //----------------------------------
    //  dataProvider
    //----------------------------------    
    
    /**
     *  @private
     */
    override public function set dataProvider(value:IList):void
    {
        // FIXME: need correct error message
        if (!(value is MonthArrayList))
            throw(new Error(resourceManager.getString("components", "layoutReadOnly")));            
        
        super.dataProvider = value;
        
        invalidateSize();
        // FIXME: are the renderers all thrown away
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    // FIXME: is this needed and if so why?
    
    private var _enabled:Boolean = true;
    
    /**
     *  @private
     */
    private var enabledChanged:Boolean = false;
    
    [Bindable("enabledChanged")]
    [Inspectable(category="General", enumeration="true,false", defaultValue="true")]
    
    /**
     *  @private
     */
    override public function get enabled():Boolean
    {
        return _enabled;
    }
    
    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        if (value == _enabled)
            return;
        
        _enabled = value;
        super.enabled = value;
        enabledChanged = true;
        
        invalidateProperties();
    }
        
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  anchorDate
    //----------------------------------
    
    private var _anchorDate:Date;
    private var anchorDateChanged:Boolean;
    
    [Bindable("anchorDateChanged")]
    
    /**
     *  The date of the <i>anchor</i> for the next shift selection.
     *  The anchor is the date most recently selected. 
     *  It defines the anchor date when selecting multiple dates in the month. 
     *  When you select multiple dates, the set of dates extends from 
     *  the anchor to the caret date.
     *
     *  <p>Setting <code>anchorDate</code> to <code>null</code> means that anchor 
     *  is undefined.</p>
     *
     *  @default null
     * 
     *  @see spark.components.#caretDate
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get anchorDate():Date
    {
        return _anchorDate ? new Date(_anchorDate.time) : null;
    }
    
    /**
     *  @private
     */
    public function set anchorDate(value:Date):void
    {
        if (DateUtil.datesEqual(value, _anchorDate))
            return;
        
        _anchorDate = value ? new Date(value.time) : null;
        anchorDateChanged = true;
    }
    
    //----------------------------------
    //  caretDate   
    //----------------------------------
    
    // FIXME: for accessibility should there be an initial value?
    
    private var _caretDate:Date;
    private var caretDateChanged:Boolean;
    
    [Bindable("caretChange")]
    
    /**
     *  The date indicated by the caret.
     *  Keyboard selection uses the caret.
     * 
     *  <p>Setting <code>caretDate</code> to <code>null</code> means that caret 
     *  is undefined and the caret will not be shown.</p>
     * 
     *  @default null
     * 
     *  @see spark.components.#anchorDate
     *  @see spark.components.#caretIndicator
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0 
     */
    public function get caretDate():Date
    {
        return _caretDate ? new Date(_caretDate.time) : null;
    }
    
    /**
     *  @private
     */
    public function set caretDate(value:Date):void
    {
        if (DateUtil.datesEqual(value, _caretDate))
            return;
        
        _caretDate = value ? new Date(value.time) : null;
        caretDateChanged = true;
        invalidateProperties();
        invalidateMonthGridDisplayListFor("caretIndicator");
    }
    
    //----------------------------------
    //  dateSelection (private)
    //----------------------------------    
    
    private var _dateSelection:DateSelection = null;
    
    /**
     *  @private
     *  This keeps track of the keyboard and mouse selection. 
     *  It also object becomes the monthGrid's dateSelection property after the monthGrid renderer 
     *  becomes visible so that the monthGrid layout can determine what days are selectable.
     */
    public function get dateSelection():DateSelection
    {
        if (!_dateSelection)
            _dateSelection = new DateSelection();
        return _dateSelection;
    }
    
    //----------------------------------
    //  displayedDate
    //----------------------------------
    
    // PARB split into displayedMonth and displayedYear.
    
    //----------------------------------
    //  displayedDates
    //----------------------------------
    
    // Removed by PARB since only one month is current supported.
    
    //----------------------------------
    //  displayedMonth
    //----------------------------------
     
    private var _displayedMonth:int;
    private var displayedMonthChanged:Boolean = true;
    
    [Bindable("displayedMonthChanged")]
    [Bindable("monthYearChange")]
    [Inspectable(category="General")]
    
    /**
     *  Specifies the month that will be displayed.  The Gregorian months are numbers 0-11.
     *  Setting this property may change the appearance of the component.
     *  
     *  @default "current month"
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get displayedMonth():int
    {
        return _displayedMonth;
    }
    
    /**
     *  @private
     */
    public function set displayedMonth(value:int):void
    {
        if (value == _displayedMonth)
            return;
                        
        _displayedMonth = value;
        displayedMonthChanged = true;
        
        // NOTE:
        // The displayed month and year in the monthGrid is changed by scrolling the dataGroup
        // to the approriate renderer, not by setting the properties directly in monthGrid.
        
        invalidateProperties();
        invalidateDisplayList(); 
        
        dispatchChangeEvent("displayedMonthChanged");
    }
   
    //----------------------------------
    //  displayedYear
    //----------------------------------
    
    private var _displayedYear:int;
    private var displayedYearChanged:Boolean = true;
    
    [Bindable("displayedYearChanged")]
    [Bindable("monthYearChange")]
    [Inspectable(category="General")]
    
    /**
     *  Specifies the year in the Gregorian calendar that will be displayed.
     *  Setting this property may change the appearance of the component.
     *  
     *  @default "current year"
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get displayedYear():int
    {
        return _displayedYear;
    }
    
    /**
     *  @private
     */
    public function set displayedYear(value:int):void
    {
        if (value == _displayedYear)
            return;
        
        
        _displayedYear = value
        displayedYearChanged = true;
        
        // NOTE:
        // The displayed month and year in the monthGrid is changed by scrolling the dataGroup
        // to the approriate renderer, not by setting the properties directly in monthGrid.
                
        invalidateProperties();
        invalidateDisplayList(); 
        
        dispatchChangeEvent("displayedYearChanged");
    }
    
    //----------------------------------
    //  enableIME
    //----------------------------------
    
    /**
     *  A flag that indicates whether the IME should
     *  be enabled when the component receives focus.
     *
     *  @return false.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get enableIME():Boolean
    {
        if (yearDropDownListBase && yearDropDownListBase is ComboBox)
            return ComboBox(yearDropDownListBase).enableIME;
        
        return false;
    }
   
    //----------------------------------
    //  hoverDate   
    //----------------------------------
        
    private var _hoverDate:Date = null;
    //private var hoverDateChanged:Boolean;
    
    [Bindable("hoverDateChanged")]
    
    /**
     *  The date indicated by the hover indicator.
     * 
     *  <p>Setting <code>hoverDate</code> to <code>null</code> means that hover indicator
     *  will not be shown.</p>
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0 
     */
    public function get hoverDate():Date
    {
        return _hoverDate ? new Date(_hoverDate.time) : null;
    }
    
    /**
     *  @private
     */
    public function set hoverDate(value:Date):void
    {
        if (DateUtil.datesEqual(value, _hoverDate))
            return;
        
        _hoverDate = value ? new Date(value.time) : null;
        //hoverDateChanged = true;
        
        invalidateMonthGridDisplayListFor("hoverIndicator");
    }
    
    //----------------------------------
    //  imeMode
    //----------------------------------
    
    private var _imeMode:String = null;
    
    [Inspectable(environment="none")]
    
    /**
     *  @inheritDoc
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function get imeMode():String
    {
        return _imeMode;
    }
    
    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        _imeMode = value;
    }
    
    //----------------------------------
    //  monthGrid (private)
    //----------------------------------
    
    /**
     *  This assumes the first visible month is the month we're dealing with.  This may have to
     *  change when monthCount > 1 is supported.
     */ 
    mx_internal function get monthGrid():MonthGrid
    {
        return getFirstMonthGridInView();
    }
    
    //----------------------------------
    //  monthNameFormatter
    //----------------------------------
    
    private var _monthNameFormatter:DateTimeFormatter = null;
    
    [Bindable("monthNameFormatterChanged")]
    
    /**
     *  The formatter used to formatting the month names in the monthDropDownList.
     * 
     *  @default "<i>default for Spark DateTimeFormatter</i>"
     * 
     *  @see spark.formatters.DateTimeFormatter#dateTimePattern
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get monthNameFormatter():DateTimeFormatter
    {
        // Default is "EEEE, MMMM dd, yyyy h:mm:ss a" which means full month.
        if (_monthNameFormatter == null)
        {
            _monthNameFormatter = new DateTimeFormatter();
            
            // Hook it into the style subsystem so it will be notified of locale changes.
            const asc:IAdvancedStyleClient = _monthNameFormatter as IAdvancedStyleClient;
            if (asc && (asc.styleParent != this))
                addStyleClient(asc);                        
        }
        
        return _monthNameFormatter;
    }
    
    /**
     *  @private
     */
    public function set monthNameFormatter(value:spark.formatters.DateTimeFormatter):void
    {
        if (_monthNameFormatter == value)
            return;

        // If there was a formatter, unhook it from the style subsystem.
        const oldASC:IAdvancedStyleClient = _monthNameFormatter as IAdvancedStyleClient;
        if (oldASC && (oldASC.styleParent == this))
            removeStyleClient(oldASC);

        _monthNameFormatter = value;
        
        // If there is a new formatter, hook it into the style subsystem so it will be notified
        // if the locale changes.
        const asc:IAdvancedStyleClient = _monthNameFormatter as IAdvancedStyleClient;
        if (asc && (asc.styleParent != this))
            addStyleClient(asc);            
                        
        dispatchChangeEvent("monthNameFormatterChanged");
    }    
    
    //----------------------------------
    //  selectableDates
    //----------------------------------
    
    private var _selectableDates:DateSet = new DateSet();
    private var selectableDatesChanged:Boolean;
    
    [Bindable("selectableDatesChanged")]
    
    /**
     *  Specifies the set of dates which are selectable in the date chooser via user interaction.  
     *  If this is not specified, all dates between <code>DateChooser.MIN_DATE</code> and 
     *  <code>DateChooser.MAX_DATE</code> are selectable. 
     *  Only the day, month and fullYear properties of each <code>Date</code> is relevant.  
     *  The time properties of each selectable date are ignored.
     * 
     *  <p>This set of dates applies to all interactive selections which are done after this is set.
     *  If the set of selectable dates is changed after any dates have been selected, the
     *  selection will remain, even if one or more of the dates in the selection are no longer in 
     *  the set of selectable dates.</p>
     * 
     *  <p>In order to navigate to a particular month, its month and year must be between the 
     *  <code>minxDate</code> and <code>maxDate</code> properties of selectable dates.</p>
     *
     *  @default "all dates between DateChooser.MIN_DATE and DateChooser.MAX_DATE"
     *  
     *  @see spark.components.calendarClasses.DateSet
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get selectableDates():DateSet
    {
        return _selectableDates;
    }
    
    /**
     *  @private
     */
    public function set selectableDates(value:DateSet):void
    {
        if (value == null)
            value = new DateSet();
        
        // FIXME: clone this?
        _selectableDates = value;
        selectableDatesChanged = true;
                
//        setMonthGridProperty("selectableDates", value);
//        monthGridPropertyChanged = true;        
        
        invalidateProperties();        
        dispatchChangeEvent("selectableDatesChanged");
    }
   
    //----------------------------------
    //  selectedDate
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    [Inspectable(category="General", defaultValue="null")]
    
    /**
     *  The selected date or if there is more than one selected date, this is the last date
     *  that was selected.
     *  If the last selection was a range, this is the latest date in the range.
     *
     *  <p>When the user changes the selection by interacting with the 
     *  control, the control dispatches the <code>selectionChange</code> event.
     *  When the user changes the selection programmatically, the 
     *  control dispatches the <code>valueCommit</code> event.</p>
     * 
     *  <p> This property is intended to be used to initialize or bind to the
     *  selection in MXML markup.
     *  Attempts to set this property are deferred until commitProperties()
     *  runs.  
     *  The <code>setSelectedDate()</code> method should be used
     *  for programatic selection updates, for example when writing a keyboard
     *  or mouse event handler. </p> 
     *  
     *  @default null
     *  
     *  @see spark.components.calendarClasses.DateRange
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get selectedDate():Date
    {
        return dateSelection.lastSelectedDate;        
    }
    
    /**
     *  @private
     */
    public function set selectedDate(value:Date):void
    {
        // FIXME: bind selectionMode, set selectedDates, selectedDates are wiped out when selectionMode
        // binding occurs
        // FIXME: displayed date doesn't seem right if this is set

        if (value)
            setSelectedDate(value);
        else
            clearSelection();
    }
    
    //----------------------------------
    //  selectedDates
    //----------------------------------
    
    private var _selectedDates:Vector.<DateRange>;
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    [Inspectable(category="General", defaultValue="-1")]
    
    /**
     *  The dates selected in the date chooser.
     *
     *  <p>When the user changes the selection by interacting with the 
     *  control, the control dispatches the <code>selectionChange</code> event.
     *  When the user changes the selection programmatically, the 
     *  control dispatches the <code>valueCommit</code> event.</p>
     * 
     *  <p> This property is intended to be used to initialize or bind to the
     *  selection in MXML markup.  
     *  Attempts to set this property are deferred until commitProperties()
     *  runs.  
     *  The <code>selectDateRange</code> and <code>addSelectedDate()</code> 
     *  methods should be used for programatic selection updates, 
     *  for example when writing a keyboard or mouse event handler. </p> 
     *  
     *  @default "empty <code>Vector.&lt;DateRange&gt;</code>"
     *  
     *  @see spark.components.calendarClasses.DateRange
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get selectedDates():Vector.<DateRange>
    {
        return dateSelection.allDateRanges();  
    }
    
    /**
     *  @private
     */
    public function set selectedDates(value:Vector.<DateRange>):void
    {         
        var selectionChanged:Boolean = dateSelection.removeAll();
        
        // FIXME: check selection mode
        
        for each (var range:DateRange in value)
        {
            selectionChanged = dateSelection.addDateRange(range.startDate, range.endDate) || selectionChanged;
        }
        
        if (selectionChanged)
        {
            caretDate = dateSelection.lastSelectedDate;
            invalidateMonthGridDisplayListFor("selectionIndicator");
            dispatchChangeEvent("selectionChange");
        }        
    }
        
    //----------------------------------
    //  selectionMode
    //----------------------------------
        
    [Bindable("selectionModeChanged")]
    [Inspectable(category="General", enumeration="singleDate,singleRange,multipleRanges", defaultValue="singleDate")]
    
    // FIXME
    private var _selectionMode:String = DateChooserSelectionMode.SINGLE_DATE;
    
    /**
     *  The selection mode of the control.  Possible values are:
     *  <code>"singleDate" (DateChooserSelectionMode.SINGLE_DATE)</code>, 
     *  <code>"singleRange" (DateChooserSelectionMode.SINGLE_RANGE)</code>, 
     *  <code>"multipleRanges" DateChooserSelectionMode.MULTIPLE_RANGES</code>.
     * 
     *  <p>Changing the selectionMode causes the current selection and the caret to be reset.</p>
     *
     *  @default "singleDate"
     * 
     *  @see spark.components.calendarClasses.DateChooserSelectionMode
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function get selectionMode():String
    {
        return _selectionMode;
    }
    
    /**
     *  @private
     */
    public function  set selectionMode(value:String):void
    {
        if (_selectionMode == value)
            return;
        
        if (value != DateChooserSelectionMode.SINGLE_DATE && value != DateChooserSelectionMode.SINGLE_RANGE && 
            value != DateChooserSelectionMode.MULTIPLE_RANGES)
        {
            return;
        }
            
        _selectionMode = value;

        clearSelection();
        
        dispatchChangeEvent("selectionModeChanged");
    }
    
    //----------------------------------
    //  showCaret
    //----------------------------------
    
    /**
     *  @private
     */
    private var _showCaret:Boolean = false;
    
    [Bindable("showCaretChanged")]    
    
    /**
     *  @private
     *  Determines if the caret indicator, if there is one, is visible, it
     *  the caret is set to a date in this month.
     *  This is set to true when the date chooser gets focus and to false when
     *  the date chooser loses focus.
     * 
     *  @default false
     */
    public function get showCaret():Boolean
    {
        return _showCaret;
    }
    
    /**
     *  @private
     */
    public function set showCaret(value:Boolean):void
    {
        if (_showCaret == value)
            return;
        
        _showCaret = value;
        invalidateMonthGridDisplayListFor("caretIndicator");
        
        dispatchChangeEvent("showCaretChanged");       
    }    
    
    //----------------------------------
    //  showExtraWeekAtEnd (delegates to monthGrid)
    //----------------------------------
    
//    private var _showExtraWeekAtEnd:Boolean = false;
//    
//    [Bindable("showExtraWeekAtEndChanged")]
//    [Inspectable(defaultValue="false")]
//    
//    /**
//     *  @copy spark.components.calendarClasses.monthGrid#showExtraWeekAtEnd
//     *
//     *  @default false
//     *  
//     *  @see #showFixedWeeks
//     *  @see #showDaysInOtherMonths
//     * 
//     *  @langversion 3.0
//     *  @playerversion Flash 11
//     *  @playerversion AIR 3.0
//     *  @productversion Flex 5.0
//     */
//    public function get showExtraWeekAtEnd():Boolean
//    {
//        return _showExtraWeekAtEnd;
//    }
//    
//    /**
//     *  @private
//     */
//    public function set showExtraWeekAtEnd(value:Boolean):void
//    {
//        if (value == _showExtraWeekAtEnd)
//            return;
//        
//        _showExtraWeekAtEnd = value;
////        setMonthGridProperty("showExtraWeekAtEnd", value);
//        monthGridPropertyChanged = true;
//        
//        invalidateProperties();       
//        dispatchChangeEvent("showExtraWeekAtEndChanged");
//    }
//    
//    //----------------------------------
//    //  showFixedWeeks (delegates to monthGrid)
//    //----------------------------------
//    
//    private var _showFixedWeeks:Boolean = true;
//    
//    [Bindable("showFixedWeeksChanged")]
//    [Inspectable(defaultValue="true")]
//    
//    /**
//     *  @copy spark.components.calendarClasses.monthGrid#showFixedWeeks
//     *
//     *  @default true
//     *  
//     *  @see #showFixedWeeksAtEnd
//     *  @see #showDaysInOtherMonths
//     * 
//     *  @langversion 3.0
//     *  @playerversion Flash 11
//     *  @playerversion AIR 3.0
//     *  @productversion Flex 5.0
//     */
//    public function get showFixedWeeks():Boolean
//    {
//        return _showFixedWeeks;
//    }
//    
//    /**
//     *  @private
//     */
//    public function set showFixedWeeks(value:Boolean):void
//    {
//        if (value == _showFixedWeeks)
//            return;
//        
//        _showFixedWeeks = value;
////        setMonthGridProperty("showFixedWeeks", value);
//        monthGridPropertyChanged = true;
//        
//        invalidateProperties();        
//        dispatchChangeEvent("showFixedWeeksChanged");
//    }
    
    //----------------------------------
    //  showDaysInOtherMonths (delegates to monthGrid)
    //----------------------------------
    
    private var _showDaysInOtherMonths:Boolean = true;
    
    [Bindable("showDaysInOtherMonthsChanged")]
    [Inspectable(defaultValue="true")]
    
    /**
     *  @copy spark.components.calendarClasses.monthGrid#showDaysInOtherMonths
     *
     *  @default true
     *  
     *  @see #showFixedWeeks
     *  @see #showFixedWeeksAtEnd
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get showDaysInOtherMonths():Boolean
    {
        return _showDaysInOtherMonths;
    }
    
    /**
     *  @private
     */
    public function set showDaysInOtherMonths(value:Boolean):void
    {
        if (value == _showDaysInOtherMonths)
            return;
        
        _showDaysInOtherMonths = value;        
//        setMonthGridProperty("showDaysInOtherMonths", value);
        monthGridPropertyChanged = true;
        
        invalidateProperties();        
        dispatchChangeEvent("showDaysInOtherMonthsChanged");
    }
    
    //----------------------------------
    //  showTodayIndicator (delegates to monthGrid)
    //----------------------------------
    
    private var _showTodayIndicator:Boolean = true;
    
    [Bindable("showTodayIndicatorChanged")]
    [Inspectable(category="General", defaultValue="true")]
           
    /**
     *  @copy spark.components.calendarClasses.monthGrid#showTodayIndicator
     *
     *  @default true
     *  
     *  @see #todayIndicator
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function get showTodayIndicator():Boolean
    {
        return _showTodayIndicator;
    }
    
    /**
     *  @private
     */
    public function set showTodayIndicator(value:Boolean):void
    {
        if (value == _showTodayIndicator)
            return;
        
        _showTodayIndicator = value;
//        setMonthGridProperty("showTodayIndicator", value);
        monthGridPropertyChanged = true;
        
        invalidateProperties();
        dispatchChangeEvent("showTodayIndicatorChanged");
    }

    //----------------------------------
    //  sixWeekLayoutMode (delegates to monthGrid)
    //----------------------------------
    
    private var _sixWeekLayoutMode:String = SixWeekLayoutMode.EXTRA_WEEK_AFTER;
    
    [Bindable("sixWeekLayoutModeChanged")]
    [Inspectable(category="General", defaultValue="off", enumeration="off, extraWeekAfter, extraWeekBefore")]
    
    /**
     *  @copy spark.components.calendarClasses.monthGrid#sixWeekLayoutMode
     *
     *  @default SixWeekLayoutMode.EXTRA_WEEK_AFTER ("extraWeekAfter")
     *  
     *  @see #showDaysInOtherMonths
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function get sixWeekLayoutMode():String
    {
        return _sixWeekLayoutMode;
    }
    
    /**
     *  @private
     */
    public function set sixWeekLayoutMode(value:String):void
    {
        if (value == _sixWeekLayoutMode)
            return;
        
        if (value != SixWeekLayoutMode.OFF && value != SixWeekLayoutMode.EXTRA_WEEK_BEFORE && 
            value != SixWeekLayoutMode.EXTRA_WEEK_AFTER)
        {
            return;
        }
                
        _sixWeekLayoutMode = value;
        monthGridPropertyChanged = true;
        
        invalidateProperties();
        dispatchChangeEvent("sixWeekLayoutModeChanged");
    }
        
    //----------------------------------
    //  typicalDate (delegates to monthGrid)
    //----------------------------------
    
    private var _typicalDate:Date = null;
    private var typicalDateChanged:Boolean;
    
    [Bindable("typicalDateChanged")]
    
    /**
     *  @copy spark.components.calendarClasses.monthGrid#typicalDate
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get typicalDate():Date
    {
        return _typicalDate;
    }
    
    /**
     *  @private
     */
    public function set typicalDate(value:Date):void
    {
        if (value == _typicalDate)
            return;
        
        _typicalDate = value;
//        setMonthGridProperty("typicalDate", value);
        typicalDateChanged = true;
        monthGridPropertyChanged = true;
        
        invalidateProperties();
        dispatchChangeEvent("typicalDateChanged");
    } 

    //----------------------------------
    //  weekOrientation (delegates to monthGrid)
    //----------------------------------
    
    private var _weekOrientation:String = WeekOrientation.ROWS;
    private var weekOrientationChanged:Boolean;
    
    // ToDo: is there any way to get this from the locale information?
    
    [Inspectable(category="General", enumeration="rows,columns", defaultValue="rows")]
    [Bindable("weekOrientationChanged")]
    
    /**
     *  @copy spark.components.calendarClasses.monthGrid#weekOrientation
     * 
     *  @default WeekOrientation.ROWS ("rows")
     *  
     *  @see spark.components.spark.calendarClasses.WeekOrientation
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get weekOrientation():String
    {
        return _weekOrientation;
    }
    
    /**
     *  @private
     */
    public function set weekOrientation(value:String):void
    {
        if (value == _weekOrientation)
            return;
        
        if (value != WeekOrientation.ROWS && value != WeekOrientation.COLUMNS) 
            return;
        
        _weekOrientation = value;
        weekOrientationChanged = true;

        monthGridPropertyChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();
        dispatchChangeEvent("weekOrientationChanged");
    } 
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (DateChooser.createAccessibilityImplementation != null)
            DateChooser.createAccessibilityImplementation(this);
    }
            
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        // FIXME: if minDate changes may have to change displayDate and invalidate grid
        // FIXME: if displayedDate changed make sure it is between min and maxDate
        
        if (anchorDateChanged || selectableDatesChanged)
        {
            if (anchorDate)
            {
                var newDate:Date = clampToSelectableDate(_anchorDate);
                if (newDate)
                {
                    _anchorDate = newDate;
                    anchorDateChanged = true;
                }
            }
            
            if (anchorDateChanged)
                dispatchChangeEvent("anchorDateChanged");
            
            anchorDateChanged = false;
        }
        
        if (caretDateChanged || selectableDatesChanged)
        {
            if (caretDate)
            {
                const newCaretDate:Date = clampToSelectableDate(_caretDate);
                if (newCaretDate)
                {
                    _caretDate = newDate;
                    caretDateChanged = true;
                }
            }
            
            if (caretDateChanged)
            {
                // Scroll caret into view.  
                // FIXME: No event because not due to user interaction??
                if (_caretDate)
                {
                    // Trigger bindings so month header will update.
                    displayedYear = _caretDate.fullYear;
                    displayedMonth = _caretDate.month;
                }
                 
                invalidateMonthGridDisplayListFor("caretIndicator");
                //monthGrid.invalidateMonthGridDisplayListFor("caretIndicator");
                
                if (hasEventListener(DateChooserEvent.CARET_CHANGE))
                    dispatchEvent(new DateChooserEvent(DateChooserEvent.CARET_CHANGE));
            }
            
            caretDateChanged = false;    
        }
        
        if (selectableDatesChanged)
        {
            const date:Date = new Date(_displayedYear, _displayedMonth, 1);
            const newAnchorDate:Date = clampToSelectableDate(date);
            if (newAnchorDate)
            {
                displayedYear = newDate.fullYear;
                displayedMonth = newDate.month;
            }
            
            // FIXME: may have to adjust months in dropdown list or yearTextDisplay
            // FIXME: may have to change next/Prev buttons
            
            selectableDatesChanged = false;            
        }
        
        if (typicalDateChanged)
        {
            if (dataGroup)
                dataGroup.typicalItem = typicalDate;
            typicalDateChanged = false;
        }
        
        if (monthGridPropertyChanged)
        {
            updateMonthGridRenderers();
            
            if (nextMonthButton)
                nextMonthButton.rotation = weekOrientation == WeekOrientation.ROWS ? 0 : 90;
            
            if (previousMonthButton)
                previousMonthButton.rotation = weekOrientation == WeekOrientation.ROWS ? 0 : 90;

            monthGridPropertyChanged = false;
        }

        if (weekOrientationChanged)
        {
            if (dataGroup)
            {
                const dp:IList = dataGroup.dataProvider;
                if (_weekOrientation == WeekOrientation.ROWS && weekOrientationRowsLayout)
                    dataGroup.layout = weekOrientationRowsLayout.newInstance();
                else if (_weekOrientation == WeekOrientation.COLUMNS && weekOrientationColumnsLayout)
                    dataGroup.layout = weekOrientationColumnsLayout.newInstance();
                dataGroup.verticalScrollPosition = 0;
                dataGroup.horizontalScrollPosition = 0;
            }
            weekOrientationChanged = false;
        }
        
        if (displayedMonthChanged || displayedYearChanged)
        {
            if (displayedMonthChanged && monthDropDownList)
                monthDropDownList.selectedItem = monthNames[_displayedMonth];
            if (displayedYearChanged && yearDropDownListBase)
                yearDropDownListBase.selectedItem = String(_displayedYear);
            
            const minDate:Date = _selectableDates.minDate;
            const maxDate:Date = _selectableDates.maxDate;
            
            if (nextMonthButton)
            {
                nextMonthButton.enabled = _displayedYear <  maxDate.fullYear || 
                    _displayedMonth < maxDate.month;
            }
            if (previousMonthButton)
            {
                previousMonthButton.enabled = _displayedYear >  minDate.fullYear || 
                    _displayedMonth > minDate.month;
            }
                  
            displayedMonthChanged = false;
            displayedYearChanged = false;
        }        
    }
      
    /**
     *  @private
     */
    override protected function measure():void
    {
        if (localeChanged)
        {
            initializeMonthDropDownList();
            adjustHeaderPartsForLocale();
                        
            localeChanged = true;
        }
        
        super.measure();
    }
           
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        ensureMonthIsVisible(_displayedYear, _displayedMonth);
    }

    /**
     *  @private
     *  Call partAdded() for IFactory type skin parts.   By default, findSkinParts() is not 
     *  called for IFactory type skin part variables, because they're assumed to be 
     *  "dynamic" skin parts, to be created with createDynamicPartInstance().  That's 
     *  not the case with the IFactory valued parts listed in factorySkinPartNames.
     */ 
    override protected function findSkinParts():void
    {
        super.findSkinParts();
        
        for each (var partName:String in factorySkinPartNames)
        {
            if ((partName in skin) && skin[partName])
                partAdded(partName, skin[partName]);
        }
    }
        
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        var includePart:Boolean;
        
        if (instance == dataGroup)
        {
            dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.addEventListener(RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererAddHandler);
            dataGroup.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
                
        if (instance == caretIndicator)
        {                
            // Add a focus listener so we can turn the caret on and off
            // when we get and lose focus.
            addEventListener(FocusEvent.FOCUS_IN, dateChooser_focusHandler);
            addEventListener(FocusEvent.FOCUS_OUT, dateChooser_focusHandler);
        }
                
        if (instance == nextMonthButton)
        {
            // for autoRepeat="true"
            nextMonthButton.addEventListener(FlexEvent.BUTTON_DOWN, nextMonthButton_buttonDownEventHandler);
            nextMonthButton.addEventListener(MouseEvent.MOUSE_DOWN, nextMonthButton_buttonDownEventHandler);
        }
        
        if (instance == previousMonthButton)
        {
            // for autoRepeat="true"
            previousMonthButton.addEventListener(FlexEvent.BUTTON_DOWN, previousMonthButton_buttonDownEventHandler);
            previousMonthButton.addEventListener(MouseEvent.MOUSE_DOWN, previousMonthButton_buttonDownEventHandler);
        }
        
        if (instance == monthDropDownList)
        {
            monthDropDownList.requireSelection = true;
            initializeMonthDropDownList();
            monthDropDownList.addEventListener(DropDownEvent.CLOSE, monthDropDropList_closeEventHandler);
            if (yearDropDownListBase)
                adjustHeaderPartsForLocale();
        }
        
        if (instance == yearDropDownListBase)
        {
            yearDropDownListBase.addEventListener(IndexChangeEvent.CHANGE, yearDropDownListBase_changeEventHandler);
            if (monthDropDownList)
                adjustHeaderPartsForLocale();
        }
        
        if (instance == caretIndicator || instance == hoverIndicator || 
            instance == selectionIndicator || instance == todayIndicator || 
            instance == rowSeparator || instance == columnSeparator)
        {
            monthGridPropertyChanged = true;
            invalidateProperties();
        }
        
        if (instance == weekOrientationRowsLayout || instance == weekOrientationColumnsLayout)
            weekOrientationChanged = true;
                
        // FIXME - once month month and year skin parts are present need to arrange them in the
        // correct order
    }
    
    /**
     * @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == dataGroup)
        {
            dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererAddHandler);
            dataGroup.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
               
        if (instance == caretIndicator)
        {                
            removeEventListener(FocusEvent.FOCUS_IN, dateChooser_focusHandler);
            removeEventListener(FocusEvent.FOCUS_OUT, dateChooser_focusHandler);
        }
        
        if (instance == nextMonthButton)
        {
            nextMonthButton.removeEventListener(FlexEvent.BUTTON_DOWN, nextMonthButton_buttonDownEventHandler);
            nextMonthButton.removeEventListener(MouseEvent.MOUSE_DOWN, nextMonthButton_buttonDownEventHandler);
        }
        
        if (instance == previousMonthButton)
        {
            previousMonthButton.removeEventListener(FlexEvent.BUTTON_DOWN, previousMonthButton_buttonDownEventHandler);
            previousMonthButton.removeEventListener(MouseEvent.MOUSE_DOWN, previousMonthButton_buttonDownEventHandler);
        }

        if (instance == monthDropDownList)
            monthDropDownList.removeEventListener(DropDownEvent.CLOSE, monthDropDropList_closeEventHandler);
                
        if (instance == yearDropDownListBase)
            yearDropDownListBase.addEventListener(IndexChangeEvent.CHANGE, yearDropDownListBase_changeEventHandler);
        
        if (instance == caretIndicator || instance == hoverIndicator || 
            instance == selectionIndicator || instance == todayIndicator || 
            instance == rowSeparator || instance == columnSeparator)
        {
            monthGridPropertyChanged = true;
            invalidateProperties();
        }  
    }

    /**
     *  @private
     */ 
    override public function styleChanged(styleName:String):void
    {
        super.styleChanged(styleName);
        
        const allStyles:Boolean = (styleName == null || styleName == "styleName");
        
        if (allStyles || styleManager.isSizeInvalidatingStyle(styleName))
        {
            if (dataGroup)
            {
                var  indices:Vector.<int> = dataGroup.getItemIndicesInView();
                for each (var i:int in indices)
                {
                    const monthGrid:MonthGridItemRenderer = 
                        dataGroup.getElementAt(i) as MonthGridItemRenderer;
                    
                    if (monthGrid)
                    {
                        monthGrid.layout.clearVirtualLayoutCache();
                        monthGrid.invalidateSize();
                        invalidateMonthGridDisplayListFor("grid");
                    }
                }
            }
       }   
        
        // Wait until the style change is propograted to the style client child formatters before
        // formatting the headers.
        if (allStyles || styleName == "locale")
        {        
            // FIXME: strip out @calendar or change to Gregorian calendar
            localeChanged = true;
            invalidateSize();
        }
    }
    
    /**
     *  @private
     */
    override public function itemToLabel(item:Object):String
    {
        // FIXME: is this right?
        if (item !== null)
            return monthNameFormatter.format(item);
        return " ";
    }

    /**
     *  @private
     */
    override public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
    {
        // set the owner
        renderer.owner = this;
        
        // always set the data last
        if ((renderer is IDataRenderer) && (renderer !== data))
            IDataRenderer(renderer).data = data;           
    }  
    
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  Scrolls to the month after the month of the <code>displayedDate</code> if any date
     *  in that month is less than or equal to the <code>maxDate> for <code>selectableDates</code>.
     * 
     *  <p>If the <code>smoothScrolling</code> style is true the transition will be animated.</p>
     *  
     *  <p>If the date displayed changes, the <code>DateChooserEvent.MONTH_SCROLL</code> event is 
     *  dispatched.</p>
     * 
     *  @see #displayedDate
     *  @see #selectableDates
     *  @see spark.events.DateChooserEvent#MONTH_SCROLL
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */    
    public function scrollToNextMonth():Boolean
    {
        // FIXME: GAT method
        var nextMonth:Date = new Date(_displayedYear, _displayedMonth + 1, 1);
        
        if (clampToSelectableMonth(nextMonth) == null)
        {
            if (getStyle("smoothScrolling"))
            {
                animateMonthGridScrolling(nextMonth);
            }
            else
            {                
                displayedYear = nextMonth.fullYear;
                displayedMonth = nextMonth.month;
                var scrollEvent:DateChooserEvent = new DateChooserEvent(DateChooserEvent.MONTH_SCROLL);
                dispatchEvent(scrollEvent);                
            }
            
            return true;
        }
        
        return false;
    }

    /** 
     *  Scrolls to the month before the month of the <code>displayedDate</code> if any date
     *  in that month is greater than or equal to the <code>minDate> for 
     *  <code>selectableDates</code>.
     * 
     *  <p>If the <code>smoothScrolling</code> style is true the transition will be animated.</p>
     *  
     *  <p>If the date displayed changes, the <code>DateChooserEvent.MONTH_SCROLL</code> event is 
     *  dispatched.</p>
     * 
     *  @see #displayedDate
     *  @see #selectableDates
     *  @see spark.events.DateChooserEvent#MONTH_SCROLL
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */    
    public function scrollToPreviousMonth():Boolean
    {
        // FIXME: GAT method
        var previousMonth:Date = new Date(_displayedYear, _displayedMonth - 1, 1);
        
        if (clampToSelectableMonth(previousMonth) == null)
        {
            if (getStyle("smoothScrolling"))
            {
                animateMonthGridScrolling(previousMonth);
            }
            else
            {                
                displayedYear = previousMonth.fullYear;
                displayedMonth = previousMonth.month;
                var scrollEvent:DateChooserEvent = new DateChooserEvent(DateChooserEvent.MONTH_SCROLL);
                dispatchEvent(scrollEvent);                
            }
        }
        
        return false;
    }
    
    /** 
     *  Scrolls to the same month in the year after the year of the <code>displayedDate</code> if 
     *  any date in that month is less than or equal to the <code>maxDate> for 
     *  <code>selectableDates</code>.
     * 
     *  <p>The transition is not animated.</p>
     *  
     *  <p>If the date displayed changes, the <code>DateChooserEvent.MONTH_SCROLL</code> event is 
     *  dispatched.</p>
     * 
     *  @see #displayedDate
     *  @see spark.events.DateChooserEvent#MONTH_SCROLL
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */    
    private function scrollToNextYear():Boolean
    {
        // FIXME: GAT method
        var nextYear:Date = new Date(_displayedYear + 1, _displayedMonth, 1);
        
        if (clampToSelectableMonth(nextYear) == null)
        {
            displayedYear = nextYear.fullYear;
            displayedMonth = nextYear.month;
            var scrollEvent:DateChooserEvent = new DateChooserEvent(DateChooserEvent.MONTH_SCROLL);
            dispatchEvent(scrollEvent);
            return true;
        }
        
        return false;
    }
    
    /** 
     *  Scrolls to the same month in the year before the year of the <code>displayedDate</code> if 
     *  any date in that month is greater than or equal to the <code>minDate> for 
     *  <code>selectableDates</code>.
     * 
     *  <p>The transition is not animated.</p>
     *  
     *  <p>If the date displayed changes, the <code>DateChooserEvent.MONTH_SCROLL</code> event is 
     *  dispatched.</p>
     * 
     *  @see #displayedDate
     *  @see spark.events.DateChooserEvent#MONTH_SCROLL
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */    
    private function scrollToPreviousYear():Boolean
    {
        // FIXME: GAT method
        var previousYear:Date = new Date(_displayedYear - 1, _displayedMonth, 1);
        
        if (clampToSelectableMonth(previousYear) == null)
        {
            displayedYear = previousYear.fullYear;
            displayedMonth = previousYear.month;
            var scrollEvent:DateChooserEvent = new DateChooserEvent(DateChooserEvent.MONTH_SCROLL);
            dispatchEvent(scrollEvent);
            return true;
        }
        
        return false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  DateSelection Cover Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Removes all of the selected dates.  
     *  Removes the caret and the anchor by setting <code>caretDate</code> and 
     *  <code>anchorDate</code> to null.
     *
     *  @return <code>true</code> if the selection changed.
     *  <code>false</code> if there was nothing previously selected.
     *    
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function clearSelection():Boolean
    {
        const selectionChanged:Boolean = dateSelection.removeAll();

        initializeAnchorDate();
        initializeCaretDate();

        if (selectionChanged)
        {            
            invalidateMonthGridDisplayListFor("selectionIndicator");
            dispatchEvent(new DateChooserEvent(DateChooserEvent.SELECTION_CHANGE));
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
     
    /**
     *  Determines if <code>date</code> is selected.
     * 
     *  <p>The time properties of the date are ignored.</p>
     * 
     *  @param date The date to check.
     *  
     *  @return <code>true</code> if the current selection contains the date.
     *  <code>false</code> if there is no selection or it does not contain the date.
     * 
     *  @see spark.components.DateChooser#selectableDates
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function selectionContainsDate(date:Date):Boolean
    {
        return dateSelection.containsDate(date);
    }
    
    /**
     *  Determines if all the dates between <code>startDate</code> and <code>endDate</code>,
     *  inclusive, are selected.
     *  The <code>startDate</code> must be less than or equal to the <code>endDate/<code>.
     * 
     *  <p>The time properties of the dates are ignored.</p>
     * 
     *  @param startDate The earliest date in the range.
     *  @param endDate The latest date in the range.
     *  
     *  @return <code>true</code> if the current selection contains all 
     *  the dates in the date range and <code>false</code>if there is no selection or not all
     *  the dates are contained within the date range.
     * 
     *  @see spark.components.DateChooser#selectableDates
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function selectionContainsDateRange(startDate:Date, endDate:Date):Boolean
    {
        return dateSelection.containsDateRange(startDate, endDate);
    }
    
    /**
     *  Sets the selection to this date and the caret position to this date.
     * 
     *  <p>This date must be between the <code>minDate</code> and <code>maxDate</code> of
     *  <code>selectableDates</code> but it does not have to be one of the selectable dates.
     *  The time properties of the date are ignored.</p>
     * 
     *  @param date The date to select.
     * 
     *  @return <code>true</code> if the selection changed and <code>false</code> if the date could
     *  was already selected or could not be selected.
     *  
     *  @see spark.components.DateChooser#selectableDates
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function setSelectedDate(date:Date):Boolean
    {
        if (date == null)
            return false;
        
        const newDate:Date = clampToSelectableDate(date); 
        if (newDate)
            date = newDate;
        
        const selectionChanged:Boolean = dateSelection.setDate(date);
        if (selectionChanged)
        {
            caretDate = date;            
            invalidateMonthGridDisplayListFor("selectionIndicator")
            dispatchEvent(new DateChooserEvent(DateChooserEvent.SELECTION_CHANGE));
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
        
    /**
     *  If the <code>selectionMode</code> is <code>"multipleRanges"</code>, adds the date to the 
     *  selection and sets the caret position this date.
     * 
     *  <p>This date must be between the <code>minDate</code> and <code>maxDate</code> of
     *  <code>selectableDates</code> but it does not have to be one of the selectable dates.
     *  The time properties of the date are ignored.</p>
     * 
     *  @param date The date to select.
     * 
     *  @return <code>true</code> if the selection changed and <code>false</code> if the date was
     *  already in the selection or the selection mode did not allow an additional selection.
     *  
     *  @see spark.components.DateChooser#selectableDates
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function addSelectedDate(date:Date):Boolean
    {
        if (date == null)
            return false;
        
        const newDate:Date = clampToSelectableDate(date); 
        if (newDate)
            date = newDate;
                                
        const selectionChanged:Boolean = dateSelection.addDate(date);
        if (selectionChanged)
        {
            caretDate = date;           
            invalidateMonthGridDisplayListFor("selectionIndicator")
            dispatchEvent(new DateChooserEvent(DateChooserEvent.SELECTION_CHANGE));
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  Removes the date from the selection and sets the caret position to this date.
     * 
     *  @param date The date to select.
     * 
     *  @return <code>true</code> if no errors.
     *  <code>false</code> if <code>date</code> is invalid or the not selectable.
     *  
     *  @see spark.components.DateChooser#selectableDates
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function removeSelectedDate(date:Date):Boolean
    {
        const selectionChanged:Boolean = dateSelection.removeDate(date);
        if (selectionChanged)
        {
            caretDate = date;           
            invalidateMonthGridDisplayListFor("selectionIndicator")
            dispatchEvent(new DateChooserEvent(DateChooserEvent.SELECTION_CHANGE));
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /** 
     *  If the <code>selectionMode</code> is <code>"singleRange"</code> or 
     *  <code>"multipleRanges"</code>, sets the selection to all the dates in the date range and the
     *  caret position to the last date in the date range.
     * 
     *  <p>The <code>startDate</code> must be less than or equal to the <code>endDate/<code>.
     *  In addition, <code>startDate</code> and <code>endDate</code> must be
     *  between the <code>selectableDates</code> properties <code>minDate</code> and 
     *  <code>maxDate</code>, inclusive, but they do not need to be selectable dates.
     *  The time properties of the date are ignored.</p>
     * 
     *  @param startDate The earliest date in the range.
     *  @param endDate The latest date in the range.
     *  
     *  @return <code>true</code> if the selection changed or <code>false</code> if the
     *  selection did not change because the dates were already selected or the selection mode did
     *  not allow the selection.
     *  
     *  @see spark.components.DateChooser#minDate
     *  @see spark.components.DateChooser#maxDate
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */    
    public function selectDateRange(startDate:Date, endDate:Date):Boolean
    {
        if (_selectionMode == DateChooserSelectionMode.SINGLE_DATE)
            return false;
            
        var newDate:Date = clampToSelectableDate(startDate); 
        if (newDate)
            startDate = newDate;
        newDate = clampToSelectableDate(endDate); 
        if (newDate)
            endDate = newDate;
                
        const selectionChanged:Boolean = dateSelection.setDateRange(startDate, endDate);
        if (selectionChanged)
        {
            caretDate = endDate;
            invalidateMonthGridDisplayListFor("selectionIndicator")
            dispatchEvent(new DateChooserEvent(DateChooserEvent.SELECTION_CHANGE));
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /** 
     *  If the <code>selectionMode</code> is <code>"multipleRanges"</code>,
     *  adds all the dates in the date range to the selection and sets the
     *  caret position to the last cell in the date range.
     * 
     *  <p>The <code>startDate</code> must be less than or equal to the <code>endDate/<code>.
     *  In addition, <code>startDate</code> and <code>endDate</code> must be
     *  between the <code>selectableDates</code> properties <code>minDate</code> and 
     *  <code>maxDate</code>, inclusive, but they do not need to be selectable dates.
     *  The time properties of the date are ignored.</p>
     * 
     *  @param startDate The earliest date in the range.
     *  @param endDate The latest date in the range.
     *  
     *  @return <code>true</code> if the selection changed or <code>false</code> if the
     *  selection did not change because the dates were already selected or the selection mode did
     *  not allow the selection.
     *  
     *  @see spark.components.DateChooser#selectableDates
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */    
    public function addDateRange(startDate:Date, endDate:Date):Boolean
    {
        // FIXME: swap start/end or have addDateRange do it
        
        if (_selectionMode != DateChooserSelectionMode.MULTIPLE_RANGES)
            return false;
        
        var newDate:Date = clampToSelectableDate(startDate); 
        if (newDate)
            startDate = newDate;
        newDate = clampToSelectableDate(endDate); 
        if (newDate)
            endDate = newDate;
        
        const selectionChanged:Boolean = dateSelection.addDateRange(startDate, endDate);
        if (selectionChanged)
        {
            caretDate = endDate;
            invalidateMonthGridDisplayListFor("selectionIndicator")
            dispatchEvent(new DateChooserEvent(DateChooserEvent.SELECTION_CHANGE));
            dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }

    private function dispatchFlexEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new FlexEvent(type));
    }
    
    private function dispatchDateChooserEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new DateChooserEvent(type));
    }
    
    /**
     *  Clamp date to within the selectableDates min/maxDate range.
     *  Considers fullYear, month and date.
     *  
     *  @returns null if date not changed, or new date if date was changed.
     */ 
    private function clampToSelectableDate(date:Date):Date
    {
        var newDate:Date;
        
        if (DateUtil.dateCompare(date, _selectableDates.minDate) == -1)
            newDate = _selectableDates.minDate;
        
        if (DateUtil.dateCompare(date, _selectableDates.maxDate) == 1)
            newDate = _selectableDates.maxDate;
      
        return newDate;
    }
    
    /**
     *  Clamp date to within the the absolute MIN_DATE and MAX_DATE.
     *  Considers fullYear, month and date.
     *  
     *  @returns date if date not changed, or new date if date was changed.
     */ 
    private function clampToMinMaxDate(date:Date):Date
    {
        if (!date)
            return null;
        
        var newDate:Date = date;
        
        if (DateUtil.dateCompare(date, MIN_DATE) == -1)
            newDate = MIN_DATE;
        
        if (DateUtil.dateCompare(date, MAX_DATE) == 1)
            newDate = MAX_DATE;
        
        return newDate;
    }
    
    /**
     *  Clamp month and year of date to within the month and year of selectableDates min/maxDate
     *  range.
     *  
     *  @returns null if date not changed, or new date if date was changed.
     */ 
    private function clampToSelectableMonth(date:Date):Date
    {
        var newDate:Date;
        
        const minDate:Date = _selectableDates.minDate;
        const maxDate:Date = _selectableDates.maxDate;
        
        if (date.fullYear < minDate.fullYear || 
            (date.fullYear == minDate.fullYear && date.month < minDate.month))
        {
            newDate = new Date(minDate.time);        
        }
        
        if (date.fullYear > maxDate.fullYear || 
            (date.fullYear == maxDate.fullYear && date.month > maxDate.month))
        {
            newDate = new Date(maxDate.time);        
        }
        
        return newDate;
    }

    private function initializeMonthDropDownList():void
    {
        // ToDo: assumptions here might not be valid for alternate calendar.
        
        // FIXME: if Hebrew, layoutDirection needs to be rtl to get correct order, also
        // drop-down list is left aligned and it should be right aligned.
        
        if (!monthDropDownList)
            return;
        
        monthNames = monthNameFormatter.getMonthNames();
        var longestMonthName:String = "";

        if (monthDropDownList.dataProvider == null)
            monthDropDownList.dataProvider = new ArrayList();            
        else
            monthDropDownList.dataProvider.removeAll();
        
        var dp:IList = monthDropDownList.dataProvider;
        const monthNamesLength:int = monthNames.length;
        
        const minDate:Date = selectableDates.minDate;
        const maxDate:Date = selectableDates.maxDate;
        
        for (var i:int = 0; i < monthNamesLength; i++)
        {
            if (minDate.fullYear == _displayedYear && i < minDate.month)
                continue;
            
            if (maxDate.fullYear == _displayedYear && i > maxDate.month)
                break;
                
            dp.addItem(monthNames[i]);
            
            longestMonthName = monthNames[i].length > longestMonthName.length ? 
                               monthNames[i] : longestMonthName;
            
            if (i == _displayedMonth)
                monthDropDownList.selectedItem = monthNames[i];
        }
        
        monthDropDownList.typicalItem = longestMonthName;
    }
        
    private function initializeAnchorDate():void
    {
        anchorDate = new Date(_displayedYear, _displayedMonth, 1);
    }
    
    private function initializeCaretDate():void
    {
        caretDate = new Date(_displayedYear, _displayedMonth, 1);
    }

    // For now, selection is within a single month.
    private function extendSelection(target:MonthGrid, toDate:Date):Boolean
    {
        var selectionChanged:Boolean = false;
        
        // Anchor gets set on mouseUp so if in a drag use the mouseDown pt rather than the anchor.
        if  (_selectionMode != DateChooserSelectionMode.SINGLE_DATE)
        {              
            if (anchorDate)
            {
                if (anchorDate.time < toDate.time)
                    selectionChanged = selectDateRange(anchorDate, toDate);
                else    
                    selectionChanged = selectDateRange(toDate, anchorDate);
            }
        }        
        
        if (selectionChanged)
            caretDate = toDate;
        
        return selectionChanged;
    }
    
    // For now, selection is within a single month.
    private function toggleSelection(target:MonthGrid, date:Date):Boolean
    {
        var selectionChanged:Boolean = false;
        
        const isDateSelected:Boolean = selectionContainsDate(date);
        
        if (isDateSelected)
        {       
            // If there is a singleRange selection of more than one date, then toggling one of
            // the dates, doesn't remove that date.  Rather it changes the selection to be just
            // that date.
            if (selectionMode == DateChooserSelectionMode.SINGLE_RANGE && !dateSelection.containsOnlyDateRange(date, date))
                selectionChanged = setSelectedDate(date);
            else
                selectionChanged = removeSelectedDate(date);                
        }
        else
        {
            if (selectionMode == DateChooserSelectionMode.MULTIPLE_RANGES)
                selectionChanged = addSelectedDate(date);                
            else
                selectionChanged = setSelectedDate(date);                   
        }

        if (selectionChanged)
        {
            anchorDate = date;
            caretDate = date;
        }
        
        return selectionChanged;       
    }    
        
    /**
     *  @private
     * 
     *  A convenience method that handles scrolling a data item (MonthGrid)
     *  into view. 
     * 
     *  If the data item at the specified index is not completely 
     *  visible, the calendar scrolls until it is brought into view. 
     *  If the data item is already in view, no additional scrolling occurs. 
     */
    protected function ensureMonthIsVisible(year:int, month:int):void
    {
        if (!layout || !dataGroup)
            return;
        
        if (dataGroup.getItemIndicesInView().length == 0)
            validateNow();
        
        const date:Date = new Date(year, month, 1);
        const index:int = MonthArrayList.dateToIndex(date);
        
        var spDelta:Point = dataGroup.layout.getScrollPositionDeltaToElement(index);
        
        if (spDelta)
        {
            dataGroup.horizontalScrollPosition += spDelta.x;
            dataGroup.verticalScrollPosition += spDelta.y;
        }
    }

    /**
     *  If adjustHeaderForLocale is true, adjust the relative positions of the month and year parts 
     *  to match the format for the given locale.  If it is false, and
     *  the parts have been changed, return them to their initial positions.
     * 
     *  @returns True if the positions of the parts were swapped.
     */ 
    private function adjustHeaderPartsForLocale():Boolean
    {
        var changed:Boolean;
        
        //headerPartsFormatter.setStyle("locale", getStyle("locale"));

        const monthPosition:int = monthYearPositionFormatter.getMonthPosition();
        const yearPosition:int = monthYearPositionFormatter.getYearPosition();
        
        // Can only adjust parts if both parts have the same parent.
        if ((monthDropDownList && yearDropDownListBase) && 
            monthDropDownList.parent == yearDropDownListBase.parent)
        {
            var container:IVisualElementContainer = 
                monthDropDownList.parent as IVisualElementContainer;
            if (!container)
                return false;
            
            var monthIndex:int = container.getElementIndex(monthDropDownList);
            var yearIndex:int = container.getElementIndex(yearDropDownListBase);
            
            if (adjustHeaderForLocale)
            {
                // Order month and year according to position.
                if ((monthPosition < yearPosition && monthIndex > yearIndex) ||
                    (yearPosition < monthPosition && yearIndex > monthIndex))
                {
                    container.swapElementsAt(monthIndex, yearIndex);
                    changed = true;
                } 
                
                // If this is the first adjustment, save the initial positions so they can
                // be restored.
                if (initialMonthPositionIndex < 0)
                    initialMonthPositionIndex = monthPosition;
                if (initialYearPositionIndex < 0)
                    initialYearPositionIndex = yearPosition;
            }
            else if (initialMonthPositionIndex >= 0 && initialYearPositionIndex >= 0)
            {
                // If an adjustment was made, restore to original position.
                if ((initialMonthPositionIndex < initialYearPositionIndex && monthIndex > yearIndex) ||
                    (initialYearPositionIndex < initialMonthPositionIndex && yearIndex > monthIndex))
                {
                    container.swapElementsAt(monthIndex, yearIndex);
                    changed = true;
                }                                                
            }                
        }
        
        return changed;
    }
    
    /**
     *  One or more of the properties which are covered in monthGrid changed.
     *  Update all the visible/active monthGrid renderers by setting data.
     *  This will reinitialize the monthGrid properties so it will pick up the new values.
     *  The one exception is the displayed month/Year.  To change that you must scroll the
     *  dataGroup to the index which represents the desired date.
     */
    private function updateMonthGridRenderers():void
    {
//        monthGridPropertyChanged = false;
//        const modifiedProperties:Object = monthGridProperties;
//        monthGridProperties = {};
        
        if (!dataGroup)
            return;
        
        var  indices:Vector.<int> = dataGroup.getItemIndicesInView();
        for each (var i:int in indices)
        {
            const renderer:MonthGridItemRenderer = 
                dataGroup.getElementAt(i) as MonthGridItemRenderer;
            
            if (renderer)
                updateRenderer(renderer, i, renderer.data);
                        
            /*
            if (!renderer || !renderer.monthGrid)
                continue;
            
            const monthGrid:MonthGrid = renderer.monthGrid;
            
            for (var propertyName:String in modifiedProperties)
            {
                monthGrid[propertyName] = modifiedProperties[propertyName];
            }
            */
        }        
    }
    
//    private function updateMonthGridProperty(property:String, value:Object):void
//    {
//        if (!dataGroup)
//            return;
//        
//        var  indices:Vector.<int> = dataGroup.getItemIndicesInView();
//        for each (var i:int in indices)
//        {
//            const renderer:MonthGridItemRenderer = 
//                dataGroup.getElementAt(i) as MonthGridItemRenderer;
//            
//            if (renderer && renderer.monthGrid)
//                renderer.monthGrid[property] = value;
//        }
//    }
    
    private function getFirstMonthGridInView():MonthGrid
    {
        if (!dataGroup)
            return null;
        
        var index:int = -1;;
        
        if (dataGroup.layout is HorizontalLayout)
        {
            var layout:HorizontalLayout = dataGroup.layout as HorizontalLayout;
            index = layout.firstIndexInView;            
        }
        else
        {
            const indices:Vector.<int> = dataGroup.getItemIndicesInView();
            if (indices.length > 0)
                index = indices[0];
        }
        
        if (index >= 0)
        {
            const renderer:MonthGridItemRenderer = 
                dataGroup.getElementAt(index) as MonthGridItemRenderer;
            if (renderer)
                return renderer.monthGrid;
        }
        
        return null;
    }
    
    private function invalidateMonthGridSizes():void
    {
        if (!dataGroup)
            return;
        
        trace("invalidateMonthGridSizes");
        
        var  indices:Vector.<int> = dataGroup.getItemIndicesInView();
        for each (var i:int in indices)
        {
            const renderer:MonthGridItemRenderer = 
                dataGroup.getElementAt(i) as MonthGridItemRenderer;
            
            if (renderer && renderer.monthGrid)
                renderer.monthGrid.invalidateSize();                
        }        
    }

    /**
     *  Invalidate the display lists of all active/visible monthGrids for the given reason.
     **/
    private function invalidateMonthGridDisplayListFor(reason:String):void
    {
        if (!dataGroup)
            return;
        
        var  indices:Vector.<int> = dataGroup.getItemIndicesInView();
        for each (var i:int in indices)
        {
            const renderer:MonthGridItemRenderer = 
                dataGroup.getElementAt(i) as MonthGridItemRenderer;
            
            if (renderer && renderer.monthGrid)
                renderer.monthGrid.invalidateDisplayListFor(reason);                
        }        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Animation
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     *  The Animate object used to scroll the months.
     */
    mx_internal function get animateScrollPosition():Animate
    {
        if (_animateScrollPosition)
            return _animateScrollPosition;
        
        _animateScrollPosition = new Animate();
        _animateScrollPosition.easer = new Linear();
        _animateScrollPosition.startDelay = 0;
        
        //_animateScrollPosition.addEventListener("effectUpdate", animationUpdateHandler);
        _animateScrollPosition.addEventListener(EffectEvent.EFFECT_END, animationEndHandler);
        _animateScrollPosition.addEventListener(EffectEvent.EFFECT_STOP, animationEndHandler);

        return _animateScrollPosition;
    }

    /**
     *  @private
     *  Call this to animate the month transitions. 
     */
    mx_internal function animateMonthGridScrolling(toDate:Date):void
    {
        if (!dataGroup)
            return;
        
        animateScrollPosition.target = dataGroup;
        
        const index:int = MonthArrayList.dateToIndex(toDate);        
        const valueToBounds:Rectangle = dataGroup.layout.getElementBounds(index);
        
        // This should not happen but be safe.!!
        if (valueToBounds == null)
            return;

        var property:String;
        var valueFrom:Number;
        var valueTo:Number;
        
        if (weekOrientation == WeekOrientation.ROWS)
        {
            property = "horizontalScrollPosition";
            valueFrom = dataGroup.horizontalScrollPosition;
            valueTo = valueToBounds.x;
        }
        else
        {
            property = "verticalScrollPosition";
            valueFrom = dataGroup.verticalScrollPosition;
            valueTo = valueToBounds.y;            
        }
        
        const pageSize:int = dataGroup.width;
        const duration:Number = getStyle("repeatInterval") * (Math.abs(valueTo - valueFrom) / pageSize);
        
        // Stop any running animation.
        animateScrollPosition.stop();
        
        // Start the animation.
        animateScrollPosition.duration = duration;
        animateScrollPosition.motionPaths = new <MotionPath>[
            new SimpleMotionPath(property, valueFrom, valueTo)];
        animateScrollPosition.startDelay = 0;
        
        animateScrollPosition.play();
    }
                    
    /**
     * @private
     * Called when MonthGrid animated scrolling either completes (end) or is terminated 
     * prematurely (stop).
     * Dispatches "monthScroll" event.
     */
    private function animationEndHandler(event:EffectEvent):void
    {     
        // FIXME:  is this needed in addition to MONTH_SCROLL?  what about CHANGE_START?
        // dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
        
        // End of monthScroll so dispatch event.
            
        var scrollEvent:DateChooserEvent = new DateChooserEvent(DateChooserEvent.MONTH_SCROLL);
        dispatchEvent(scrollEvent);

    }
        
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------
    
    // FIXME: keyboard navigation within the headers for accessibility??  TAB similiar to DG?
    
    /**
     *  @private
     *  Keyboard navigation for accessibility.  
     *  Extracted from http://www.w3.org/WAI/PF/aria-practices/#datepicker
     * 
     * Keyboard navigation on days that are not included the currently displayed month should 
     * move to the month automatically and lead to the day in the next or previous month.
     *
     *  Up Arrow and Down Arrow - goes to the same day of the week in the previous or next 
     *    week respectively. If the user advances past the end of the month they continue into the 
     *    next or previous month as appropriate.
     * 
     *  Left Arrow and Right Arrow - advances one day to the next, also in a continuum. Visually 
     *    focus is moved from day to day and wraps from row to row in a grid of days and weeks.
     * 
     *  Control+Page Up - Moves to the same date in the previous year.
     * 
     *  Control+Page Down - Moves to the same date in the next year.
     * 
     *  Space -
     *       Singleton Mode: acts as a toggle either selecting or deselecting the date.
     *       Contiguous Mode: Similar to selecting a range of text. Space selects the first date. 
     *                        Shift+Arrows add to the selection. Pressing Space again deselects the 
     *                        previous selections and selects the current focused date.
     *       Non-Contiguous Mode: Space may be used to select multiple non-contiguous dates.
     * 
     *  Home - Moves to the first day of the current month.
     * 
     *  End - Moves to the last day of the current month.
     * 
     *  Page Up - Moves to the same date in the previous month.
     * 
     *  Page Down - Moves to the same date in the next month.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        // Was the space bar hit? 
        if (event.keyCode == Keyboard.SPACE)
        {
            // FIXME: these aren't all implemented are they
            
            // Singleton Mode: acts as a toggle either selecting or deselecting the date.
            // Contiguous Mode: Similar to selecting a range of text. Space selects the first date. 
            //   Shift+Arrows add to the selection. Pressing Space again deselects the previous 
            //   selections and selects the current focused date.
            // Non-Contiguous Mode: Space may be used to select multiple non-contiguous dates.
                            
            // Updates the selection.  The caret remains the same and the anchor is updated.
            if (toggleSelection(monthGrid, caretDate))
            {
                //anchorDate = caretDate;
                event.preventDefault();                
            }
            return;
        }
        
        // Was some other navigation key hit?
        const newCaretDate:Date = getNewCaretPosition(event);
        if (!newCaretDate)
            return;
        
        // Cancel so another component doesn't handle this event.
        event.preventDefault(); 
        
        // FIXME: where does the selection change event come from?
        
        if (event.shiftKey)
        {
            // The shift key-nav key combination extends the selection and 
            // updates the caret.
            extendSelection(monthGrid, newCaretDate);
            //if (extendSelection(monthGrid, newCaretDate))
                /*caretDate = newCaretDate*/;
        }
        else
        {
            caretDate = newCaretDate;
        }
    }
    
    /**
     *  @private
     *  Returns the new caret position based on the key that was entered.
     */
    private function getNewCaretPosition(event:KeyboardEvent):Date
    {
        /*
        PageUp: Previous Month
        PageDown: Next Month
        ctrl-PageUp: Previous Year
        ctrl-PageDown: Next Year
        */
        
        // Some unrecognized key stroke was entered, return. 
        if (!NavigationUnit.isNavigationUnit(event.keyCode))
            return null; 
        
        var newCaretDate:Date = caretDate;
          
        const currentMonth:Date = new Date(_displayedYear, _displayedMonth, 1);
        const previousMonth:Date = new Date(currentMonth.fullYear, currentMonth.month - 1, 1);
        const nextMonth:Date = new Date(currentMonth.fullYear, currentMonth.month + 1, 1);
        
        // If rtl layout, need to swap LEFT and RIGHT so correct action
        // is done.
        var keyCode:uint = mapKeycodeForLayoutDirection(event);
        
        // FIXME: if selectableDates can be null?
        // FIXME: should there always be a caret?
        
        // FIXME: replace date arithmetic with get next/previous day/week/month/year methods in 
        // CalendarDate from GAT.  This date arithmetic is not always right - for example 2/29/12, 
        // go back a yr, goes to 3/1/122
               
        // FIXME - dispatch scroll events
        
        if (keyCode == Keyboard.LEFT)
        {
            newCaretDate.date--;
            if (!selectableDates.isDateIncluded(newCaretDate))
                newCaretDate = selectableDates.getPreviousIncludedDate(newCaretDate);
        }           
        else if (keyCode == Keyboard.RIGHT)
        {
            newCaretDate.date++;
            if (!selectableDates.isDateIncluded(newCaretDate))
                newCaretDate = selectableDates.getNextIncludedDate(newCaretDate);
        }           
        else if (keyCode == Keyboard.UP)
        {
            newCaretDate.date -= 7;
            if (!selectableDates.isDateIncluded(newCaretDate))
                newCaretDate = selectableDates.getPreviousIncludedDate(newCaretDate);
        }            
        else if (keyCode == Keyboard.DOWN)
        {
            newCaretDate.date += 7;
            if (!selectableDates.isDateIncluded(newCaretDate))
                newCaretDate = selectableDates.getNextIncludedDate(newCaretDate);
        }
        else if (keyCode == Keyboard.HOME)
        {
            newCaretDate.date = 1;
            newCaretDate = selectableDates.getPreviousIncludedDate(newCaretDate);
        }            
        else if (keyCode == Keyboard.END)
        {
            newCaretDate.date = new CalendarDate(currentMonth).numDaysInMonth;
            if (!selectableDates.isDateIncluded(newCaretDate))
                newCaretDate = selectableDates.getNextIncludedDate(newCaretDate);
        }
        else if (keyCode == Keyboard.PAGE_UP)
        {
            if (event.ctrlKey)
            {
                newCaretDate.fullYear--;
            }
            else
            {
                const numDaysInPreviousMonth:int = new CalendarDate(previousMonth).numDaysInMonth;
                if (newCaretDate.date > numDaysInPreviousMonth)
                    newCaretDate.date = numDaysInPreviousMonth;
                newCaretDate.month--;
            }
            if (!selectableDates.isDateIncluded(newCaretDate))
                newCaretDate = selectableDates.getPreviousIncludedDate(newCaretDate);
        }
        else if (keyCode == Keyboard.PAGE_DOWN)
        {
            if (event.ctrlKey)
            {
                newCaretDate.fullYear++;
            }
            else
            {
                const numDaysInNextMonth:int = new CalendarDate(nextMonth).numDaysInMonth;
                if (newCaretDate.date > numDaysInNextMonth)
                    newCaretDate.date = numDaysInNextMonth;
                newCaretDate.month++;
            }
            
            if (!selectableDates.isDateIncluded(newCaretDate))
                newCaretDate = selectableDates.getNextIncludedDate(newCaretDate);
        }
            
        return newCaretDate;        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
        
    //--------------------------------------------------------------------------
    //
    //  Skin Part Event handlers
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     *  The UIComponent's focusInHandler and focusOutHandler draw the
     *  focus.  This handler exists only when there is a caretIndicator part.
     */
    protected function dateChooser_focusHandler(event:FocusEvent):void
    {            
        if (isOurFocus(DisplayObject(event.target)))
            showCaret = event.type == FocusEvent.FOCUS_IN;
    }

    /**
     *  @private
     *  The button was pressed or is being pressed to scroll to the next month(s).
     */
    protected function nextMonthButton_buttonDownEventHandler(event:Event):void
    {
        var target:ButtonBase = event.target as ButtonBase;
        
        // If autoRepeat is true then we get an initial mouseDown and followed by one or more 
        // buttonDown events.  In this case ignore the mouseDown events so it is possible to scroll
        // just one month.
        if (target && target.autoRepeat && event is MouseEvent)
            return;
                
        // For a ltr layout, this button is on the right and for a rtl layout, it is on the left.
        scrollToNextMonth();
    }
    
    /**
     *  @private
     *  The button was presssed or is being pressed to scroll to the previous month(s).
     */
    protected function previousMonthButton_buttonDownEventHandler(event:Event):void
    {
        var target:ButtonBase = event.target as ButtonBase;
        
        // If autoRepeat is true then we get an initial mouseDown and followed by one or more 
        // buttonDown events.  In this case ignore the mouseDown events so it is possible to scroll
        // just one month.
        if (target && target.autoRepeat && event is MouseEvent)
            return;
        
        // For a ltr layout, this button is on the left and for a rtl layout, it is on the right.
        scrollToPreviousMonth();
    }
        
    /**
     *  @private
     *  The month drop-down list was closed so update the displayed date.
     */
    protected function monthDropDropList_closeEventHandler(event:DropDownEvent):void
    {
        if (monthDropDownList.selectedItem != monthNames[_displayedMonth])
        {
            // Can't use the index directly if not every month is in the list.
            // ToDo: check for 12 implies Gregorian calendar
            if (monthDropDownList.dataProvider.length == 12)
            {
                displayedMonth = monthDropDownList.selectedIndex;    
            }
            else
            {
                for (var i:int; i < monthNames.length; i++)
                {
                    if (monthNames[i] == monthDropDownList.selectedItem)
                    {
                        displayedMonth = i;
                        break;
                    }
                }
            }
        }       
    }
    
    /**
     *  @private
     *  The year text input was commited.  If the year is valid, update the displayed date
     *  otherwise restore the prior year in the text input control and cancel the event.
     */
    protected function yearDropDownListBase_changeEventHandler(event:IndexChangeEvent):void
    {
        var selectedYear:Number = Number(yearDropDownListBase.selectedItem);
        const minDate:Date = selectableDates.minDate;
        const maxDate:Date = selectableDates.maxDate;
              
        // Invalid input.  Restore currently displayed year.
        if (isNaN(selectedYear) || 
            selectedYear < minDate.fullYear || selectedYear > maxDate.fullYear)
        {
            yearDropDownListBase.selectedItem = String(displayedYear);
            event.preventDefault();
            return;
        }
        
        displayedYear = selectedYear;
        
        // Year updated.  Make sure the displayedMonth is within the min/Max selectable date range.
        if (minDate.fullYear == _displayedYear && _displayedMonth < minDate.month)        
            displayedMonth = minDate.month;
        
        if (maxDate.fullYear == _displayedYear && _displayedMonth > maxDate.month)        
            displayedMonth = maxDate.month;
    }

    //--------------------------------------------------------------------------
    //
    //  Viewport Property Handlers
    //
    //--------------------------------------------------------------------------
    
    private function viewport_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        switch(event.property) 
        {
            case "contentWidth": 
            case "contentHeight": 
                break;
            
            case "horizontalScrollPosition":
            case "verticalScrollPosition":
                const layout:LayoutBase = dataGroup.layout;
                if (layout)
                {
                    const hsp:Number = dataGroup.horizontalScrollPosition;
                    const vsp:Number = dataGroup.verticalScrollPosition;
                    const index:int = layout.getElementNearestScrollPosition(new Point(hsp, vsp), "topLeft");
                    
                    // Update the displayed date.
                    const date:Date = MonthArrayList.indexToDate(index);
                    displayedYear = date.fullYear;
                    displayedMonth = date.month;
                }
                break;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  MonthGrid Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called when a MonthGrid has been added to the dataGroup of this component.
     *  For a virtual layout, this is not called when a renderer is recycled.
     */
    protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
    {
        //trace(event.type, itemToLabel(event.data), "inView", dataGroup.getItemIndicesInView());

        var renderer:MonthGridItemRenderer = event.renderer as MonthGridItemRenderer;        
        if (!renderer)
            return;
        
        var monthGrid:MonthGrid = renderer.monthGrid; 
        if (!monthGrid)
            return;
            
        monthGrid.addEventListener(MonthGridEvent.MONTH_GRID_MOUSE_DOWN, grid_mouseDownHandler, false, EventPriority.DEFAULT_HANDLER);
        monthGrid.addEventListener(MonthGridEvent.MONTH_GRID_MOUSE_DRAG, grid_mouseDragHandler, false, EventPriority.DEFAULT_HANDLER);
        monthGrid.addEventListener(MonthGridEvent.MONTH_GRID_MOUSE_UP, grid_mouseUpHandler, false, EventPriority.DEFAULT_HANDLER);
        monthGrid.addEventListener(MonthGridEvent.MONTH_GRID_ROLL_OVER, grid_rollOverHandler, false, EventPriority.DEFAULT_HANDLER);
        monthGrid.addEventListener(MonthGridEvent.MONTH_GRID_ROLL_OUT, grid_rollOutHandler, false, EventPriority.DEFAULT_HANDLER);
        monthGrid.addEventListener(FlexEvent.VALUE_COMMIT, monthGrid_eventHandler);
    }
 
    /**
     *  @private
     *  Called when a MonthGrid has been removed from the dataGroup of this component.
     *  For a virtual layout, this is not called when a renderer is recycled.
     */
    protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
    {
        //trace(event.type, "inView", dataGroup.getItemIndicesInView());

        var renderer:MonthGridItemRenderer = event.renderer as MonthGridItemRenderer;        
        if (!renderer)
            return;
        
        var monthGrid:MonthGrid = renderer.monthGrid; 
        if (!monthGrid)
            return;
        
        monthGrid.removeEventListener(MonthGridEvent.MONTH_GRID_MOUSE_DOWN, grid_mouseDownHandler);
        monthGrid.removeEventListener(MonthGridEvent.MONTH_GRID_MOUSE_DRAG, grid_mouseDragHandler);
        monthGrid.removeEventListener(MonthGridEvent.MONTH_GRID_MOUSE_UP, grid_mouseUpHandler);
        monthGrid.removeEventListener(MonthGridEvent.MONTH_GRID_ROLL_OVER, grid_rollOverHandler);
        monthGrid.removeEventListener(MonthGridEvent.MONTH_GRID_ROLL_OUT, grid_rollOutHandler);
        monthGrid.removeEventListener(FlexEvent.VALUE_COMMIT, monthGrid_eventHandler);
    }
         
    /**
     *  Propograte up the VALUE_COMMIT event from MonthGrid.
     */ 
    // FIXME: may not need this anymore
    private function monthGrid_eventHandler(event:Event):void
    {
        if (hasEventListener(event.type))
            dispatchEvent(event);
    }

    /**
     *  @private
     *  This may be the start of a drag selecton so remember the pending anchor.
     */
    protected function grid_mouseDownHandler(event:MonthGridEvent):void
    {
        if (event.isDefaultPrevented())
            return;
    
        const renderer:IDateItemRenderer = event.itemRenderer;
        if (!renderer || !renderer.enabled)
            pendingAnchorDate = null;
        else
            pendingAnchorDate = renderer.date;
    }
   
    /**
     *  @private
     */
    protected function grid_mouseDragHandler(event:MonthGridEvent):void
    {
        if (event.isDefaultPrevented())
            return;
            
        const renderer:IDateItemRenderer = event.itemRenderer;
        if (!renderer || !renderer.enabled)
            return;
        
        const target:MonthGrid = event.monthGrid;
        
        // Typically the anchor is set on mouse up, so if this is the first drag event, set
        // the anchor based on the preceeding mouse down location.
        if (pendingAnchorDate)
        {
            anchorDate = pendingAnchorDate;
            pendingAnchorDate = null;
            dragInProgress = true;            
        }
        
        extendSelection(target, renderer.date);
        
        event.updateAfterEvent();        
    }

    /**
     *  @private
     *  Update the hover indicator.
     */
    protected function grid_rollOverHandler(event:MonthGridEvent):void
    {
        if (event.isDefaultPrevented())
            return;
                
        const target:MonthGrid = event.monthGrid;
                
        target.hoverRowIndex = event.rowIndex;
        target.hoverColumnIndex = event.columnIndex;
        
        event.updateAfterEvent();        
    }
    
    /**
     *  @private
     *  Update the hover indicator.
     */
    protected function grid_rollOutHandler(event:MonthGridEvent):void
    {
        if (event.isDefaultPrevented())
            return;
                
        const target:MonthGrid = event.monthGrid;
        
        target.hoverRowIndex = -1;
        target.hoverColumnIndex = -1;
        
        event.updateAfterEvent();
    }
    
    /**
     *  @private
     *  Selection on mouseUp rather than mouseDown.
     */
    protected function grid_mouseUpHandler(event:MonthGridEvent):void
    {
        if (event.isDefaultPrevented())
            return;
        
        const renderer:IDateItemRenderer = event.itemRenderer;
        const target:MonthGrid = event.monthGrid;
                
        // Complete the drag-select operation.
        // FIXME: drag to dates in next/prev month
        if (dragInProgress)
        {
            if (!renderer || !renderer.enabled)
                clearSelection();
            dragInProgress = false;
            return;
        }
                
        if (!renderer || !renderer.enabled)
            return;
        
        // FIXME: if next or previous month then navigate to that month
        
        const rowIndex:int = renderer.rowIndex;
        const columnIndex:int = renderer.columnIndex;
       
        if (event.ctrlKey)
        {
            // ctrl-click toggles the selection and updates anchor and caret position.
            if (toggleSelection(target, renderer.date))
            {
                // FIXME
                //anchorDate = renderer.date;
                //caretDate = renderer.date;
            }
        }        
        else if (event.shiftKey)
        {
            // shift-click extends the selection from the current anchor and updates the 
            // caret position.
            extendSelection(target, renderer.date);
            // FIXME
                //if (extendSelection(target, renderer.date))
                /*caretDate = renderer.date*/;
        }         
        else if (setSelectedDate(renderer.date))
        {
            // click sets the selection and updates the anchor and caret position.
            anchorDate = renderer.date;
            caretDate = renderer.date;
        }
    } 
}
}