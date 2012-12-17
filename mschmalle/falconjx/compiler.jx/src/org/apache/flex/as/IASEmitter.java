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

package org.apache.flex.as;

import java.io.Writer;

import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IVariableNode;
import org.apache.flex.compiler.visitor.IASNodeStrategy;

/**
 * The {@link IASEmitter} interface allows abstraction between the
 * {@link IASNodeStrategy} and the current output buffer {@link Writer}.
 * 
 * @author Michael Schmalle
 */
public interface IASEmitter
{
    /**
     * Writes a string to the writer.
     * 
     * @param value The string to write to the output buffer.
     */
    void write(String value);

    /**
     * Pushes an indent into the emitter so after newlines are emitted, the
     * output is correctly formatted.
     */
    void indentPush();

    /**
     * Pops an indent from the emitter so after newlines are emitted, the output
     * is correctly formatted.
     */
    void indentPop();

    /**
     * Emit a documentation comment for a Class field or constant
     * {@link IVariableNode}.
     * 
     * @param node The {@link IVariableNode} class field member.
     */
    void emitFieldDocumentation(IVariableNode node);

    /**
     * Emit a full Class field member.
     * 
     * @param node The {@link IVariableNode} class field member.
     */
    void emitField(IVariableNode node);

    /**
     * Emit a documentation comment for a Class method {@link IFunctionNode}.
     * 
     * @param node The {@link IFunctionNode} class method member.
     */
    void emitMethodDocumentation(IFunctionNode node);

    /**
     * Emit a full Class or Interface method member.
     * 
     * @param node The {@link IFunctionNode} class method member.
     */
    void emitMethod(IFunctionNode node);
}
