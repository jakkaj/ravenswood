package cse.ravenswood;

import org.apache.storm.topology.base.BaseBasicBolt;
import org.apache.storm.topology.BasicOutputCollector;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.tuple.Tuple;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;

import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

public class ParserBolt extends BaseBasicBolt {
  
    // Declare output fields & streams
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        // Declare the fields in the tuple. These fields are accessible by
        // these names when read by bolts.
        declarer.declare(new Fields("messageDate", "messageId", "userId", "value", "body", "timestampUtc"));
    }

    //Process tuples
    @Override
    public void execute(Tuple tuple, BasicOutputCollector collector) {
        // Should only be one tuple, which is the JSON message from the spout
        String tupleValue = tuple.getString(0);

        // Example JSON:
        //  {
        //  "messageDate":"2018-06-26T00:38:26Z",
        //  "messageId":"c8bcfe1b-a4ba-453f-8487-c594f73c12f5",
        //  "userId":2000,
        //  "value":35544
        // } 

        JSONObject msg = new JSONObject(tupleValue);
        String messageDate = msg.getString("messageDate");
        String messageId = msg.getString("messageId");
        int userId = msg.getInt("userId");
        int value = msg.getInt("value");
        String body = msg.has("body") ? msg.getString("body") : "{}";

        // Create a timestamp
        long epochMilli = new Date().toInstant().toEpochMilli();

        // Emit
        collector.emit(new Values(messageDate, messageId, userId, value, body, epochMilli));
    }
}
