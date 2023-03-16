using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using SqlBits.Common;

namespace SqlBits.Functions
{
    public class TimerToEH
    {
        [FunctionName("TimerToEH")]
        public void Run([TimerTrigger("*/2 * * * * *")]TimerInfo myTimer,
        // eventhub output connection of eh, ns of primaryhub, using async person collector
        [EventHub("person", Connection = "eh")] IAsyncCollector<Person> outputEvents,        
        ILogger log)
        {
            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
            // create new person object with random guid id and name
            var person = new Person {
                Id = Guid.NewGuid(),
                Name = Guid.NewGuid().ToString()
            };

            // add person to outputEvents
            outputEvents.AddAsync(person);

        }
    }
}
