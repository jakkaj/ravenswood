using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Microsoft.Extensions.Configuration;

namespace DataGenNetCore
{
    public class AppSecrets
    {
        public static IConfiguration Configuration { get; set; }
        public string EventHubConnectionString()
        {
            var builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json");
            Configuration = builder.Build();
            string connstr = Configuration["EventHubConnectionString"];
            return connstr;
        }

        public string EventHubPath()
        {
            var builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json");
            Configuration = builder.Build();
            string connstr = Configuration["EventHubPath"];
            return connstr;
        }
    }
}