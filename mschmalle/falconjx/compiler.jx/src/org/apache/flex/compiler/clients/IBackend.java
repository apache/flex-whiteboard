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

package org.apache.flex.compiler.clients;

import java.io.File;
import java.util.List;

import org.apache.flex.compiler.config.Configurator;
import org.apache.flex.compiler.internal.js.codgen.ASBlockWalker;
import org.apache.flex.compiler.internal.js.codgen.JSFilterWriter;
import org.apache.flex.compiler.internal.js.codgen.JSWriter;
import org.apache.flex.compiler.internal.projects.ISourceFileHandler;
import org.apache.flex.compiler.internal.targets.JSTarget;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.projects.IASProject;
import org.apache.flex.compiler.projects.ICompilerProject;
import org.apache.flex.compiler.targets.ITargetProgressMonitor;
import org.apache.flex.compiler.targets.ITargetSettings;
import org.apache.flex.compiler.units.ICompilationUnit;

/**
 * The backend strategy for the {@link MXMLJSC} javascript compiler.
 * 
 * @author Michael Schmalle
 */
public interface IBackend
{
    /**
     * Returns the instance that is used to manage what type of
     * {@link ICompilationUnit} is created during parsing.
     * 
     * @return The implemented {@link ISourceFileHandler}.
     */
    ISourceFileHandler getSourceFileHandlerInstance();

    /**
     * Returns the {@link File} extension used when saving compiled code.
     */
    String getOutputExtension();

    /**
     * Creates a {@link Configurator} for the specific compile session.
     */
    Configurator createConfigurator();

    /**
     * Creates a javascript target that will be used to build the compiled
     * javascript source file.
     * 
     * @param project The current {@link ICompilerProject}.
     * @param settings The target's custom settings.
     * @param monitor The compilation monitor used during asynchronous parsing
     * of {@link ICompilationUnit}s.
     * @return A new {@link JSTarget} used during compilation.
     */
    JSTarget createJSTarget(IASProject project, ITargetSettings settings,
            ITargetProgressMonitor monitor);

    JSFilterWriter createFilterWriter(IASProject project);

    JSWriter createWriter(IASProject project, List<ICompilerProblem> errors,
            ICompilationUnit compilationUnit, boolean enableDebug);

    ASBlockWalker createWalker(IASProject project,
            List<ICompilerProblem> errors, JSFilterWriter writer);

}
