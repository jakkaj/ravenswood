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
        // GET: api/Enrich
        // GET: api/sdf
        [HttpGet]
        public ActionResult<UsersModel> Get([FromQuery] int id, [FromHeader] string stormuserSegment)
        {
            var envWriteBack = Environment.GetEnvironmentVariable("WRITE_BACK");

            var users = UserGen.GetUsers();

            var user = users.FirstOrDefault(_ => _.UserId == id.ToString());

            if (user == null)
            {
                return new UsersModel
                {
                    UserId = id.ToString(),
                    UserName = "Not Found",
                    UserSegment = "1", 
                    Service = envWriteBack
                };
            }

            user.Service = envWriteBack;

            return user;
        }
    }
}
