using System;
using System.Collections.Generic;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using SqlBits.Common;
namespace SqlBits.Functions
{
    public static class CosmosDBtoSQL
    {
        [FunctionName("CosmosDBtoSQL")]
        public static void Run([CosmosDBTrigger(
            databaseName: "CorpDB",
            collectionName: "people",
            ConnectionStringSetting = "cdb",
            LeaseCollectionName = "leases")]IReadOnlyList<Document> input,
            // sql output with async collector of persons, connection sql
            [Sql("sqlbits.person", connectionStringSetting: "sql")]IAsyncCollector<Person> outputEvents,
            ILogger log)
        {
            if (input != null && input.Count > 0)
            {
                // for each document create a person and map Id and name from document then add to outputEvents
                foreach (var doc in input)
                {
                    var person = new Person
                    {
                        Id = Guid.Parse(doc.Id),
                        Name = doc.GetPropertyValue<string>("Name")
                    };
                    outputEvents.AddAsync(person);
                }
            }
        }
    }
}
