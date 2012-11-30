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

org.apache.flex.core.Application = adobe.extend("org.apache.flex.core.Application", adobe, {

	/**
	 * Constructor: org.apache.flex.core.Application()
	 * @constructor
	 */
	init : function()
	{
		/** @type {org.apache.flex.core.Application} */
		var self = this;

		self._super(); /* Call to super() was missing in ctor! */

		return self;
	},

    queuedListeners : undefined,

    addEventListener : function(type, handler)
    {
        // at contructor time, the element may not be available yet
        if (typeof this.element == "undefined")
        {
            if (typeof this.queuedListeners == "undefined")
                this.queuedListeners = [];
            this.queuedListeners.push ({ type: type, handler: handler});
            return;
        }

        if (typeof this.element.attachEvent == "function")
            this.element.attachEvent(adobe.eventMap[type], handler);
        else if (typeof this.element.addEventListener == "function")
        {
            this.element.addEventListener(type, handler);
        }
    },

    start : function()
    {
		/** @type {org.apache.flex.core.Application} */
		var self = this;

        this.element = document.getElementsByTagName('body')[0];

        if (typeof this.queuedListeners != "undefined")
        {
            var n = this.queuedListeners.length;
            for (var i = 0; i < n; i++)
            {
                var q = this.queuedListeners[i];
                this.addEventListener(q.type, q.handler);
            }
        }

        self.valuesImpl = new self.valuesImplClass;
        org.apache.flex.core.ValuesManager.valuesImpl = self.valuesImpl;

        self.initialView = new self.initialViewClass;
        self.initialView.addToParent(this.element);
        self.initialView.initUI(self);
        // create the event
        var evt = document.createEvent('Event');
        // define that the event name is `build`
        evt.initEvent('viewChanged', true, true);

        // elem is any element
        this.element.dispatchEvent(evt);
    }
});

/**
 * Member: org.apache.flex.core.Application.prototype._CLASS
 * @const
 * @type {org.apache.flex.core.Application}
 */
org.apache.flex.core.Application.prototype._CLASS = org.apache.flex.core.Application;

/**
 * Member: org.apache.flex.core.Application._PACKAGE
 * @const
 * @type {org.apache.flex.core.Application}
 */
org.apache.flex.core.Application._PACKAGE = org.apache.flex.core;

/**
 * Member: org.apache.flex.core.Application._NAME
 * @const
 * @type {string}
 */
org.apache.flex.core.Application._NAME = "org.apache.flex.core.Application";

/**
 * Member: org.apache.flex.core.Application._FULLNAME
 * @const
 * @type {string}
 */
org.apache.flex.core.Application._FULLNAME = "org.apache.flex.core.Application";

/**
 * Member: org.apache.flex.core.Application._SUPER
 * @const
 * @type {Object}
 */
org.apache.flex.core.Application._SUPER = Object;

/**
 * Member: org.apache.flex.core.Application._NAMESPACES
 * @const
 * @type {Object}
 */
org.apache.flex.core.Application._NAMESPACES = {};

adobe.classes["org.apache.flex.core.Application"]  = org.apache.flex.core.Application;
