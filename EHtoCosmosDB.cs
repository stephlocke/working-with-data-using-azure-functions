using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using SqlBits.Common;

namespace SqlBits.Functions
{
    public static class EHtoCosmosDB
    {
        [FunctionName("EHtoCosmosDB")]
        public static async Task Run([EventHubTrigger("person", Connection = "eh")] EventData[] events,
        // cosmosdb output with container CorpDB, connection cdb with a schema of person
        [CosmosDB(databaseName: "CorpDB", collectionName: "people", ConnectionStringSetting = "cdb", CreateIfNotExists = true)] IAsyncCollector<Person> outputEvents,
        ILogger log)
        {
            var exceptions = new List<Exception>();

            foreach (EventData eventData in events)
            {
                try
                {
                   // convert eventbody to Person object
                   await outputEvents.AddAsync(eventData.EventBody.ToObjectFromJson<Person>());
                  
                }
                catch (Exception e)
                {
                    // We need to keep processing the rest of the batch - capture this exception and continue.
                    // Also, consider capturing details of the message that failed processing so it can be processed again later.
                    exceptions.Add(e);
                }
            }

            // Once processing of the batch is complete, if any messages in the batch failed processing throw an exception so that there is a record of the failure.

            if (exceptions.Count > 1)
                throw new AggregateException(exceptions);

            if (exceptions.Count == 1)
                throw exceptions.Single();
        }
    }
}
