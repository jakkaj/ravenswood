using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Microsoft.Extensions.Configuration;

namespace DataGenNetCore
{
    public static class SampleData
    {
        public static IConfiguration Configuration { get; set; }
        public static List<string> Users()
        {
            var builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("users.json");
            Configuration = builder.Build();
            string users = Configuration["Users"];            
            List<string> list = new List<string>(users.Split(","));
            return list;
        }

    }
}
