/**
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

org.apache.flex.core.UIBase = adobe.extend("org.apache.flex.core.UIBase", adobe, {

	/**
	 * Constructor: org.apache.flex.core.UIBase()
	 * @constructor
	 */
	init : function()
	{
		/** @type {org.apache.flex.core.UIBase} */
		var self = this;

		self._super(); /* Call to super() was missing in ctor! */

		return self;
	},

    addEventListener : function(type, handler)
    {
        if (typeof this.element.attachEvent == "function")
            this.element.attachEvent(adobe.eventMap[type], handler);
        else if (typeof this.element.addEventListener == "function")
            this.element.addEventListener(type, handler);
    },

    dispatchEvent : function(evt)
    {
		/** @type {org.apache.flex.core.UIBase} */
		var self = this;

        // elem is any element
        this.element.dispatchEvent(evt);
    },

    set_x : function(n)
    {
        this.positioner.style.position = "absolute";
        this.positioner.style.left = n.toString() + "px";
    },

    set_y : function(n)
    {
        this.positioner.style.position = "absolute";
        this.positioner.style.top = n.toString() + "px";
    }
});

/**
 * Member: org.apache.flex.core.UIBase.prototype._CLASS
 * @const
 * @type {org.apache.flex.core.UIBase}
 */
org.apache.flex.core.UIBase.prototype._CLASS = org.apache.flex.core.UIBase;

/**
 * Member: org.apache.flex.core.UIBase._PACKAGE
 * @const
 * @type {org.apache.flex.core.UIBase}
 */
org.apache.flex.core.UIBase._PACKAGE = org.apache.flex.core;

/**
 * Member: org.apache.flex.core.UIBase._NAME
 * @const
 * @type {string}
 */
org.apache.flex.core.UIBase._NAME = "org.apache.flex.core.UIBase";

/**
 * Member: org.apache.flex.core.UIBase._FULLNAME
 * @const
 * @type {string}
 */
org.apache.flex.core.UIBase._FULLNAME = "org.apache.flex.core.UIBase";

/**
 * Member: org.apache.flex.core.UIBase._SUPER
 * @const
 * @type {Object}
 */
org.apache.flex.core.UIBase._SUPER = Object;

/**
 * Member: org.apache.flex.core.UIBase._NAMESPACES
 * @const
 * @type {Object}
 */
org.apache.flex.core.UIBase._NAMESPACES = {};

adobe.classes["org.apache.flex.core.UIBase"]  = org.apache.flex.core.UIBase;
