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

"use strict";

org.apache.flex.html.staticControls.TextButton = adobe.extend("org.apache.flex.html.staticControls.TextButton", org.apache.flex.core.UIBase, {
	/**
	 * Constructor: org.apache.flex.html.staticControls.TextButton()
	 * @constructor
	 */
	init: function () {
		/** @type {org.apache.flex.html.staticControls.TextButton} */
		var self = this;

		self._super(); /* Call to super() was missing in ctor! */

		return self;
	},

    addToParent: function (p) {
        this.positioner = document.createElement("input");
        this.element = this.positioner;
        this.element.setAttribute("type", "button");
        p.appendChild(this.positioner);
    },

    get_text: function () {
        return this.element.getAttribute("value");
    },

    set_text: function (s) {
        this.element.setAttribute("value", s);
    }
});

/**
 * Member: org.apache.flex.html.staticControls.TextButton.prototype._CLASS
 * @const
 * @type {org.apache.flex.html.staticControls.TextButton}
 */
org.apache.flex.html.staticControls.TextButton.prototype._CLASS = org.apache.flex.html.staticControls.TextButton;

/**
 * Member: org.apache.flex.html.staticControls.TextButton._PACKAGE
 * @const
 * @type {org.apache.flex.html.staticControls.TextButton}
 */
org.apache.flex.html.staticControls.TextButton._PACKAGE = org.apache.flex.html.staticControls;

/**
 * Member: org.apache.flex.html.staticControls.TextButton._NAME
 * @const
 * @type {string}
 */
org.apache.flex.html.staticControls.TextButton._NAME = "org.apache.flex.html.staticControls.TextButton";

/**
 * Member: org.apache.flex.html.staticControls.TextButton._FULLNAME
 * @const
 * @type {string}
 */
org.apache.flex.html.staticControls.TextButton._FULLNAME = "org.apache.flex.html.staticControls.TextButton";

/**
 * Member: org.apache.flex.html.staticControls.TextButton._SUPER
 * @const
 * @type {Object}
 */
org.apache.flex.html.staticControls.TextButton._SUPER = Object;

/**
 * Member: org.apache.flex.html.staticControls.TextButton._NAMESPACES
 * @const
 * @type {Object}
 */
org.apache.flex.html.staticControls.TextButton._NAMESPACES = {};

adobe.classes["org.apache.flex.html.staticControls.TextButton"]  = org.apache.flex.html.staticControls.TextButton;
