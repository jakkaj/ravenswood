package cse.ravenswood;

import org.apache.storm.topology.base.BaseBasicBolt;

import java.util.Map;

import com.microsoft.azure.documentdb.ConnectionPolicy;
import com.microsoft.azure.documentdb.ConsistencyLevel;
import com.microsoft.azure.documentdb.Document;
import com.microsoft.azure.documentdb.DocumentClient;
import com.microsoft.azure.documentdb.DocumentClientException;
import com.microsoft.azure.documentdb.RequestOptions;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.BasicOutputCollector;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.tuple.Tuple;

import org.json.JSONObject;

public class CosmosWriterBolt extends BaseBasicBolt {

    private static final Logger LOG = LogManager.getLogger(CosmosWriterBolt.class.getName());
    private String _serviceEndpoint;
    private String _key;
    private String _databaseName;
    private String _collectionName;
    private DocumentClient _client;

    public CosmosWriterBolt(String serviceEndpoint, String key, String databaseName, String collectionName) {
        this._serviceEndpoint = serviceEndpoint;
        this._key = key;
        this._databaseName = databaseName;
        this._collectionName = collectionName;
    }

    @Override
    public void prepare(Map stormConf, TopologyContext context) {
        this._client = new DocumentClient(this._serviceEndpoint, this._key, new ConnectionPolicy(), ConsistencyLevel.Eventual);
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

        JSONObject obj = new JSONObject();
        obj.put("messageDate", messageDate);
        obj.put("messageId", messageId);
        obj.put("userId", userId);
        obj.put("value", value);
        obj.put("body", new JSONObject(body));
        obj.put("timestampUtc", timestampUtc);

        String collectionLink = String.format("/dbs/%s/colls/%s", this._databaseName, this._collectionName);

        try {
            LOG.info(String.format("Saving to database %s, collection %s, data: %s", this._databaseName, this._collectionName, obj.toString()));
            this._client.createDocument(collectionLink, new Document(obj.toString()), new RequestOptions(), false);
        } catch (DocumentClientException de) {
            LOG.error(de.getMessage());
        }
        
    }

	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
	}
}

