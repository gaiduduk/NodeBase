import javax.xml.transform.OutputKeys;
import java.io.*;
import java.net.*;
import java.util.ArrayList;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import com.sun.org.apache.xerces.internal.parsers.DOMParser;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * Created by yar 09.09.2009
 */
public class HttpServer {

    class Host
    {
        String mac;
        String ip;
        int lastBlock;
    }

    static class Response
    {
        String mac;
        String lastBlock;
    }



    static ArrayList<Host> hostList = new ArrayList<Host>();

    static String localMac;

    public static void main(String[] args) {
        localMac = getMac();
        new Thread(new SocketListener()).start();

        String request = createRequest(-1);
        String response = sendRequest("http://localhost:8080", request);
        Response res = readResponse(response);







    }


    static String createRequest(int lastBlock)
    {
        try
        {

            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();


            Document doc = docBuilder.newDocument();
            Element host = doc.createElement("host");
            doc.appendChild(host);

            host.setAttribute("mac", localMac);



            /*Element firstname = doc.createElement("firstname");
            firstname.appendChild(doc.createTextNode("yong"));
            staff.appendChild(firstname);
            */

            TransformerFactory tf = TransformerFactory.newInstance();
            Transformer transformer = tf.newTransformer();
            transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));
            return writer.getBuffer().toString();

        } catch (ParserConfigurationException pce) {
            pce.printStackTrace();
        } catch (TransformerException tfe) {
            tfe.printStackTrace();
        }
        return "";
    }

    static Response readResponse(String response)
    {

        if (response == "") return null;

        DOMParser parser = new DOMParser();
        try
        {
            Response res = new Response();
            parser.parse(new InputSource(new StringReader(response)));
            Document doc = parser.getDocument();
            Element host = doc.getDocumentElement();
            res.mac = host.getAttribute("mac");

            return res;
        } catch (SAXException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }




    static String getMac()
    {
        if (true) return  "96-2E-E8-7F-AA-94";
        InetAddress ip;
        try {

            ip = InetAddress.getLocalHost();
            NetworkInterface network = NetworkInterface.getByInetAddress(ip);
            byte[] mac = network.getHardwareAddress();
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < mac.length; i++) {
                sb.append(String.format("%02X%s", mac[i], (i < mac.length - 1) ? "-" : ""));
            }
            return  sb.toString();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        } catch (SocketException e){
            e.printStackTrace();
        }

        return null;
   }




    public static String sendRequest(String targetURL, String request)
    {
        URL url;
        HttpURLConnection connection = null;
        try {
            //Create connection
            url = new URL(targetURL);
            connection = (HttpURLConnection)url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Content-Type",
            "application/x-www-form-urlencoded");

            connection.setRequestProperty("Content-Length", "" +
               Integer.toString(request.getBytes().length));
            connection.setRequestProperty("Content-Language", "en-US");

            connection.setUseCaches (false);
            connection.setDoInput(true);
            connection.setDoOutput(true);

            //Send request
            DataOutputStream wr = new DataOutputStream (
                  connection.getOutputStream ());
            wr.writeBytes (request);
            wr.flush ();
            wr.close ();

            //Get Response
            InputStream is = connection.getInputStream();
            BufferedReader rd = new BufferedReader(new InputStreamReader(is));
            String line;
            StringBuffer response = new StringBuffer();
            while((line = rd.readLine()) != null) {
                response.append(line);
                response.append('\r');
            }
            rd.close();
            return response.toString();

        } catch (Exception e) {
            System.out.println(e.getMessage());
          e.printStackTrace();
          return null;

        } finally {

          if(connection != null) {
            connection.disconnect();
          }
        }
    }

    static class SocketListener implements Runnable {

        public void run() {
            try
            {
                ServerSocket ss = new ServerSocket(8080);
                while (true) {
                    Socket s = ss.accept();
                    System.err.println("Client accepted");
                    new Thread(new SocketAnswer(s)).start();
                }
            }
            catch (Throwable e)
            {
                System.out.println("занят порт 8080");
            }
        }
    }

    static class SocketAnswer implements Runnable {

        private Socket s;
        private InputStream is;
        private OutputStream os;

        private SocketAnswer(Socket s) throws Throwable {
            this.s = s;
            this.is = s.getInputStream();
            this.os = s.getOutputStream();
        }

        public void run() {
            try {
                readInputHeaders();
                writeResponse(createRequest(0));
            } catch (Throwable t) {
                /*do nothing*/
            } finally {
                try {
                    s.close();
                } catch (Throwable t) {
                    /*do nothing*/
                }
            }
            System.err.println("Client processing finished");
        }

        private void writeResponse(String s) throws Throwable {
            String response = "HTTP/1.1 200 OK\r\n" +
                    "Server: YarServer/2009-09-09\r\n" +
                    "Content-Type: text/html\r\n" +
                    "Content-Length: " + s.length() + "\r\n" +
                    "Connection: close\r\n\r\n";
            String result = response + s;
            os.write(result.getBytes());
            os.flush();
        }

        private void readInputHeaders() throws Throwable {
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            while(true) {
                String s = br.readLine();
                if(s == null || s.trim().length() == 0) {
                    break;
                }
            }
        }
    }









    static class Time
    {
        double func;
        double par1;
        double par2;
        double trueto;
        double result;
    }

    static class TimeID
    {
        double timeIndex;
        double funcIndex;
        double linkIndex;
        double trueIndex;
        double resultIndex;

    }




    void generate(int blockNum, int blockSize)
    {


        double funcRun = 0;
        double[] inputVars = {1, 6, 3};
        ArrayList<TimeID> rightFuncs = new ArrayList<TimeID>();

        //set time
        double timeIndex = 3;

        long beginTime = System.currentTimeMillis();
        while (true)
        {
            timeIndex++;
            //timeIndex =4;

            ArrayList<Time> timeLine = new ArrayList<Time>();
            for (double i = 0; i <= timeIndex; i++)
                timeLine.add(new Time());

            //set function
            double funcCount = 8;

            for (double funcIndex = 0; funcIndex < Math.pow(funcCount, timeIndex); funcIndex++) {


                funcRun++;

                if (funcRun % 200 == 0) {
                    System.out.println(timeIndex + " line " + funcRun + " count " + (System.currentTimeMillis() - beginTime) + " ms");
                    beginTime = System.currentTimeMillis();
                }

                double funcIndex2 = funcIndex;
                       /*0 * Math.pow(funcCount, 0) + //add
                       1 * Math.pow(funcCount, 1) + //sub
                       4 * Math.pow(funcCount, 2) + //==
                       5 * Math.pow(funcCount, 3) + //!=
                       2 * Math.pow(funcCount, 4); //mul */

                for (double i = 0; i < timeLine.size(); i++) {
                    Time time =  timeLine.get((int)i);
                    double razm = Math.pow(funcCount, i + 1);
                    time.func = (funcIndex2 % razm) / Math.pow(funcCount, i);
                    funcIndex2 -= funcIndex2 % razm;
                }


                //prepare to params generate


                ArrayList<Double> maxIndex = new ArrayList<Double>();
                for (double i = 0; i < timeLine.size(); i++)
                    maxIndex.add(Math.pow(inputVars.length + i, 2));
                Double maxIndexSum = 0.0;
                for (double i = 0; i < maxIndex.size(); i++)
                    maxIndexSum +=  maxIndex.get((int)i);
                ArrayList<Double> valIndex = new ArrayList<Double>();
                for (double i = 0; i < maxIndex.size(); i++)
                    valIndex.add(0.0);


                //set params
                for (double parIndex = 0; parIndex < maxIndexSum; parIndex++) {

                    double parIndex2 = parIndex;
                      /*(0 + 2 * Math.sqrt(maxIndex.get(0))) * 1 +
                      (3 + 2 * Math.sqrt(maxIndex.get(1))) * 1 * maxIndex.get(1) +
                      (0 + 0 * Math.sqrt(maxIndex.get(2))) * 1 * maxIndex.get(1) * maxIndex.get(2) +
                      (5 + 5 * Math.sqrt(maxIndex.get(3))) * 1 * maxIndex.get(1) * maxIndex.get(2) * maxIndex.get(3) +
                      (6 + 1 * Math.sqrt(maxIndex.get(4))) * 1 * maxIndex.get(1) * maxIndex.get(2) * maxIndex.get(3) * maxIndex.get(4);
                       */
                    for (double i = 0; i < valIndex.size(); i++)
                    {
                        double razm = 1;
                        for (double j = 1; j < maxIndex.size() - i; j++)
                            razm *= maxIndex.get((int)j);
                        double val = (double)(int)(parIndex2 / razm);
                        valIndex.set((int)(maxIndex.size() - i - 1), val);
                        parIndex2 -= val * razm;

                        if (val == 15)
                        {
                            double x = 1;
                        }
                        /*double razm = Math.pow(funcCount, i + 1);
                        time.func = (funcIndex2 % razm) / Math.pow(funcCount, i);
                        funcIndex2 -= funcIndex2 % razm;
                        */
                    }

                    for (double i = 0; i < valIndex.size(); i++)
                    {
                        double val =  valIndex.get((int)i);
                        Time time = timeLine.get((int)i);
                        double razm = Math.pow(funcCount, i + 1);
                        time.par1 = (int)(val % Math.sqrt(maxIndex.get((int)i)));
                        time.par2 = (int)(val / Math.sqrt(maxIndex.get((int)i)));
                    }


                    //set trueto
                    ArrayList<Double> equalsFuncIndexes = new ArrayList<Double>();
                    for (double i = 0; i < timeLine.size(); i++)
                        if (timeLine.get((int)i).func > 3)
                            equalsFuncIndexes.add((double)i);

                    for (double trueIndex = 0; trueIndex < Math.pow(timeLine.size() - 1, equalsFuncIndexes.size()); trueIndex++)
                    {
                        double trueIndex2 = trueIndex;
                           // 1 + 3 * Math.pow(timeLine.size() - 1, 1);

                        for (double i = 0; i < equalsFuncIndexes.size(); i++) {
                            Time time = timeLine.get((int)equalsFuncIndexes.get((int)i).doubleValue());
                            double razm = Math.pow(timeLine.size() - 1, i + 1);
                            time.trueto = (trueIndex2 % razm) / Math.pow(timeLine.size() - 1, i);
                            trueIndex2 -= trueIndex2 % razm;
                            if (time.trueto >= equalsFuncIndexes.get((int)i))
                                time.trueto++;
                        }




                        //run


                        double maxRunTime = 10000;
                        double runTime = 0;
                        double i = 0;
                        while ((i < timeLine.size()) & (runTime < maxRunTime))
                        {
                            runTime++;
                            Time time = timeLine.get((int)i);

                            double par1 = 0;
                            if (time.par1 < inputVars.length)
                                par1 = inputVars[(int)time.par1];
                            else
                                par1 = timeLine.get((int)time.par1- inputVars.length).result;

                            double par2 = 0;
                            try
                            {
                            if (time.par2 < inputVars.length)
                                par2 = inputVars[(int)time.par2];
                            else
                                par2 = timeLine.get((int)time.par2- inputVars.length).result;
                            }
                            catch (IndexOutOfBoundsException e)
                            {
                                e.printStackTrace();
                            }

                            switch ((int)time.func){
                                case 0: time.result = par1 + par2; break;
                                case 1: time.result = par1 - par2; break;
                                case 2: time.result = par1 * par2; break;
                                case 3: time.result = par1 / par2; break;
                                case 4: time.result = (par1 == par2) ? 1 : 0; break;
                                case 5: time.result = (par1 != par2) ? 1 : 0; break;
                                case 6: time.result = (par1 > par2) ? 1 : 0; break;
                                case 7: time.result = (par1 < par2) ? 1 : 0; break;
                            }
                            if (time.func > 3)
                                if (time.result == 1)
                                {
                                    i = (double)time.trueto;
                                    continue;
                                }

                            i++;
                        }




                        double rightResult = 3.14;
                        if (runTime < maxRunTime)
                        {
                            for (double resultIndex = 0; resultIndex < timeLine.size(); resultIndex++) {
                                Time time = timeLine.get((int)resultIndex);
                                double roundResult = Math.round(time.result * 100.0) / 100.0;
                                if (roundResult == rightResult)
                                {
                                    TimeID timeID = new TimeID();
                                    timeID.timeIndex = timeIndex;
                                    timeID.funcIndex = funcIndex;
                                    timeID.linkIndex = parIndex;
                                    timeID.trueIndex = trueIndex;
                                    timeID.resultIndex = resultIndex;
                                    rightFuncs.add(timeID);
                                    System.out.println(rightFuncs.size());
                                }

                            }
                        }

                    }
                }
            }
        }
    }


}
