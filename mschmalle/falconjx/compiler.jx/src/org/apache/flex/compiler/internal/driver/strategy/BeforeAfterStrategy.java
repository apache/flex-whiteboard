/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package org.apache.flex.compiler.internal.driver.strategy;

import org.apache.flex.compiler.tree.as.IASNode;
import org.apache.flex.compiler.visitor.IASNodeStrategy;

/**
 * @author Michael Schmalle
 */
public class BeforeAfterStrategy extends ASNodeHandler
{
    private IASNodeStrategy before;
    
    private IASNodeStrategy after;

    public BeforeAfterStrategy()
    {
    }

    public BeforeAfterStrategy(IASNodeStrategy filtered,
            IASNodeStrategy before, IASNodeStrategy after)
    {
        super(filtered);
        this.before = before;
        this.after = after;
    }

    public void handle(IASNode element)
    {
        before(element);
        super.handle(element);
        after(element);
    }

    protected void after(IASNode element)
    {
        if (after != null)
            after.handle(element);
    }

    protected void before(IASNode element)
    {
        if (before != null)
            before.handle(element);
    }

    public IASNodeStrategy getBefore()
    {
        return before;
    }

    public void setBefore(IASNodeStrategy before)
    {
        this.before = before;
    }

    public IASNodeStrategy getAfter()
    {
        return after;
    }

    public void setAfter(IASNodeStrategy after)
    {
        this.after = after;
    }
}
