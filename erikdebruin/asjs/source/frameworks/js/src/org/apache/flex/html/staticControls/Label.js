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

org.apache.flex.html.staticControls.Label = adobe.extend("org.apache.flex.html.staticControls.Label", org.apache.flex.core.UIBase, {

	/**
	 * Constructor: org.apache.flex.html.staticControls.Label()
	 * @constructor
	 */
	init : function()
	{
		/** @type {org.apache.flex.html.staticControls.Label} */
		var self = this;

		self._super(); /* Call to super() was missing in ctor! */

		return self;
	},

    addToParent : function(p)
    {
        this.element = document.createElement("div");
        this.positioner = this.element;
        p.appendChild(this.element);
    },

    get_text : function()
    {
        return this.element.innerHTML;
    },

    set_text : function(s)
    {
        this.element.innerHTML = s;
    }
});

/**
 * Member: org.apache.flex.html.staticControls.Label.prototype._CLASS
 * @const
 * @type {org.apache.flex.html.staticControls.Label}
 */
org.apache.flex.html.staticControls.Label.prototype._CLASS = org.apache.flex.html.staticControls.Label;

/**
 * Member: org.apache.flex.html.staticControls.Label._PACKAGE
 * @const
 * @type {org.apache.flex.html.staticControls.Label}
 */
org.apache.flex.html.staticControls.Label._PACKAGE = org.apache.flex.html.staticControls;

/**
 * Member: org.apache.flex.html.staticControls.Label._NAME
 * @const
 * @type {string}
 */
org.apache.flex.html.staticControls.Label._NAME = "org.apache.flex.html.staticControls.Label";

/**
 * Member: org.apache.flex.html.staticControls.Label._FULLNAME
 * @const
 * @type {string}
 */
org.apache.flex.html.staticControls.Label._FULLNAME = "org.apache.flex.html.staticControls.Label";

/**
 * Member: org.apache.flex.html.staticControls.Label._SUPER
 * @const
 * @type {Object}
 */
org.apache.flex.html.staticControls.Label._SUPER = Object;

/**
 * Member: org.apache.flex.html.staticControls.Label._NAMESPACES
 * @const
 * @type {Object}
 */
org.apache.flex.html.staticControls.Label._NAMESPACES = {};

adobe.classes["org.apache.flex.html.staticControls.Label"]  = org.apache.flex.html.staticControls.Label;
