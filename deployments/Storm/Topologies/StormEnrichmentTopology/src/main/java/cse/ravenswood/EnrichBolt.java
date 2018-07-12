package cse.ravenswood;

import org.apache.storm.topology.base.BaseBasicBolt;

import java.util.Date;
import java.util.Map;

import com.fasterxml.jackson.databind.deser.BuilderBasedDeserializer;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.BasicOutputCollector;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.tuple.Tuple;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;

import org.json.JSONObject;

import okhttp3.HttpUrl;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.Request.Builder;

public class EnrichBolt extends BaseBasicBolt {

    private static final Logger LOG = LogManager.getLogger(EnrichBolt.class.getName());
    private String _enrichUrl;
    private OkHttpClient _client;

    public EnrichBolt(String enrichUrl) {
        this._enrichUrl = enrichUrl;
    }

    @Override
    public void prepare(Map stormConf, TopologyContext context) {
        this._client = new OkHttpClient();
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        // Declare the fields in the tuple. These fields are accessible by
        // these names when read by bolts.
        declarer.declare(new Fields("messageDate", "messageId", "userId", "value", "body", "timestampUtc"));
    }

    @Override
    public void execute(Tuple tuple, BasicOutputCollector collector) {
        // Retrieve values
        String messageDate = tuple.getString(0);
        String messageId = tuple.getString(1);
        int userId = tuple.getInteger(2);
        int value = tuple.getInteger(3);
        String body = tuple.getString(4);
        long timestampUtc = tuple.getLong(5);

        LOG.info(String.format("RETRIEVING enrichUrl: %s, messageDate: %s, messageId: %s, userId: %s, value: %s, body: %s, timestampUtc: %s",
            this._enrichUrl,
            messageDate,
            messageId,
            Integer.toString(userId),
            Integer.toString(value),
            body,
            Long.toString(timestampUtc)));

        // Check for empty body
        if(body == null || body.isEmpty()) {
            body = "{}";
        }

        // Enrich
        JSONObject existingBodyObj = new JSONObject(body);
        JSONObject newBodyObj = getBodyObject(userId, this._enrichUrl, existingBodyObj); //Note we need to pass in the enriched body as a header
        JSONObject mergedBodyObj = mergeJSONObjects(newBodyObj, existingBodyObj);

        LOG.info(String.format("EMITTING enrichUrl: %s, messageDate: %s, messageId: %s, userId: %s, value: %s, body: %s, timestampUtc: %s",
            this._enrichUrl,
            messageDate,
            messageId,
            Integer.toString(userId),
            Integer.toString(value),
            mergedBodyObj.toString(),
            Long.toString(timestampUtc)));

        // Emit
        collector.emit(new Values(messageDate, messageId, userId, value, mergedBodyObj.toString(), timestampUtc));
    }

    private JSONObject getBodyObject(int userId, String url, JSONObject enrichedBody) {
        try {
            // Add headers
            Builder builder = buildRequestHeaders(enrichedBody);

            // Create request for remote resource.
            String userIdString = Integer.toString(userId);
            Request request = builder.addHeader("stromuserId", userIdString)
                    .url(HttpUrl.parse(url)
                        .newBuilder()
                        .addQueryParameter("id", userIdString)
                        .build())
                    .build();

            // Call web services
            Response response = this._client.newCall(request).execute();

            // Return body
            String body = response.body().string();
            JSONObject Jobject = new JSONObject(body);

            return (Jobject);
        } catch (Exception ex) {
            LOG.error(ex.getMessage());
            return new JSONObject("{}"); // for demo purposes
        }
    }

    private Builder buildRequestHeaders(JSONObject enrichedBody) {
        Builder builder = new Request.Builder();
        if (JSONObject.getNames(enrichedBody) == null) {
            return (builder);
        }
        for (String key : JSONObject.getNames(enrichedBody)) {
            String headerName = String.format("strom%s", key);
            String headerValue = enrichedBody.getString(key);
            LOG.info(String.format("Adding header: %s with value: %s", headerName, headerValue));
            builder.addHeader(headerName, headerValue);
        }
        return (builder);
    }

    private JSONObject mergeJSONObjects(JSONObject obj1, JSONObject obj2) {
        JSONObject merged = new JSONObject(obj1, JSONObject.getNames(obj1));
        if (JSONObject.getNames(obj2) == null) {
            // obj2 is empty so just return obj1
            return (obj1);
        }
        for (String key : JSONObject.getNames(obj2)) {
            merged.put(key, obj2.get(key));
        }
        return (merged);
    }
}
