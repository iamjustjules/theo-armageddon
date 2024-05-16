# theo-armageddon
theo's armageddon (task1, task2, and task3) updated for security purposes


Task 1

- Create a publicly accessible bucket in GCP with Terraform.  You must complete the following tasks.
    - Terraform script
    - Git Push the script to your Github
    - Output file must show the public link
    - Must have an index.html file within

These files work together individually and together:

00-providers.tf
This configures the providers needed. It specifies both the standard “google” provider and the “google-beta” provider, needed for accessing beta features.
- Provider Setup: Includes credentials, project ID, and region.
- ”required_providers” Block: Ensures that the correct provider versions are used.
- Purpose: Sets up the environment for Terraform to interact with Google Cloud resources.

01-main.tf
This is where the resources are defined.
- Google Storage Bucket: Configures a Google Cloud Storage (GCS) bucket to host a static website (“index.html” and images). It sets up website configuration, CORS settings, and enables uniform bucket-level access for better security.
- IAM Binding: Grants public read access to the objects in the bucket, making the website publicly accessible.
- Storage Bucket Objects: Defines objects like “index.html”, “Jandk.png”, and “JandN.jpg” to be uploaded to the GCS bucket.
- Secret Manager Data Source: Fetches a secret from Google Cloud Secrets Manager, showing how to integrate secret management within Terraform.

02-variables.tf
Defines variables used.
- Variables: Include “project_id”, “region”, “credentials”, and “bucket_name”. These are placeholders that are replaced with actual values during runtime, providing flexibility and reusability of the Terraform templates.

03-outputs.tf
Defines output variables.
- Website URL: Outputs the URL where the static website is hosted.
- Secret Value: Outputs the value of the secret fetched from Google Cloud Secrets Manager, marked as sensitive to prevent it from being displayed in logs or console output.

secrets.js
This is a Node.js script, not directly part of Terraform but related to managing secrets.
- Purpose: Demonstrates how to programmatically access secrets from Google Cloud Secrets Manager using the Google Cloud Node.js client library.
- Functionality: Connects to Secrets Manager, retrieves a secret, and logs its value. It’s an example of how application code might interact with secrets, separate from Terraform.

How They Work Together
- Terraform Files: Set up infrastructure (GCS bucket, objects, IAM policies) and securely fetch secrets as part of the infrastructure setup.
- Node.js Script: Represents a separate application layer or operational script used for secret management or dynamic configuration during runtime.

Features
- Security: The Terraform setup ensures that the bucket contents are publicly readable, suitable for a static website. It also uses Google Cloud Secrets Manager for sensitive data.
- Modularity: The use of variables and outputs makes the configuration modular and reusable, allowing parameters to be changed easily without altering the main configuration.
- Separation: This manages infrastructure, while the Node.js script manages runtime secret fetching for a separation between infrastructure provisioning and application runtime management.


Task 2

- Create a publicly accessible web page with Terraform.  You must complete the following
    - Terraform Script with a VPC
    - Terraform script must have a VM within your VPC.
    - The VM must have the homepage on it.
    - The VM must have an publicly accessible link to it.
    - You must Git Push your script to your Github.
    - Output file must show 1) Public IP, 2) VPC, 3) Subnet of the VM, 4) Internal IP of the VM.


Here's how each block works:
 
00-providers.tf
This file configures the providers:
- “google”: Used for most of the GCP resources.
- “google-beta”: Used for accessing beta features or resources that are only available in the beta provider.  
Both are configured with credentials, project ID, and region, so terraform can authenticate and interact with the project.

01-main.tf
This is where resources are created:
- Google Storage Bucket: Configured for hosting static content (HTML and images) with a specific CORS setting to allow web access and uniform bucket-level access for consistent permissions management.
- IAM Binding: Ensures the bucket’s contents are publicly accessible by binding the “storage.objectViewer” role to all users.
- Content Objects: HTML and image files are uploaded to the bucket. These objects are accessible via the bucket to serve as a static website.
- VPC and Subnetwork: Defines a VPC and a subnetwork for deploying a virtual machine, used for backend services and tasks.
- Virtual Machine: Configures a VM in the VPC/subnet to install and run a web server for a deployment.
- Secrets Manager Data Source: Pulls data from GCP Secrets Manager integrating secrets for secure access.

02-variables.tf
Defines all the variables used.

03-outputs.tf
Specifies output variables requested. The fetched secret is crucial for security.

secrets.js
This is a Node.js script, not directly part of Terraform but related to managing secrets.
-Purpose: Demonstrates how to programmatically access secrets from Google Cloud Secrets Manager using the Google Cloud Node.js client library.
-Functionality: Connects to Secrets Manager, retrieves a secret, and logs its value. It’s an example of how application code might interact with secrets, separate from Terraform.

How They Work Together
- The configuration sets up the infrastructure with the static website and network components. It integrates Secrets Manager to securely fetch and use the secret in the infrastructure.
- Node.js Script: Represents a separate application layer or operational script used for secret management or dynamic configuration during runtime.
- Outputs from Terraform provide crucial URLs and IP addresses that might be used by other systems or reported back to end users for direct access.

Features
- Security: The Terraform setup ensures that the bucket contents are publicly readable, suitable for a static website. It also uses Google Cloud Secrets Manager for sensitive data.
- Modularity: The use of variables and outputs makes the configuration modular and reusable, allowing parameters to be changed easily without altering the main configuration.
- Separation: This manages infrastructure, while the Node.js script manages runtime secret fetching for a separation between infrastructure provisioning and application runtime management.


Task 3

You must complete the following scenerio.

A European gaming company is moving to GCP.  It has the following requirements in it's first stage migration to the Cloud:

A) You must choose a region in Europe to host it's prototype gaming information.  This page must only be on a RFC 1918 Private 10 net and can't be accessible from the Internet.
B) The Americas must have 2 regions and both must be RFC 1918 172.16 based subnets.  They can peer with HQ in order to view the homepage however, they can only view the page on port 80.
C) Asia Pacific region must be choosen and it must be a RFC 1918 192.168 based subnet.  This subnet can only VPN into HQ.  Additionally, only port 3389 is open to Asia. No 80, no 22.

Deliverables.
1) Complete Terraform for the entire solution.
2) Git Push of the solution to your GitHub.
3) Screenshots showing how the HQ homepage was accessed from both the Americas and Asia Pacific. 

The primary reasons why the earlier version didn't work is because:
- Incorrect ordering led to errors. Depends_on ensured conditions were met before resource creation
- Misconfiguration in IP ranges. I reviewed other code to update modules, resources, and CIDR blocks correctly for peering.
- Lack of modularity led to issues. Reviewing the logging and error messages provided insights into specific fixes using terraform registry and online code
- Documentation review (https://cloud.google.com/architecture/building-internet-connectivity-for-private-vms#terraform) helped to gain insight on how to peer portions together correctly.

Here’s how this works:
- Data Flow: Variables are defined in “variables.tf” files and passed into resources or modules via the module's configuration in “.tf” files. Outputs generated by resources within a module are often made available to other modules or the root configuration.
- Execution Order: Terraform creates a dependency graph based on the resources' relationships and dependencies. For example, a VM instance might need to wait for its network and subnet to be created first, handled automatically by Terraform.
- Module Reusability: By encapsulating related resources in modules (like a VPC with its networking rules and VM instances), you can reuse this setup in different environments or projects by changing the input variables.
Interaction Between Root and Modules
Understanding the interaction between the root configuration and modules in Terraform can significantly streamline your infrastructure as code practices. Let’s dive deeper into how these components interact within your Terraform setup:
Root Configuration
The root configuration is essentially the entry point of your Terraform project. It's where you define provider settings, backends, required versions, and where you invoke modules. The root configuration can also include resource definitions, but in large projects, most resources are managed inside modules to keep the root clean and maintainable.
Modules
Modules in Terraform serve as containers for multiple resources that are logically grouped together. They enable you to organize, reuse, and encapsulate complex setups. Each module can have its own set of resources, variables, outputs, and even other modules, creating a hierarchical structure.

The interaction between the root configuration and modules occurs primarily through:
- Module Invocation: From the root configuration, you invoke modules by specifying the module source and passing input variables required by the module. These variables are defined in the module’s “variables.tf” file and set in the module block at the root.
- Variable Passing: Variables provide a way to customize modules each time they are used. The root configuration passes values to these variables, which influence how the resources within the module are configured.
- Accessing Module Outputs: The root configuration can access outputs from modules to use these values in other parts of your Terraform configuration or other modules. This is how different modules often interconnect.
- Providers and Modules: While providers can be configured within modules, it's a common practice to configure providers in the root configuration to ensure consistency across all modules and manage provider versions and settings centrally.

Practical Example of Module Interaction
- Peering Module: In your configuration, the peering module is used to set up network peering between America and Europe networks. It requires network IDs from both the America and Europe modules.
Here, the root configuration acts as a mediator that passes necessary outputs from the America and Europe modules into the Peering module as inputs. This kind of data flow typifies the modular approach in Terraform, allowing each module to be self-contained yet interdependent through well-defined interfaces.
The root configuration is used to orchestrate the deployment with modules with the necessary parameters stitching outputs together to form the system. Modules hold resources and configurations to be reusable across infrastructure. Each component provides flexibility, reusability, and data flow between modules and back to the user or other parts of the configuration.

