using System;
using System.Collections.Generic;
using System.Text;

namespace DemoApp
{
    public class Body
    {
        public string svc2 { get; set; }
        public string svc3 { get; set; }
        public string service { get; set; }
        public string HostGuid { get; set; }
        public string userName { get; set; }
        public string userId { get; set; }
        public string userSegment { get; set; }
        public string cluster { get; set; }
    }

    public class ResultModel
    {
        public string messageId { get; set; }
        public string messageDate { get; set; }
        public long timestampUtc { get; set; }
        public string id { get; set; }
        public Body body { get; set; }
        public int userId { get; set; }
        public int value { get; set; }
        public string _rid { get; set; }
        public string _self { get; set; }
        public string _etag { get; set; }
        public string _attachments { get; set; }
        public int _ts { get; set; }
    }
}
