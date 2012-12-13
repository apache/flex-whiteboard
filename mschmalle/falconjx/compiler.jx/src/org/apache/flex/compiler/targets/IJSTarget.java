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

package org.apache.flex.compiler.targets;

import java.util.Collection;

import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.js.IJSApplication;

/**
 * @author Michael Schmalle
 */
public interface IJSTarget extends ITarget
{

    /**
     * Build the target JavaScript application and collect problems. Every time
     * the method is called, a new IJSApplication model is created.
     * 
     * @param problems compilation problems output
     * @return IJSApplication if build is success
     */
    IJSApplication build(Collection<ICompilerProblem> problems);
}
