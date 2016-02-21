package net.metabrain.level2.web.client;

import com.google.gson.Gson;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import net.metabrain.level2.consolidator.Action;
import net.metabrain.utils.Http;

import java.io.IOException;

public class ClientAction implements HttpHandler {
    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        String actionID = Http.Params(httpExchange).get("actionID");
        Action action = new Action(actionID);
        Http.Response(httpExchange, new Gson().toJson(action));
    }
}
