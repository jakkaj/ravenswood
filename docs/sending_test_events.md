<!-- TOC -->

- [Sending Test Events](#sending-test-events)
    - [Event Generator App](#event-generator-app)
        - [Edit the Configs](#edit-the-configs)
        - [Running the App](#running-the-app)
- [View Database Output](#view-database-output)
        - [Edit the Configs](#edit-the-configs-1)
        - [Running the App](#running-the-app-1)

<!-- /TOC -->

# Sending Test Events

If you're [Deployed the Bits](deploying_the_bits.md) then you'll need to know how to send some test events. 

To enable this there are some apps hidden away under the `/apps` folder that can generate events as well as read the outputted information from the database. 

## Event Generator App

Under `/apps/EventGenerator/DataGenNetCore` is a little [.NET Core](https://www.microsoft.com/net/download/dotnet-core/2.1) app that you can build to send some test events. 

### Edit the Configs

In the app edit the `appsettings.json` file and enter the Azure Event Hub connection information.

### Running the App

Make sure have the [.NET Core](https://www.microsoft.com/net/download/dotnet-core/2.1) SDK installed. 

```
dotnet restore
dotnet build
dotnet run sendmessages slow
```
... or fast, faster or insane. 

Checking the storm UI you can now see there are test events in the stream. 

![transitign](https://user-images.githubusercontent.com/5225782/43247884-673ea982-90f9-11e8-9dc5-811aac8a6b42.PNG)

Now it's time to see the outputs of this.

# View Database Output

Once the events are being generated, you can see the result of the encrichment stream. The events are emitted to the Event Hubs, processed by Storm via the various bolts and output the other side in to the database. This app reads the latest database record so we can view the enriched result. 

Make sure have the [.NET Core](https://www.microsoft.com/net/download/dotnet-core/2.1) SDK installed. 

Switch to /apps/DemoApp/DemoApp. 

### Edit the Configs

In the app edit the `appsettings.json` file and enter the Azure CosmosDB connection information.

### Running the App

```
dotnet restore
dotnet build
dotnet run
```

As long as the event emitter app is running then you will see some changing output like this:

```
MessageId: 274b4a4b-21eb-402a-927f-c46b914e0e00, date: 07/26/2018 07:35:29
UserId: 1000

Enrichments
        User Name: Amadeus Cho
        User Segment: 1

Services
        SVC1: svc1v1
        SVC2: svc2v1
        SVC3: svc3v1

Cluster
         a



-- Raw --
{"messageId":"274b4a4b-21eb-402a-927f-c46b914e0e00","messageDate":"2018-07-26T07:35:29Z","timestampUtc":1532590531901,"id":"6249001f-e33b-43c3-8900-1fe33bc3c389","body":{"cluster":"a","svc2":"svc2v1","svc3":"svc3v1","service":"svc1v1","HostGuid":"0b4aa4ac-e0ae-4133-97e8-8a7fbe9a4891","userName":"Amadeus Cho","userId":"1000","userSegment":"1"},"userId":1000,"value":3464,"_rid":"UPYnAPE9wADIlAAAAAAAAA==","_self":"dbs/UPYnAA==/colls/UPYnAPE9wAA=/docs/UPYnAPE9wADIlAAAAAAAAA==/","_etag":"\"01000973-0000-0000-0000-5b5979c30000\"","_attachments":"attachments/","_ts":1532590531}


```

This shows you the result of the services and other enrichments ready for demonstration with [Intelligent Routing!](intelligent_routing.md)