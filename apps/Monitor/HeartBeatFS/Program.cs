using System;
using System.IO;
using System.Threading;

namespace HeartBeatFS
{
    class Program
    {
        static void Main(string[] args)
        {
            
            var file = Environment.GetEnvironmentVariable("HEART_BEAT_FOLDER");

            var thisCluster = Environment.GetEnvironmentVariable("THIS_CLUSTER");
            var thatCluster = Environment.GetEnvironmentVariable("THAT_CLUSTER");

            var fi = new FileInfo(Path.Combine(file, thisCluster, "heartbeat.txt"));

            if(!fi.Directory.Exists){
                fi.Directory.Create();
            }

            Console.WriteLine($"Writing to {fi.FullName}");

            while(true){
                try{                   
                    Console.WriteLine($"Heart Heat: {DateTime.Now.ToLongDateString()} {DateTime.Now.ToLongTimeString()}");
                    File.WriteAllText(fi.FullName, DateTime.UtcNow.Ticks.ToString());
                    Thread.Sleep(5000);
                }catch(Exception ex){
                    Console.WriteLine(ex);
                }
            }
        }
    }
}
