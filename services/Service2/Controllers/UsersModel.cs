using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Service1.Models
{
    public class UsersModel
    {
        public string UserId { get; set; }
        public string UserName { get; set; }
        public string UserSegment { get; set; }
        public string Service { get; set; }
    }

    public static class UserGen
    {
        public static List<UsersModel> GetUsers()
        {
            var l = new List<UsersModel>();

            l.Add(new UsersModel {UserId = "1000", UserName = "Amadeus Cho", UserSegment = "1"});
            l.Add(new UsersModel { UserId = "2000", UserName = "Miles Morales", UserSegment = "1" });
            l.Add(new UsersModel { UserId = "3000", UserName = "Cosmo The Space Dog", UserSegment = "1" });
            l.Add(new UsersModel { UserId = "4000", UserName = "Silk", UserSegment = "1" });
            l.Add(new UsersModel { UserId = "5000", UserName = "Fin Fang Foom", UserSegment = "2" });
            l.Add(new UsersModel { UserId = "6000", UserName = "Human Torch", UserSegment = "2" });
            l.Add(new UsersModel { UserId = "7000", UserName = "Jocasta", UserSegment = "2" });
            l.Add(new UsersModel { UserId = "8000", UserName = "The Leader", UserSegment = "2" });
            l.Add(new UsersModel { UserId = "9000", UserName = "Namor the Submariner", UserSegment = "2" });
            l.Add(new UsersModel { UserId = "10000", UserName = "Captain America", UserSegment = "2" });

            return l;
        }
    }

  
}
