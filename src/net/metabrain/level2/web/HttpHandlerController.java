package net.metabrain.level2.web;

import net.metabrain.level2.utils.Http;
import net.metabrain.level2.web.client.ClientAction;
import net.metabrain.level2.web.client.ClientActionExecute;
import net.metabrain.level2.web.client.ClientActionList;

import java.io.File;
import java.io.IOException;

public class HttpHandlerController {

    public HttpHandlerController() {
        System.out.println(new File("").getAbsolutePath());
        try {
            Http.serverContent.put("/help", new RegistryApi());
            Http.serverContent.put("/registryapi", new RegistryApi());
            Http.serverContent.put("/hashmaptest", new HashMapTest());
            Http.serverContent.put("/", new Explorer());
            Http.serverContent.put("/" + ClientAction.class.getSimpleName(), new ClientAction());
            Http.serverContent.put("/" + ClientActionList.class.getSimpleName(), new ClientActionList());
            Http.serverContent.put("/" + ClientActionExecute.class.getSimpleName(), new ClientActionExecute());
            //add "/" context likePermutation root tree
            Http.open(8080);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
