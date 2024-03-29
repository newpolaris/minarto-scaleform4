﻿/**
 * The CLIK ScrollIndicator displays the scroll position of another component, such as a multiline textField. It can be pointed at a textField to automatically display its scroll position. All list-based components as well as the TextArea have a scrollBar property which can be pointed to a ScrollIndicator or ScrollBar instance or linkage ID. 
    
    <b>Inspectable Properties</b>
    The inspectable properties of the ScrollIndicator are:
    <ul>
        <li><i>scrollTarget</i>: Set a TextArea or normal multiline textField as the scroll target to automatically respond to scroll events. Non-text field types have to manually update the ScrollIndicator properties.</li>
        <li><i>visible</i>: Hides the component if set to false.</li>
        <li><i>enabled</i>: Disables the component if set to false.</li>
        <li><i>offsetTop</i>: Thumb offset at the top. A positive value moves the thumb's top-most position higher.</li>
        <li><i>offsetBottom</i>: Thumb offset at the bottom. A positive value moves the thumb's bottom-most position lower.</li>
    </ul>
    
    <b>States</b> 
    The ScrollIndicator does not have explicit states. It uses the states of its child elements, the thumb and track Button components.    
    
     <b>Events</b>
    All event callbacks receive a single Event parameter that contains relevant information about the event. The following properties are common to all events. <ul>
    <li><i>type</i>: The event type.</li>
    <li><i>target</i>: The target that generated the event.</li></ul>
        
    The events generated by the ScrollIndicator component are listed below. The properties listed next to the event are provided in addition to the common properties.
    <ul>
        <li><i>ComponentEvent.SHOW</i>: The visible property has been set to true at runtime.</li>
        <li><i>ComponentEvent.HIDE</i>: The visible property has been set to false at runtime.</li>
        <li><i>Event.SCROLL</i>: The scroll position has changed.</li>
    </ul>
 */

/**************************************************************************

Filename    :   ScrollIndicator.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.controls {
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.text.TextField;
    
    import scaleform.clik.constants.ScrollBarDirection;
    import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.controls.Button;
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.events.ComponentEvent;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.interfaces.IScrollBar;
    import scaleform.clik.ui.InputDetails;
    
    [Event(name="scroll", type="flash.events.Event")]
    
    public class ScrollIndicator extends UIComponent implements IScrollBar {
        
    // Constants:
        
    // Public Properties:
        /** The direction of the scroll bar. Valid values are ScrollBarDirection.VERTICAL / ScrollBarDirection.HORIZONTAL. */
        public var direction:String = ScrollBarDirection.VERTICAL;
        /** Thumb offset at the top. A positive value moves the thumb's top-most position higher. */
        [Inspectable(defaultValue="0")]
        public var offsetTop:Number = 0;
        /** Thumb offset at the bottom. A positive value moves the thumb's bottom-most position lower. */
        [Inspectable(defaultValue="0")]
        public var offsetBottom:Number = 0;
        
    // Protected Properties:
        protected var _isDragging:Boolean = false;
        protected var _maxPosition:Number = 10;
        protected var _minPosition:Number = 0;
        protected var _minThumbSize:Number = 10;
        protected var _pageScrollSize:Number = 1;
        protected var _pageSize:Number;
        protected var _position:Number = 5;
        protected var _scrollTarget:Object;
        
    // UI Elements:
        /** A reference to the thumb symbol in the ScrollIndicator. */
        public var thumb:MovieClip;
        /** A reference to the track symbol in the ScrollIndicator. */
        public var track:MovieClip;
        
    // Initialization:
        public function ScrollIndicator() {
            super();
        }
        
        override protected function initialize():void {
            super.initialize();
        }
        
    // Public Getter / Setters:
        /**
         * Enables or disables the component. Disabled components should not receive mouse, keyboard, or any 
         * other kind of focus or interaction.
         */
        [Inspectable(defaultValue="true")]
        override public function get enabled():Boolean { return super.enabled; }
        override public function set enabled(value:Boolean):void {
            if (value == super.enabled) { return; }
            super.enabled = value;
            gotoAndPlay(enabled ? "default" : "disabled"); // setState?
        }
        
        /**
         * The current position of the ScrollIndicator.
         */
        public function get position():Number { return _position; }
        public function set position(value:Number):void {
            value = Math.max(_minPosition, Math.min(_maxPosition, value));
            if (value == _position) { return; }
            _position = value;
            dispatchEvent(new Event(Event.SCROLL));
            invalidateData();
        }
        
        /**
         * The minimum size for the thumb.
         */
        [Inspectable(type="Number", defaultValue="10")]
        public function get minThumbSize():Number { return _minThumbSize; }
        public function set minThumbSize(value:Number):void {
            value = Math.max(1, value);
            _minThumbSize = value;
            invalidateSize();
        }
        
        public function get isHorizontal():Boolean { return direction == ScrollBarDirection.HORIZONTAL; }
        
        [Inspectable(type="String", defaultValue="")]
        public function get scrollTarget():Object { return _scrollTarget; }
        public function set scrollTarget(value:Object):void {
            if (value is String) {
                if (!componentInspectorSetting || value.toString() == "" || parent == null) { return; }
                value = parent.getChildByName(value.toString());
                if (value == null) { return; }
            }
            
            var oldTarget:Object = _scrollTarget;
            _scrollTarget = value;
            
            if (oldTarget != null) {
                oldTarget.removeEventListener(Event.SCROLL, handleTargetScroll, false);
                if (oldTarget.scrollBar != null) { oldTarget.scrollBar = null; }
                // focusTarget = null;
                // oldTarget.noAutoSelection = false; // @TODO: Look at replacing for AS3.
            }
            
            // Check if the scrollTarget is on a component, and if it has a scrollBar property (like a List)
            if (value is UIComponent && "scrollBar" in value) {
                value.scrollBar = this;
                return;
            }
            
            if (_scrollTarget == null) { 
                tabEnabled = true;
                return; 
            }
            
            _scrollTarget.addEventListener(Event.SCROLL, handleTargetScroll, false, 0, true);
            
            //_scrollTarget.noAutoSelection = true; // @TODO: Look at replacing for AS3.
            if (_scrollTarget is UIComponent) { focusTarget = _scrollTarget as UIComponent; }
            tabEnabled = false;
            handleTargetScroll(null);
            
            invalidate();
        }
        
        /**
         * Returns the available scrolling height of the component.
         */
        public function get availableHeight():Number {
            // thumbHeight may not be valid on the first invalidation.
            var thumbHeight:Number = isNaN(thumb.height) ? 0 : thumb.height;
            return (isHorizontal ? _width : _height) - thumbHeight + offsetBottom + offsetTop;
        }
        
    // Public Methods:
        /**
         * Set the scroll properties of the component.
         * @param pageSize The size of the pages to determine scroll distance.
         * @param minPosition The minimum scroll position.
         * @param maxPosition The maximum scroll position.
         * @param pageScrollSize The amount to scroll when "paging". Not currently implemented.
         */
        public function setScrollProperties(pageSize:Number, minPosition:Number, maxPosition:Number, pageScrollSize:Number = NaN):void {
            this._pageSize = pageSize;
            if (!isNaN(pageScrollSize)) { this._pageScrollSize = pageScrollSize; }
            this._minPosition = minPosition;
            this._maxPosition = maxPosition;
            
            invalidateSize();
        }
        
        /** @exclude */
        override public function handleInput(event:InputEvent):void {
            if (event.handled) { return; }
            var details:InputDetails = event.details;
            if (details.value == InputValue.KEY_UP) { return; } // Allow key-down and key-press
            var isHorizontal:Boolean = (direction == ScrollBarDirection.HORIZONTAL);
            switch (details.navEquivalent) {
                case NavigationCode.UP:
                    if (isHorizontal) { return; }
                    position -= 1;
                    break;
                case NavigationCode.DOWN:
                    if (isHorizontal) { return; }
                    position += 1;
                    break;
                case NavigationCode.LEFT:
                    if (!isHorizontal) { return; }
                    position -= 1;
                    break;
                case NavigationCode.RIGHT:
                    if (!isHorizontal) { return; }
                    position += 1;
                    break;
                case NavigationCode.HOME:
                    position = 0;
                    break;
                case NavigationCode.END:
                    position = _maxPosition;
                    break;
                default:
                    return;
            }
            event.handled = true;
        }
        
        /** @exclude */
        override public function toString():String {
            return "[CLIK ScrollIndicator " + name + "]";
        }
        
    // Protected Methods:
        override protected function configUI():void { 
            super.configUI();
            
            focusable = false;
            mouseChildren = mouseEnabled = false;
            
            if (track == null) { track = new MovieClip(); } // Do not add to stage, this is just to avoid having to constantly check for it.
            thumb.enabled = enabled;
            
            initSize();
            direction = (rotation != 0 && rotation != 180) ? ScrollBarDirection.HORIZONTAL : ScrollBarDirection.VERTICAL; //LM: Test 180º
        }
        
        override protected function draw():void {
            if (isInvalid(InvalidationType.SIZE)) {
                // Ensure that the size is up to date before updating the layout and thumb.
                setActualSize(_width, _height);
                drawLayout();
                updateThumb();
            } else if (isInvalid(InvalidationType.DATA)) { // DATA refers to POSITION only
                if (_scrollTarget is TextField) {
                    var target:TextField = _scrollTarget as TextField;
                    setScrollProperties(target.bottomScrollV - target.scrollV, 1, target.maxScrollV);
                }
                updateThumbPosition();
            }
        }
        
        protected function drawLayout():void {
            track.height = isHorizontal ? _width : _height;
            if (track is UIComponent) { track.validateNow(); }
        }
        
        protected function updateThumb():void {
            var per:Number = Math.max(1, _maxPosition - _minPosition + _pageSize);
            var trackHeight:Number = (isHorizontal ? _width : _height) + offsetTop + offsetBottom;
            thumb.height = Math.max(_minThumbSize, Math.min(_height, _pageSize / per * trackHeight));
            if (thumb is UIComponent) { (thumb as UIComponent).validateNow(); }
            updateThumbPosition();
        }
        
        protected function updateThumbPosition():void {
            var percent:Number = (_position - _minPosition) / (_maxPosition - _minPosition);
            if (isNaN(percent)) { percent = 0; } // In the case that the _maxPosition == _minPosition.
            var yPos:Number = percent * availableHeight;
            thumb.y = Math.max( -offsetTop, Math.min(availableHeight - offsetTop, yPos) );
            thumb.visible = !((_maxPosition == _minPosition) || isNaN(_pageSize) || _maxPosition == 0);
        }
        
        // The scrollTarget TextField has changed its scroll position. 
        protected function handleTargetScroll(event:Event):void {
            if (_isDragging) { return; } // Don't listen for scroll events while the thumb is dragging.
            var target:TextField = _scrollTarget as TextField;
            if (target != null) {
                setScrollProperties(target.bottomScrollV - target.scrollV, 1, target.maxScrollV);
                position = target.scrollV;
            }
        }
    }
}