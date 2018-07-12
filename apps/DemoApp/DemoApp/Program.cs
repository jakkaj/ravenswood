using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using Microsoft.Extensions.Configuration;

namespace DemoApp
{
    class Program
    {
        static void Main(string[] args)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
                .AddEnvironmentVariables()
                .Build();

            DemoClient demoClient = new DemoClient(config);

            while (true)
            {
                try
                {
                    //var numRecords = demoClient.GetCosmosRecordCount();
                    //Console.WriteLine($"Number of records in CosmosDb: {numRecords}");

                    var lastRecord = demoClient.GetCosmosLastRecord();

                    Console.WriteLine("-- Raw --");
                    Console.WriteLine(lastRecord.ToString());

                    var result = (ResultModel) lastRecord;

                    Console.Clear();

                    Console.WriteLine($"MessageId: {result.messageId}, date: {result.messageDate}");
                    Console.WriteLine($"UserId: {result.userId}");
                    Console.WriteLine("");
                    Console.WriteLine("Enrichments");
                    Console.WriteLine($"\tUser Name: {result.body.userName}");
                    Console.WriteLine($"\tUser Segment: {result.body.userSegment}");
                    Console.WriteLine("");
                    Console.WriteLine("Services");
                    Console.WriteLine($"\tSVC1: {result.body.service}");
                    Console.WriteLine($"\tSVC2: {result.body.svc2}");
                    Console.WriteLine($"\tSVC3: {result.body.svc3}");

                    Console.WriteLine("");
                    Console.WriteLine("Cluster");

                    Console.WriteLine($"\t {result.body.cluster}");


                    Console.WriteLine("");
                    Console.WriteLine("");
                    Console.WriteLine("");
                    Console.WriteLine("-- Raw --");
                    Console.WriteLine(lastRecord.ToString());
                }
                catch (Exception e)
                {
                    Exception baseException = e.GetBaseException();
                    Console.WriteLine("Error: {0}, Message: {1}", e.Message, baseException.Message);
                }
                //Console.WriteLine("Press any key to query again...");
                Thread.Sleep(500);
            }
        }
    }
}

