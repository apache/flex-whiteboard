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

org.apache.flex.core.ViewBase = adobe.extend("org.apache.flex.core.ViewBase", org.apache.flex.core.UIBase, {

	/**
	 * Constructor: org.apache.flex.core.ViewBase()
	 * @constructor
	 */
	init : function()
	{
		/** @type {org.apache.flex.core.ViewBase} */
		var self = this;

		self._super(); /* Call to super() was missing in ctor! */

		return self;
	},

    addToParent : function(p)
    {
        this.element = document.createElement("div");
        p.appendChild(this.element);
    },

    initUI: function(app)
    {
		/** @type {org.apache.flex.core.ViewBase} */
		var self = this;

        // cache this for speed
        var descriptors = self.get_uiDescriptors();

        var n = descriptors.length;
        var i = 0;

        var value;
        var valueName;

        while (i < n)
        {
            var c = descriptors[i++];					// class
            var o = new c();
            o.addToParent(this.element);
            c = descriptors[i++];							// model
            if (c)
            {
                value = new c();
                o.addBead(value);
            }
            if (typeof o.initModel == "function")
                o.initModel();
            var j;
            var m;
            valueName = descriptors[i++];					// id
            if (valueName)
                this[valueName] = o;

            m = descriptors[i++];							// num props
            for (j = 0; j < m; j++)
            {
                valueName = descriptors[i++];
                value = descriptors[i++];
                o["set_" + valueName](value);
            }
            m = descriptors[i++];							// num beads
            for (j = 0; j < m; j++)
            {
                c = descriptors[i++];
                value = new c();
                o.addBead(value);
            }
            if (typeof o.initSkin == "function")
                o.initSkin();
            m = descriptors[i++];							// num events
            for (j = 0; j < m; j++)
            {
                valueName = descriptors[i++];
                value = descriptors[i++];
                o.addEventListener(valueName, adobe.createProxy(this, value));
            }
            m = descriptors[i++];							// num bindings
            for (j = 0; j < m; j++)
            {
                valueName = descriptors[i++];
                var bindingType = descriptors[i++];
                switch (bindingType)
                {
                    case 0:
                        var sb = new org.apache.flex.binding.SimpleBinding();
                        sb.destination = o;
                        sb.destinationPropertyName = valueName;
                        sb.source = app[descriptors[i++]];
                        sb.sourcePropertyName = descriptors[i++];
                        sb.eventName = descriptors[i++];
                        sb.initialize();
                }
            }
        }
    }
});

/**
 * Member: org.apache.flex.core.ViewBase.prototype._CLASS
 * @const
 * @type {org.apache.flex.core.ViewBase}
 */
org.apache.flex.core.ViewBase.prototype._CLASS = org.apache.flex.core.ViewBase;

/**
 * Member: org.apache.flex.core.ViewBase._PACKAGE
 * @const
 * @type {org.apache.flex.core.ViewBase}
 */
org.apache.flex.core.ViewBase._PACKAGE = org.apache.flex.core;

/**
 * Member: org.apache.flex.core.ViewBase._NAME
 * @const
 * @type {string}
 */
org.apache.flex.core.ViewBase._NAME = "org.apache.flex.core.ViewBase";

/**
 * Member: org.apache.flex.core.ViewBase._FULLNAME
 * @const
 * @type {string}
 */
org.apache.flex.core.ViewBase._FULLNAME = "org.apache.flex.core.ViewBase";

/**
 * Member: org.apache.flex.core.ViewBase._SUPER
 * @const
 * @type {Object}
 */
org.apache.flex.core.ViewBase._SUPER = Object;

/**
 * Member: org.apache.flex.core.ViewBase._NAMESPACES
 * @const
 * @type {Object}
 */
org.apache.flex.core.ViewBase._NAMESPACES = {};

adobe.classes["org.apache.flex.core.ViewBase"]  = org.apache.flex.core.ViewBase;
