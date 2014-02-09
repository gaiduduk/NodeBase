package com.example.notepad;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import android.os.Bundle;
import android.app.ActionBar.Tab;
import android.app.Activity;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

public class MainActivity extends Activity {
	
	MetaNode root;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		
		/*root = new MetaNode("http://178.124.178.151/!hello");
		
		//setTitle(root.id);
		
		ListView List = (ListView)findViewById(R.id.listView1);
		MetaAdapter adapter = new MetaAdapter(this, R.layout.list_item, root.local);
		List.setAdapter(adapter);*/
		
		
		
		Button button = (Button)findViewById(R.id.button1);
		button.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0){
				try
				{
					URL url = new URL("http://178.124.178.151");
					HttpURLConnection conn = (HttpURLConnection)url.openConnection();
					conn.setRequestMethod("POST");
					conn.setRequestProperty("Content-Language", "en-US");  
							
					conn.setDoInput(true);
					conn.setDoOutput(true);

				      //Send request
				      DataOutputStream wr = new DataOutputStream(conn.getOutputStream());
				      wr.writeBytes("1234");
				      wr.flush();
				      wr.close();

				      //Get Response	
				      InputStream is = conn.getInputStream();
				      BufferedReader rd = new BufferedReader(new InputStreamReader(is));
				      String line;
				      StringBuffer response = new StringBuffer(); 
				      while((line = rd.readLine()) != null) {
				        response.append(line);
				        response.append('\r');
				      }
				      rd.close();

					Toast.makeText(getApplication(), "GUT", Toast.LENGTH_SHORT).show();
					     	    
				}catch (Exception e)
				{Log.i("GET RESPONSE", "Error " + e.getMessage());}
			}
		});
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

}
