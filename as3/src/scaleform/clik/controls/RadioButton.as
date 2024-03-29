﻿/**
 * RadioButton is a button component that usually belongs in a set to display and change a single value. Only one RadioButton in a set can be selected at one time, and clicking another RadioButton in the set selects the new component and deselects the previously selected component.
 
    The CLIK RadioButton is very similar to the CheckBox component and shares its functionality, states and behavior. The main difference is that the RadioButton supports a group property, to which a custom ButtonGroup can be assigned. RadioButton also does not inherently set its toggle property since toggling is performed by the ButtonGroup instance that manages it.

    <b>Inspectable Properties</b>
    Since it derives from the Button control, the RadioButton contains the same inspectable properties as the Button with the omission of the toggle and disableFocus properties.
    <ul>
        <li><i>autoRepeat</i>: Determines if the button dispatches "click" events when pressed down and held. </li>
        <li><i>autoSize</i>: Determines if the button will scale to fit the text that it contains and which direction to align the resized button. Setting the autoSize property to {@code autoSize="none"} will leave its current size unchanged.</li>
        <li><i>data</i>: Data related to the button. This property is particularly helpful when using butons in a ButtonGroup. </li>
        <li><i>enabled</i>: Disables the button if set to false.</li>
        <li><i>focusable</i>: By default buttons receive focus for user interactions. Setting this property to false will disable focus acquisition.</li>
        <li><i>label</i>: Sets the label of the Button.</li>
        <li><i>selected</i>: Set the selected state of the Button. Buttons can have two sets of mouse states, a selected and unselected.  When a Button's {@code toggle} property is {@code true} the selected state will be changed when the button is clicked, however the selected state can be set using ActionScript even if the toggle property is false.</li>
        <li><i>toggle</i>: Sets the toggle property of the Button. If set to true, the Button will act as a toggle button.</li>
        <li><i>visible</i>: Hides the button if set to false.</li>
    </ul>
        
    <b>States</b>
    Since the RadioButton is able to toggle between selected and unselected states, it, similar the CheckBox, requires at least the following states:
    <ul>
        <li>an up or default state.</li>
        <li>an over state when the mouse cursor is over the component, or when it is focused.</li>
        <li>a down state when the button is pressed.</li>
        <li>a disabled state.</li>
        <li>a selected_up or default state.</li>
        <li>a selected_over state when the mouse cursor is over the component, or when it is focused.</li>
        <li>a selected_down state when the button is pressed.</li>
        <li>a selected_disabled state.</li>
    </ul>
    
    These are the minimal set of keyframes that should be in a RadioButton. The extended set of states and keyframes supported by the Button component, and consequently the RadioButton component, are described in the Getting Started with CLIK Buttons document.
    
    <b>Events</b>
    All event callbacks receive a single Event parameter that contains relevant information about the event. The following properties are common to all events. <ul>
    <li><i>type</i>: The event type.</li>
    <li><i>target</i>: The target that generated the event.</li></ul>
        
    The events generated by the RadioButton component are listed below. The properties listed next to the event are provided in addition to the common properties.<ul>
    <ul>
        <li><i>ComponentEvent.SHOW</i>: The visible property has been set to true at runtime.</li>
        <li><i>ComponentEvent.HIDE</i>: The visible property has been set to false at runtime.</li>
        <li><i>ComponentEvent.STATE_CHANGE</i>: The button's state has changed.</li>
        <li><i>FocusHandlerEvent.FOCUS_IN</i>: The button has received focus.</li>
        <li><i>FocusHandlerEvent.FOCUS_OUT</i>: The button has lost focus.</li>
        <li><i>Event.SELECT</i>: The selected property has changed.</li>
        <li><i>ButtonEvent.PRESS</i>: The button has been pressed.</li>
        <li><i>ButtonEvent.CLICK</i>: The button has been clicked.</li>
        <li><i>ButtonEvent.DRAG_OVER</i>: The mouse cursor has been dragged over the button (while the left mouse button is pressed).</li>
        <li><i>ButtonEvent.DRAG_OUT</i>: The mouse cursor has been dragged out of the button (while the left mouse button is pressed).</li>
        <li><i>ButtonEvent.RELEASE_OUTSIDE</i>: The mouse cursor has been dragged out of the button and the left mouse button has been released.</li>
    </ul>
*/

/**************************************************************************

Filename    :   RadioButton.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.controls {
    
    import scaleform.clik.controls.Button;
    
    import flash.events.MouseEvent;
    
    public class RadioButton extends Button {
        
    // Constants:
        public static const DEFAULT_GROUPNAME:String = "default";
        
    // Public Properties:
        
    // Protected Properties:
        
    // Initialization:
        public function RadioButton() {
            super();
        }
        
        override protected function initialize():void {
            super.initialize();
            toggle = true;
            allowDeselect = false;
            if (_group == null) { 
                groupName = DEFAULT_GROUPNAME;
            }
        }
        
    // Public getter / setters:
        // ** Override inspectables from base class
        override public function get autoRepeat():Boolean { return false; }
        override public function set autoRepeat(value:Boolean):void { }
        override public function get toggle():Boolean { return true; }
        override public function set toggle(value:Boolean):void { }
        
        // ** Expose groupName as inspectable
        [Inspectable(defaultValue="")]
        override public function get groupName():String { return super.groupName; }
        override public function set groupName(value:String):void {
            super.groupName = value;
        }
        
    // Public Methods:
        /** @exclude */
        override public function toString():String {
            return "[CLIK RadioButton " + name + "]";
        }
    }
}