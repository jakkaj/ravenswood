using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Service1.Models;

namespace Service1.Controllers
{
   

    [Route("api/[controller]")]
    [ApiController]
    public class EnrichController : ControllerBase
    {
        public static Guid HostGuid = Guid.Empty;

        static EnrichController()
        {
            HostGuid = Guid.NewGuid();
        }
        // GET: api/Enrich
        // GET: api/sdf
        [HttpGet]
        public Dictionary<string, string> Get()
        {
            var envWriteBack = Environment.GetEnvironmentVariable("WRITE_BACK");
            var envWriteField = Environment.GetEnvironmentVariable("WRITE_FIELD");

            var cluster = Environment.GetEnvironmentVariable("CLUSTER");

            var d = new Dictionary<string, string>();

            d.Add(envWriteField, envWriteBack);
            d.Add("cluster", cluster);
            d.Add("HostGuid", HostGuid.ToString());
            return d;
        }
    }
}
