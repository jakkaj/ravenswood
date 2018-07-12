using System;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using Microsoft.Azure.EventHubs;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Threading;

namespace DataGenNetCore
{
    class Program
    {
        static AppSecrets secrets = new AppSecrets();
        static List<string> users = SampleData.Users();
        static EventHubClient hubClient;
        static Random random = new Random();


        private static async Task sendMessages(string velocity)
        {
            Boolean keepProcessing = true;
            Int32 delay = 1000;
            DateTime timeStamp = DateTime.Now;
            Int32 messageCount = 0;

            switch (velocity)
            {
                case "slow":
                    timeStamp = DateTime.Now;
                    delay = 1 * 2000;
                   
                    while (keepProcessing)
                    {
                        await sendMessage(true);
                        messageCount += 1;                        
                        if (timeStamp.AddSeconds(15) <= DateTime.Now)
                        {
                            var diffInSeconds = (DateTime.Now - timeStamp).TotalSeconds;
                            Console.WriteLine("Sent {0} messages in {1} seconds at a rate of {2} messages/min", messageCount, diffInSeconds, Math.Round((messageCount / diffInSeconds)*60));
                            timeStamp = DateTime.Now;
                            messageCount = 0;
                        }
                        Thread.Sleep(delay);
                    }
                    break;
                case "fast":
                    timeStamp = DateTime.Now;
                    delay = 0;
                
                    //docker run error: "Cannot see if a key has been pressed when either application does not have a console or when console input has been redirected from a file. Try Console.In.Peek."
                    //while (!(Console.KeyAvailable && Console.ReadKey(true).Key == ConsoleKey.Escape))
                    while (keepProcessing)
                    {
                        await sendMessage(false);
                        messageCount += 1;
                        if (timeStamp.AddSeconds(15) <= DateTime.Now)
                        {
                            var diffInSeconds = (DateTime.Now - timeStamp).TotalSeconds;
                            Console.WriteLine("Sent {0} messages in {1} seconds at a rate of {2} messages/min", messageCount, diffInSeconds, Math.Round((messageCount / diffInSeconds)*60));
                            timeStamp = DateTime.Now;
                            messageCount = 0;
                        }
                        Thread.Sleep(delay);
                    }
                    break;
                case "faster":
                    timeStamp = DateTime.Now;
                    delay = 0;
                    //docker run error: "Cannot see if a key has been pressed when either application does not have a console or when console input has been redirected from a file. Try Console.In.Peek."
                    //while (!(Console.KeyAvailable && Console.ReadKey(true).Key == ConsoleKey.Escape))
                    while (keepProcessing)
                    {
                        int parallelCount = 10;
                        Parallel.For(0, parallelCount,  index => {
                            sendMessage(false);
                            Interlocked.Add(ref messageCount, 1);
                        });                            
                        if (timeStamp.AddSeconds(15) <= DateTime.Now)
                        {
                            var diffInSeconds = (DateTime.Now - timeStamp).TotalSeconds;
                            Console.WriteLine("Sent {0} messages in {1} seconds at a rate of {2} messages/sec", messageCount, diffInSeconds, Math.Round(messageCount / diffInSeconds));
                            timeStamp = DateTime.Now;
                            messageCount = 0;
                        }       
                        
                    }
                    break;
                case "insane":
                    timeStamp = DateTime.Now;
                    delay = 0;
                    //docker run error: "Cannot see if a key has been pressed when either application does not have a console or when console input has been redirected from a file. Try Console.In.Peek."
                    //while (!(Console.KeyAvailable && Console.ReadKey(true).Key == ConsoleKey.Escape))
                    while (keepProcessing)
                    {
                        int parallelCount = 100;
                        Parallel.For(0, parallelCount, index => {
                            sendMessage(false);
                            Interlocked.Add(ref messageCount, 1);
                        });
                        if (timeStamp.AddSeconds(15) <= DateTime.Now)
                        {
                            var diffInSeconds = (DateTime.Now - timeStamp).TotalSeconds;
                            Console.WriteLine("Sent {0} messages in {1} seconds at a rate of {2} messages/sec", messageCount, diffInSeconds, Math.Round(messageCount / diffInSeconds));
                            timeStamp = DateTime.Now;
                            messageCount = 0;
                        }
                    }
                    break;
                default:
                    Console.WriteLine("No sendmessages velocity specified, no messages sent.");
                    break;
            }
        }

        private static async Task sendMessage(bool outputToConsole)
        {
            Guid messageId = Guid.NewGuid();
            Int32 randomUser = 0;

            Int32.TryParse(users[random.Next(0, users.Count)], out randomUser);
            var message = new Message
            {
                messageDate = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"),
                messageId = messageId.ToString(),
                userId = randomUser,
                value = random.Next(1, 65536)
            };
            var messagestringjson = JsonConvert.SerializeObject(message, new JsonSerializerSettings() { ContractResolver = new CamelCasePropertyNamesContractResolver() });
            EventData data = new EventData(Encoding.UTF8.GetBytes(messagestringjson));
            try
            {
                await hubClient.SendAsync(data);
                if (outputToConsole) {
                    Console.WriteLine("Sent: {0}", messagestringjson);
                }
            }
            catch (EventHubsException e)
            {
            }
        }        

        public static void Main(string[] args)
        {
            MainAsync(args).GetAwaiter().GetResult();
        }
        private static async Task MainAsync(string[] args)
        {
            var result = 0;

            Console.WriteLine("Message Sender Data Generator: usage: dotnet DataGenNetCore.dll sendmessages (slow|fast|faster|insane)");
            Console.WriteLine("Press ESC to stop");

            var app = new Microsoft.Extensions.CommandLineUtils.CommandLineApplication();

            var sendmessages= app.Command("sendmessages", config => {
                config.OnExecute(() => {
                    config.ShowHelp(); //show help for catapult
                    return 1; //return error since we didn't do anything
                });
                config.HelpOption("-? | -h | --help"); //show help on --help
            });
            sendmessages.Command("help", config => {
                config.Description = "get help!";
                config.OnExecute(() => {
                    sendmessages.ShowHelp("sendmessages");
                    return 1;
                });
            });
            sendmessages.Command("slow", config => {
                config.Description = "run message sending with 1 second thread sleep (slow)";
                config.HelpOption("-? | -h | --help");
                config.OnExecute(async() => {
                    Console.WriteLine("using slow mode (1 message every five seconds using thread.sleep)");
                    await sendMessages("slow");              
                    return 0;
                });
            });
            sendmessages.Command("fast", config => {                
                config.Description = "run message sending with no thread sleep (fast)";
                config.HelpOption("-? | -h | --help");
                config.OnExecute(async() => {
                    Console.WriteLine("using fast mode (single thread, no delay)");
                    await sendMessages("fast");
                    return 0;
                });
            });
            sendmessages.Command("faster", config => {
                config.Description = "run parallel for loop message sending (fastest)";
                config.HelpOption("-? | -h | --help");
                config.OnExecute(async () => {
                    Console.WriteLine("using faster mode (10 threads via parallel.for, no delay)");
                    await sendMessages("faster");
                    return 0;
                });
            });
            sendmessages.Command("insane", config => {
                config.Description = "run parallel for loop message sending (insane)";
                config.HelpOption("-? | -h | --help");
                config.OnExecute(async () => {
                    Console.WriteLine("using insane mode (100 threads via parallel.for, no delay)");
                    await sendMessages("insane");
                    return 0;
                });
            });

            //give people help with --help
            app.HelpOption("-? | -h | --help");
            try
            {
                var connectionStringBuilder = new EventHubsConnectionStringBuilder(secrets.EventHubConnectionString())
                {
                    EntityPath = secrets.EventHubPath()
                };

                hubClient = EventHubClient.CreateFromConnectionString(connectionStringBuilder.ToString());               
                app.Execute(args);
            }
            catch (Exception e)
            {
                app.HelpOption("-? | -h | --help");
                Console.WriteLine("Error occurred: {0}", e.Message);            
            }
            Environment.Exit(result);
        }

        private static int GetRandomEventNum(int num_choices, List<int> choice_weight)
        {
            int sum_of_weight = 0;
            for (int i = 0; i < num_choices; i++)
            {
                sum_of_weight += choice_weight[i];
            }

            int rnd = random.Next(sum_of_weight);
            for (int i = 0; i < num_choices; i++)
            {
                if (rnd < choice_weight[i])
                    return i;
                rnd -= choice_weight[i];
            }

            return 1;
        }
    }
}
