# Working with Data using Azure Functions
Azure Functions are an ideal solution for a variety of scenarios, such as data processing on a transactional or event-driven basis. This repository provides materials that help you explore how you can interact with Azure SQL, Cosmos DB, Event Hubs, and other services to take a lightweight, code-first approach to building APIs, integrations, ETL, and maintenance routines. With Azure Functions, you can focus on your code and let the serverless compute service take care of the infrastructure, providing an integrated programming model and an end-to-end development experience that simplifies the build, deployment, and management of your applications. 

## Resources

### Table of contents

1. **Infrastructure as code:** [main.bicep](./bicep/main.bicep)
1. **Example Functions:**

    1. Timer triggered function with an Event Hub output: [TimerToEH.cs](TimerToEH.cs)
    1. Event Hub triggered function with a Cosmos DB output: [EHtoCosmosDB](./EHtoCosmosDB.cs)
    1. Cosmos DB change-feed triggered function with an Azure SQL output: [CosmosDBtoSQL](/CosmosDBtoSQL.cs)

### Additional resources

1. [Getting started with Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-get-started)
2. [Azure Functions Developer Guide](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference)
2. [Learn with our Cloud Skills Challenge](https://aka.ms/sqlbits-dwf)

## Contributors

* **Liam Moat**

    * GitHub: [@liammoat](https://github.com/liammoat)
    * LinkedIn: [@liammoatcom](https://www.linkedin.com/in/liammoatcom/)
    * Website: [www.liammoat.com](https://www.liammoat.com)

* **Steph Locke**

    * GitHub: [@stephlocke](https://github.com/stephlocke)
    * Twitter: [@theStephLocke](https://www.twitter.com/theStephLocke)
    * LinkedIn: [www.kunalbabre.com](https://www.linkedin.com/in/stephanielocke/)