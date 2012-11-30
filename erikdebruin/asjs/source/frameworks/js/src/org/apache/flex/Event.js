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

flash.events.Event = adobe.extend("flash.events.Event", adobe, {
	/**
	 * Constructor: flash.events.Event()
	 * @constructor
	 */
	init : function (type) {
		/** @type {flash.events.Event} */
		var self = this;

		self._super(); /* Call to super() was missing in ctor! */

        self.type = type;
		return self;
	},

    type: undefined
});

/**
 * Member: flash.events.Event.prototype._CLASS
 * @const
 * @type {flash.events.Event}
 */
flash.events.Event.prototype._CLASS = flash.events.Event;

/**
 * Member: flash.events.Event._PACKAGE
 * @const
 * @type {flash.events.Event}
 */
flash.events.Event._PACKAGE = flash.events;

/**
 * Member: flash.events.Event._NAME
 * @const
 * @type {string}
 */
flash.events.Event._NAME = "flash.events.Event";

/**
 * Member: flash.events.Event._FULLNAME
 * @const
 * @type {string}
 */
flash.events.Event._FULLNAME = "flash.events.Event";

/**
 * Member: flash.events.Event._SUPER
 * @const
 * @type {Object}
 */
flash.events.Event._SUPER = Object;

/**
 * Member: flash.events.Event._NAMESPACES
 * @const
 * @type {Object}
 */
flash.events.Event._NAMESPACES = {};

adobe.classes["flash.events.Event"]  = flash.events.Event;
