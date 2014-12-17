package NodeBase;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;




class Link
{
	public Node parent;
	public Node node;
	public ArrayList<Node> nodes;
	
	Link(Node node, Node parent)
	{
		this.node = node;
		this.parent = parent;
	}
	
	void add(Node node)
	{
		if (nodes == null)
		{
			nodes = new ArrayList<Node>();
			nodes.add(this.node);
		}
		nodes.add(node);
	}
	
	Node get(int i)
	{
		if (nodes == null)
			return null;
		return nodes.get(i);
	}
}




public class Node
{
	IndexNode Index;
	
	String Path;
	Object Data;
	Map<String, String>	Attr;
	Link 
		Comment,
		Source,
		Type,
		Params,
		Value,
		True,
		Else,
		Next,
		Locals;
	
	Node(IndexNode index)
	{
		this.Index = index;
	}
	
	/*public void setIndex(IndexTree index) {
		Index = index;
	}*/
	
	/*public String getIndex() {
		return null;
	}*/
	
	public String getAttr(String key) {
		if (Attr == null)
			return null;
		return Attr.get(key);
	}
	
	public void setAttr(String key, String value) {
		if (Attr == null)
			Attr = new HashMap<String, String>();
		Attr.put(key, value);
	}


	public String getNodeType() {
		return getAttr(Const.naType);
	}
	
	public void setNodeType(String type) {
		setAttr(Const.naType, type);
	}
	
	public Link getComment() {
		return Comment;
	}
	
	public void setComment(Link comment) {
		Comment = comment;
	}

	public Node getSource() {
		Node result = this;
		while (result.Source != null)
			result = result.Source.node;
		return result;
	}
	
	public void setSource(Node node) {
		Source.node = node;
	}
	
	public Node getType() {
		return Type.node;
	}
	
	public void setType(Node node) {
		Type.node = node;
	}
	
	public Node getParam() {
		return Params.node;
	}
	
	public void setParam(Node param, int index) {
		if (param.getType() != null)
		{
			param.Source = null;
			Params.nodes.add(param);
		}
		else
		{
			if (index == Params.nodes.size())
				Params.nodes.add(param);
			else
			if (index <= Params.nodes.size())
				if (Params.nodes.get(index) != param)
					Params.nodes.set(index, param);
		}
	}
	
	public Node getValue() {
		ArrayList<Node> valueStack = new ArrayList<Node>();
		Node result = null;
		Node node = this;
		while (node != null)
		{
			valueStack.add(node);
			if (node.Source != null)
				node = node.Source.node;
			else
			{
				result = node;
				if (node.Value != null) break;
				if (valueStack.indexOf(node.Value.node) != -1) break;
				node = node.Value.node;
			}
		}
		valueStack.clear();
		return result;
	}
	
	public void setValue(Node node) {
		Value.node = node;
	}
	
	public Object getData() {
		return Data;
	}
	
	public void setData(String data) {
		Data = data;
	}
	
	public Node getTrue() {
		return True.node;
	}
	
	public void setTrue(Node node) {
		True.node = node;
	}
	
	public Node getElse() {
		return Else.node;
	}
	
	public void setElse(Node node) {
		Else.node = node;
	}
	
	public Node getNext() {
		return Next.node;
	}
	
	public void setNext(Node next) {
		Next.node = next;
		if (next != null)
			next.Next.parent = this;
	}
	
	/*public Link getLocals() {
		return Locals;
	}*/

	public void setLocal(Node local) {
		if (Locals.nodes.indexOf(local) != -1)
			Locals.nodes.add(local);
	}

	public String getBody() 
	{
		String result = null;

		if (Comment != null)
			result += Const.sComment + Comment.node.Index.getIndex();
		if (Source != null)
			result += Const.sSource + Source.node.Index.getIndex();
		
		if (Attr != null)
		{
			String str = null;
			for (Map.Entry entry: Attr.entrySet()) { 
				if (str != null)
					str += Const.sAnd;
				str += (String) entry.getKey() + Const.sEqual + (String) entry.getValue();
			} 
			result += Const.sAttr + str;
		}
		if (Type != null)
			result += Const.sType + Type.node.Index.getIndex();
		if (Params != null)
		{
			String str = null;
			for (int i=0; i<Params.nodes.size(); i++)
			{
				if (str != null)
					str += Const.sAnd;
				str += Params.nodes.get(i).Index.getIndex();
			}
			result += Const.sParams + str;
		}
		if (Value != null)
			result += Const.sValue + Value.node.Index.getIndex();
		if (True != null)
			result += Const.sTrue + True.node.Index.getIndex();
		if (Else != null)
			result += Const.sElse + Else.node.Index.getIndex();
		if (Next != null)
			result += Const.sNext + Next.node.Index.getIndex();
		if (Locals != null)
			for (int i=0; i<Locals.nodes.size(); i++)
				result += Const.sLocals + Locals.nodes.get(i).Index.getIndex();
		return result;
	}
	
	Boolean compare()
	{
		if (getNodeType() == Const.ntNumber)
			if ((Double)Data == 1)
				return true;
		if (getNodeType() == Const.ntString)
			if (((String)Data).isEmpty())
				return true;
		return false;
	}

}
