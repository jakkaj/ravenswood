using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DemoApp
{
    public class DemoClient
    {
        private IConfiguration config;
        private DocumentClient client;

        private long cosmosLastTimestamp = -1;

        public DemoClient(IConfiguration config)
        {
            this.config = config;

            // Document Client
            this.client = new DocumentClient(new Uri(config["cosmos_service_endpoint"].ToString()),
                config["cosmos_key"].ToString());
        }

        public long GetCosmosRecordCount()
        {
            var results = client.CreateDocumentQuery(UriFactory.CreateDocumentCollectionUri(config["cosmos_database_name"], config["cosmos_collection_name"]),
                String.Format("SELECT VALUE COUNT(1) FROM c")).ToList();
            return results.FirstOrDefault();
        }

        public dynamic GetCosmosLastRecord()
        {
            try
            {
                var results = client.CreateDocumentQuery(UriFactory.CreateDocumentCollectionUri(config["cosmos_database_name"], config["cosmos_collection_name"]),
                String.Format("SELECT TOP 1 * FROM c ORDER BY c.timestampUtc DESC")).ToList();
                return results[0];
            }
            catch (DocumentClientException de)
            {
                Exception baseException = de.GetBaseException();
                Console.WriteLine("{0} error occurred: {1}, Message: {2}", de.StatusCode, de.Message, baseException.Message);
            }
            catch (Exception e)
            {
                Exception baseException = e.GetBaseException();
                Console.WriteLine("Error: {0}, Message: {1}", e.Message, baseException.Message);
            }
            return null;
        }

        //Statefull method
        public long GetCosmosRecordCountSinceLastCall()
        {
            var collectionUri = UriFactory.CreateDocumentCollectionUri(config["cosmos_database_name"], config["cosmos_collection_name"]);
            var results = client.CreateDocumentQuery(collectionUri, $"SELECT VALUE COUNT(1) FROM c WHERE c.timestampUtc > {cosmosLastTimestamp}").ToList();

            // Set lastTimestamp
            var maxTimestamp = client.CreateDocumentQuery(collectionUri, "SELECT VALUE MAX(c.timestampUtc) FROM c").ToList();
            this.cosmosLastTimestamp = maxTimestamp.FirstOrDefault();

            return results.FirstOrDefault();
        }
    }
}
