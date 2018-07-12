package cse.ravenswood;

import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichSpout;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;
import org.apache.storm.utils.Utils;

import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.Random;
import java.util.TimeZone;
import java.util.UUID;

public class UserMessageSpout extends BaseRichSpout {
    SpoutOutputCollector _collector;
    Random _rand;

    @Override
    public void open(Map conf, TopologyContext context, SpoutOutputCollector collector) {
        _collector = collector;
        _rand = new Random();
    }

    //Emit data to the stream
    @Override
    public void nextTuple() {
        // Sleep for 2 second so the data rate is slower.
        Utils.sleep(2000);
        
        // Create a timestamp, since there is none in the original data
        TimeZone timeZone = TimeZone.getTimeZone("UTC");
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'");
        dateFormat.setTimeZone(timeZone);
        
        String messageDate = dateFormat.format(new Date());
        String messageId = UUID.randomUUID().toString();
        int userId = _rand.nextInt(11) + 35;
        int value = _rand.nextInt(5) + 5;

        JSONObject message = new JSONObject();
        message.put("messageDate", messageDate);
        message.put("messageId", messageId);
        message.put("userId", userId);
        message.put("value", value);

        //Emit the UserMessage
        _collector.emit(new Values(message.toString()));
    }

    //Ack is not implemented
    @Override
    public void ack(Object id) {
    }

    //Fail is not implemented
    @Override
    public void fail(Object id) {
    }

    //Declare the output fields. In this case, an single tuple
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("message"));
    }
}
