using System;
using System.IO;
using System.Threading;

namespace HeartMonitorFS
{
    class Program
    {
        static void Main(string[] args)
        {
            var file = Environment.GetEnvironmentVariable("HEART_BEAT_FOLDER");

            var thisCluster = Environment.GetEnvironmentVariable("THIS_CLUSTER");
            var thatCluster = Environment.GetEnvironmentVariable("THAT_CLUSTER");

            //if we're the a cluster do not block the image load
            if(thisCluster == "a"){
                Environment.Exit(0);
            }

            var fi = new FileInfo(Path.Combine(file, thatCluster, "heartbeat.txt"));

            Console.WriteLine($"Reading from {fi.FullName}");           

            while(true){
                try{                   
                    
                    var data = File.ReadAllText(fi.FullName);

                    var parsed = new DateTime(Convert.ToInt64(data));
                    var utc = DateTime.SpecifyKind(parsed, DateTimeKind.Utc);

                    if (DateTime.UtcNow > utc.AddSeconds(10))
                    {
                        Console.WriteLine("Other cluster update too old - flatlining");
                        //exit with 0 to ensure the initContainer allows the waiting containers to spin up
                        Environment.Exit(0);
                    }
                    
                    Console.WriteLine($"{DateTime.Now.ToLongDateString()} {DateTime.Now.ToLongTimeString()} Remote host updates within normal operating parameters");

                    Thread.Sleep(5000);
                }catch(Exception ex){
                    Console.WriteLine(ex);
                }
            }
        }
    }
}
