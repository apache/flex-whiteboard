package org.apache.flex.compiler.internal.js.codegen.goog;

import org.apache.flex.compiler.definitions.IClassDefinition;
import org.apache.flex.compiler.definitions.ITypeDefinition;
import org.apache.flex.compiler.internal.js.codegen.JSDocEmitter;
import org.apache.flex.compiler.internal.js.codegen.JSSharedData;
import org.apache.flex.compiler.js.codegen.IJSEmitter;
import org.apache.flex.compiler.js.codegen.goog.IJSGoogDocEmitter;
import org.apache.flex.compiler.tree.as.IASNode;
import org.apache.flex.compiler.tree.as.IClassNode;
import org.apache.flex.compiler.tree.as.IFunctionNode;
import org.apache.flex.compiler.tree.as.IPackageNode;
import org.apache.flex.compiler.tree.as.IParameterNode;
import org.apache.flex.compiler.tree.as.IVariableNode;

public class JSGoogDocEmitter extends JSDocEmitter implements IJSGoogDocEmitter
{

    public JSGoogDocEmitter(IJSEmitter emitter)
    {
        super(emitter);
        // TODO Auto-generated constructor stub
    }
    

    @Override
    public void emitConst(IVariableNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitConstructor(IFunctionNode node)
    {
        write(" * @constructor\n");
    }

    @Override
    public void emitDefine(IVariableNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitDeprecated(IASNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitEnum(IClassNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitExtends(IClassDefinition superDefinition)
    {
        final String qname = superDefinition.getQualifiedName();
        // TODO (mschmalle) test Object is this the only class that dosn't need a tag?
        if (qname.equals("Object"))
            return;
        write(" * @extends {" + qname + "}\n");
    }

    @Override
    public void emitImplements(IClassNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitInheritDoc(IClassNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitLicense(IClassNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitOverride(IFunctionNode node)
    {
        write(" * @override\n");
    }

    @Override
    public void emitParam(IParameterNode node)
    {
    	String postfix = (node.getDefaultValue() == null) ? "" : "=";
    	
    	String paramType = "";
    	if (node.isRest())
    		paramType = "...";
    	else
    		paramType = convertASTypeToJS(node.getVariableType());
    	
        write(" * @param {" + paramType + postfix + "} " + node.getName() + "\n");
    }

    @Override
    public void emitPrivate(IASNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitProtected(IASNode node)
    {
        // TODO Auto-generated method stub

    }

    @Override
    public void emitReturn(IFunctionNode node)
    {
        // TODO convert js types
        String rtype = node.getReturnType();
        if (rtype != null)
            write(" * @return {" + convertASTypeToJS(rtype) + "}\n");
    }

    @Override
    public void emitThis(ITypeDefinition type)
    {
        write(" * @this {" + type.getQualifiedName() + "}\n");
    }

    @Override
    public void emitType(IASNode node)
    {
        //String type = SemanticUtils.getTypeOfStem(node, emitter.getProject());
        String type = ((IVariableNode) node).getVariableType(); 
        // XXX need to map to js types
        write(" * @type {" + convertASTypeToJS(type) + "}\n");
    }

    @Override
    public void emitTypedef(IASNode node)
    {
        // TODO Auto-generated method stub

    }

    //--------------------------------------------------------------------------

    public void emmitPackageHeader(IPackageNode node)
    {
        begin();
        write(" * " + JSSharedData.getTimeStampString());
        end();
    }

    //--------------------------------------------------------------------------

    private String convertASTypeToJS(String name)
    {
    	String result = name;
    	
    	if (name.equals(""))
    		result = "*";
    	
    	if (name.equals("String"))
    		result = "string";
    	
    	if (name.equals("int") || name.equals("uint"))
    		result = "number";
    	
        return result;
    }

}
