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

flash.events.EventDispatcher = adobe.extend("flash.events.EventDispatcher", adobe, {
	/**
	 * Constructor: flash.events.EventDispatcher()
	 * @constructor
	 */
	init : function()
	{
		/** @type {flash.events.EventDispatcher} */
		var self = this;

		self._super(); /* Call to super() was missing in ctor! */

		return self;
	},

    listeners : {},

    addEventListener : function(type, handler)
    {
        if (typeof this.listeners.type === "undefined")
            this.listeners[type] = [];

        this.listeners[type].push(handler);
    },

    dispatchEvent : function(event)
    {
        var self = this;
        var type = event.type;
        if (typeof this.listeners[type] !== "undefined")
        {
            var arr = this.listeners[type];
            var n = arr.length;
            for (var i = 0; i < n; i++)
                arr[i](event);
        }
    }
});

/**
 * Member: flash.events.EventDispatcher.prototype._CLASS
 * @const
 * @type {flash.events.EventDispatcher}
 */
flash.events.EventDispatcher.prototype._CLASS = flash.events.EventDispatcher;

/**
 * Member: flash.events.EventDispatcher._PACKAGE
 * @const
 * @type {flash.events.EventDispatcher}
 */
flash.events.EventDispatcher._PACKAGE = flash.events;

/**
 * Member: flash.events.EventDispatcher._NAME
 * @const
 * @type {string}
 */
flash.events.EventDispatcher._NAME = "flash.events.EventDispatcher";

/**
 * Member: flash.events.EventDispatcher._FULLNAME
 * @const
 * @type {string}
 */
flash.events.EventDispatcher._FULLNAME = "flash.events.EventDispatcher";

/**
 * Member: flash.events.EventDispatcher._SUPER
 * @const
 * @type {Object}
 */
flash.events.EventDispatcher._SUPER = Object;

/**
 * Member: flash.events.EventDispatcher._NAMESPACES
 * @const
 * @type {Object}
 */
flash.events.EventDispatcher._NAMESPACES = {};

adobe.classes["flash.events.EventDispatcher"]  = flash.events.EventDispatcher;
