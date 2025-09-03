This solution uses n8n for ingestion and orchestration, Postgres for persistence, SQL for KPI modeling, and a flexible query approach for analyst access. The workflow is modular and can easily be extended with an API or natural-language interface.

Setup Instructions:

-Create a new worflow in n8n website.  
-Download Project Worflow.json from this repository.  
-Inside the new n8n worflow, import the Project Worflow.json.  
-Excecute worflow, upload the Dataset ads_spend.csv provided by the challenge owner.  
-Create a new project in Supabase, the data will be ingested there for peristence purposes.  
-Insert the Supabase database credentials inside Postgres nodes in n8n.
