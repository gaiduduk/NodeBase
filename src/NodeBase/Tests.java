package NodeBase;

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class Tests {
	
	
	
	public static void main(String[] args) throws Exception 
	{
		{
			beginTest("Node getters and setters");
			Node node = new Node(new Index("node"));
			node.setComment(new Node(new Index("comment")));
			node.setSource(new Node(new Index("source")));
			node.setType(new Node(new Index("type")));
			node.setValue(new Node(new Index("value")));
			node.setTrue(new Node(new Index("true")));
			node.setElse(new Node(new Index("else")));
			node.setNext(new Node(new Index("next")));
			testEqual(node.getComment().getIndex(), "comment");
			testEqual(node.getSource().getIndex(), "source");
			testEqual(node.getType().getIndex(), "type");
			testEqual(node.getValue().getIndex(), "value");
			testEqual(node.getTrue().getIndex(), "true");
			testEqual(node.getElse().getIndex(), "else");
			testEqual(node.getNext().getIndex(), "next");
			node.setAttr("attr1", "val1");
			node.setAttr("attr2", "val2");
			node.setAttr("attr3", null);
			testEqual(node.getAttr("attr1"), "val1");
			testEqual(node.getAttr("attr2"), "val2");
			testEqual(node.getAttr("attr3"), null);
			node.setData("data");
			testEqual(node.getData().toString(), "data");
			
			/*
			node.setParam(0, new Node(new Index("param1")));
			node.setParam(1, new Node(new Index("param2")));
			testEqual(node.getParams().size(), 2);
			*/
		}
		
		{
			beginTest("TextNode UserParse");
			TextNode node = new TextNode("comment@id^source$attr1=val1&attr2=val2&attr3:type?par1:type1=val3&par2=val4&par3:type2&par4#value>true|else\nnext\n\nlocal1\n\nlocal2");
			node.UserParse();
			testEqual(node.Comment, "comment");
			testEqual(node.ID, "id");
			testEqual(node.Source.Comment, "source");
			testEqual(node.Value.Comment, "value");
			testEqual(node.True.Comment, "true");
			testEqual(node.Else.Comment, "else");
			testEqual(node.Next.Comment, "next");
			testEqual(node.Locals.size(), 2);
			testEqual(node.Locals.get(0).Comment, "local1");
			testEqual(node.Locals.get(1).Comment, "local2");
			testEqual(node.Attr.size(), 3);
			testEqual(node.Attr.get("attr1"), "val1");
			testEqual(node.Attr.get("attr2"), "val2");
			testEqual(node.Attr.get("attr3"), null);
			testEqual(node.Params.size(), 4);
			testEqual(node.Params.get(0).Comment, "par1");
			testEqual(node.Params.get(0).Type.Comment, "type1");
			testEqual(node.Params.get(0).Value.Comment, "val3");
			testEqual(node.Params.get(1).Comment, "par2");
			testEqual(node.Params.get(1).Value.Comment, "val4");
			testEqual(node.Params.get(2).Comment, "par3");
			testEqual(node.Params.get(2).Type.Comment, "type2");
			testEqual(node.Params.get(3).Comment, "par4");
		}
		
		{
			beginTest("TextNode BaseParse");
			TextNode node = new TextNode("comment@id^source$attr1=val1&attr2=val2&attr3:type?par1&par2#value>true|else\nnext\n\nlocal1\n\nlocal2");
			node.BaseParse();
			testEqual(node.Comment, "comment");
			testEqual(node.ID, "id");
			testEqual(node.Source.ID, "source");
			testEqual(node.Value.ID, "value");
			testEqual(node.True.ID, "true");
			testEqual(node.Else.ID, "else");
			testEqual(node.Next.ID, "next");
			testEqual(node.Locals.size(), 2);
			testEqual(node.Locals.get(0).ID, "local1");
			testEqual(node.Locals.get(1).ID, "local2");
			testEqual(node.Attr.size(), 3);
			testEqual(node.Attr.get("attr1"), "val1");
			testEqual(node.Attr.get("attr2"), "val2");
			testEqual(node.Attr.get("attr3"), null);
			testEqual(node.Params.size(), 2);
			testEqual(node.Params.get(0).ID, "par1");
			testEqual(node.Params.get(1).ID, "par2");
		}
		
		{
			beginTest("Index");
			Index node = new Index("");
			testEqual(node.getSubNode("ind1/ind2/ind3").getIndex(), "/ind1/ind2/ind3");
			testEqual(node.getSubNode("ind1/ind2/ind4").getIndex(), "/ind1/ind2/ind4");
			testEqual(node.getSubNode("ab").getIndex(), "ab");
			testEqual(node.getSubNode("ac").getIndex(), "ac");
			testEqual(node.getSubNode("a").childs.size(), 2);
		}
		
		endTesting();
	}
	
	static void testEqual(String str1, String str2)
	{
		if (str1 == null)
		{
			if (str2 != null)
			{
				testError();
				System.out.println(str1 + " != " + str2);
			}
		}
		else
		if (str1.compareTo(str2) != 0)
		{
			testError();
			System.out.println(str1 + " != " + str2);
		}
	}
	
	static void testEqual(int num1, int num2)
	{
		if (num1 != num2)
		{
			testError();
			System.out.println(Integer.toString(num1) + " != " + Integer.toString(num2));
		}
	}
	
	private static void testError(String message)
	{
		testError();
		System.out.println(message);
	}

	static String testName = null;
	static int success = 0;
	static int errors = 0;
	
	private static void beginTest(String string) {
		if (testName != null)
			success++;
		testName = string;
	}
	
	private static void testError() {
		System.out.println(testName);
		errors++;
		testName = null;
	}

	private static void endTesting() {
		if (testName != null)
			success++;
		//System.out.println("������ " + Integer.toString(errors) + " ������� " + Integer.toString(success));
	}

	
}