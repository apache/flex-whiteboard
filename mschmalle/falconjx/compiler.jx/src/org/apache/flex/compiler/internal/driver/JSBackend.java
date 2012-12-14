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

package org.apache.flex.compiler.internal.driver;

import java.io.StringWriter;
import java.util.List;

import org.apache.flex.compiler.clients.IBackend;
import org.apache.flex.compiler.clients.JSConfiguration;
import org.apache.flex.compiler.config.Configurator;
import org.apache.flex.compiler.internal.driver.strategy.AfterNodeStrategy;
import org.apache.flex.compiler.internal.driver.strategy.BeforeAfterStrategy;
import org.apache.flex.compiler.internal.driver.strategy.BeforeNodeStrategy;
import org.apache.flex.compiler.internal.js.codgen.ASBlockWalker;
import org.apache.flex.compiler.internal.js.codgen.JSEmitter;
import org.apache.flex.compiler.internal.js.codgen.JSFilterWriter;
import org.apache.flex.compiler.internal.js.codgen.JSWriter;
import org.apache.flex.compiler.internal.projects.ISourceFileHandler;
import org.apache.flex.compiler.internal.targets.JSTarget;
import org.apache.flex.compiler.internal.visitor.ASNodeSwitch;
import org.apache.flex.compiler.problems.ICompilerProblem;
import org.apache.flex.compiler.projects.IASProject;
import org.apache.flex.compiler.targets.ITargetProgressMonitor;
import org.apache.flex.compiler.targets.ITargetSettings;
import org.apache.flex.compiler.tree.as.IFileNode;
import org.apache.flex.compiler.units.ICompilationUnit;

/**
 * A concrete implementation of the {@link IBackend} API where the
 * {@link ASBlockWalker} is used to traverse the {@link IFileNode} AST.
 * 
 * @author Michael Schmalle
 */
public class JSBackend implements IBackend
{

    @Override
    public String getOutputExtension()
    {
        return "js";
    }

    @Override
    public ISourceFileHandler getSourceFileHandlerInstance()
    {
        return JSSourceFileHandler.INSTANCE;
    }

    @Override
    public Configurator createConfigurator()
    {
        return new Configurator(JSConfiguration.class);
    }

    @Override
    public JSTarget createJSTarget(IASProject project,
            ITargetSettings settings, ITargetProgressMonitor monitor)
    {
        return new JSTarget(project, settings, monitor);
    }

    @Override
    public ASBlockWalker createWalker(IASProject project,
            List<ICompilerProblem> errors, JSFilterWriter out)
    {
        JSEmitter emitter = new JSEmitter(out);
        ASBlockWalker walker = new ASBlockWalker(errors, project, emitter);

        BeforeAfterStrategy strategy = new BeforeAfterStrategy(
                new ASNodeSwitch(walker), new BeforeNodeStrategy(emitter),
                new AfterNodeStrategy(emitter));

        walker.setStrategy(strategy);

        return walker;
    }

    @Override
    public JSFilterWriter createFilterWriter(IASProject project)
    {
        StringWriter out = new StringWriter();
        JSFilterWriter writer = new JSFilterWriter(out);
        return writer;
    }

    @Override
    public JSWriter createWriter(IASProject project,
            List<ICompilerProblem> problems, ICompilationUnit compilationUnit,
            boolean enableDebug)
    {
        return new JSWriter(project, problems, compilationUnit, enableDebug);
    }

}
