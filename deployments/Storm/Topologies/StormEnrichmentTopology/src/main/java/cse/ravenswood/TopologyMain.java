package cse.ravenswood;

import org.apache.storm.Config;
import org.apache.storm.LocalCluster;
import org.apache.storm.topology.TopologyBuilder;
import org.apache.storm.tuple.Fields;
import org.apache.storm.eventhubs.spout.EventHubSpout;
import org.apache.storm.eventhubs.spout.EventHubSpoutConfig;
import org.apache.storm.flux.wrappers.bolts.LogInfoBolt;

public class TopologyMain {
	public static void main(String[] args) throws InterruptedException {

		TopologyBuilder builder = new TopologyBuilder();

        // Just for development purposes (will be passed via ENV in flux yaml)
        String readPolicyName = "reader";
        String readPolicyKey = "0c2KnP1IQWST42OR/KnHVoWuZhjUEVar0Wu32g5DGbk=";
        String ehNs = "laceehns01";
        String ehName = "laceeh01";
        int ehPartitions = 2;
        String enrichUrl1 = "http://localhost:8001";
        String enrichUrl2 = "http://localhost:8002";

        // Spout
        builder.setSpout("eventhub-spout", 
            new EventHubSpout(
                new EventHubSpoutConfig(readPolicyName, readPolicyKey, ehNs, ehName, ehPartitions)
            )
        );

        // Parser Bolt
		builder.setBolt("parser-bolt", new ParserBolt(), 1)
        .shuffleGrouping("eventhub-spout");

        // Enrich Bolt 1
		builder.setBolt("enrich-bolt-1", new EnrichBolt(enrichUrl1), 1)
				.shuffleGrouping("parser-bolt");

        // Enrich Bolt 2
        builder.setBolt("enrich-bolt-2", new EnrichBolt(enrichUrl2), 1)
                .shuffleGrouping("enrich-bolt-1");
                
        // Log Bolt
        builder.setBolt("log-bolt", new LogInfoBolt(), 1)
            .shuffleGrouping("enrich-bolt-2");

		Config conf = new Config();
		conf.setDebug(true);

		LocalCluster cluster = new LocalCluster();
		try{
			cluster.submitTopology("eventhubenricher", conf, builder.createTopology());
			Thread.sleep(10000);
		}
		finally {
			cluster.shutdown();
		}
	}
}
