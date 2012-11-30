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

org.apache.flex.binding.SimpleBinding = adobe.extend("org.apache.flex.binding.SimpleBinding", adobe, {
	/**
	 * Constructor: org.apache.flex.binding.SimpleBinding()
	 * @constructor
	 */
	init : function()
	{
		/** @type {org.apache.flex.binding.SimpleBinding} */
		var self = this;

		self._super(); /* Call to super() was missing in ctor! */

		return self;
	},

    source: null,
    sourcePropertyName: null,
    eventName: null,
    destination: null,
    destinationPropertyName: null,

    changeHandler: function () {
		/** @type {org.apache.flex.binding.SimpleBinding} */
		var self = this;

        self.destination["set_" + self.destinationPropertyName](self.source["get_" + self.sourcePropertyName]());
    },

    initialize: function (){
		/** @type {org.apache.flex.binding.SimpleBinding} */
		var self = this;

        self.source.addEventListener(self.eventName, adobe.createProxy(self, self.changeHandler));
        self.destination["set_" + self.destinationPropertyName](self.source["get_" + self.sourcePropertyName]());
    }
});

/**
 * Member: org.apache.flex.binding.SimpleBinding.prototype._CLASS
 * @const
 * @type {org.apache.flex.binding.SimpleBinding}
 */
org.apache.flex.binding.SimpleBinding.prototype._CLASS = org.apache.flex.binding.SimpleBinding;

/**
 * Member: org.apache.flex.binding.SimpleBinding._PACKAGE
 * @const
 * @type {org.apache.flex.binding.SimpleBinding}
 */
org.apache.flex.binding.SimpleBinding._PACKAGE = org.apache.flex.binding;

/**
 * Member: org.apache.flex.binding.SimpleBinding._NAME
 * @const
 * @type {string}
 */
org.apache.flex.binding.SimpleBinding._NAME = "org.apache.flex.binding.SimpleBinding";

/**
 * Member: org.apache.flex.binding.SimpleBinding._FULLNAME
 * @const
 * @type {string}
 */
org.apache.flex.binding.SimpleBinding._FULLNAME = "org.apache.flex.binding.SimpleBinding";

/**
 * Member: org.apache.flex.binding.SimpleBinding._SUPER
 * @const
 * @type {Object}
 */
org.apache.flex.binding.SimpleBinding._SUPER = Object;

/**
 * Member: org.apache.flex.binding.SimpleBinding._NAMESPACES
 * @const
 * @type {Object}
 */
org.apache.flex.binding.SimpleBinding._NAMESPACES = {};

adobe.classes["org.apache.flex.binding.SimpleBinding"]  = org.apache.flex.binding.SimpleBinding;
