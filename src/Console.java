import java.awt.BorderLayout;
import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.JButton;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;


public class Console extends JFrame {

	public static void main(String[] args) {
		ModuleLoader loader = new ModuleLoader("C:\\Users\\Hist\\Desktop\\ClassLoader\\src\\", ClassLoader.getSystemClassLoader());
		
	      try {
	        
	        Class c = loader.loadClass("Module");
	        Method[] methods = c.getMethods(); 
	        for (Method method : methods) { 
	            System.out.println("���: " + method.getName()); 
	            System.out.println("������������ ���: " + method.getReturnType().getName()); 
	         
	            Class[] paramTypes = method.getParameterTypes(); 
	            System.out.print("���� ����������: "); 
	            for (Class paramType : paramTypes) { 
	                System.out.print(" " + paramType.getName()); 
	            } 
	            System.out.println(); 
	        }
	        
	        Object obj = c.newInstance();
	        Class[] paramTypes = new Class[] { int.class }; 
	        Method method = c.getMethod("run", paramTypes); 
	        Object[] params = new Object[] { new Integer(10) }; 
	        Object ret = method.invoke(obj, params);
	        System.out.print("��������� " + ((Integer)ret).toString()); 
	        
	      } catch (ClassNotFoundException e) {
	        e.printStackTrace();
	      } catch (InstantiationException e) {
	        e.printStackTrace();
	      } catch (IllegalAccessException e) {
	        e.printStackTrace();
	      } catch (NoSuchMethodException e) {
			e.printStackTrace();
		} catch (SecurityException e) {
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		}
	   
	}


}
