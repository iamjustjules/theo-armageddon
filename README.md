# theo-armageddon
theo's armageddon (task1, task2, and task3) updated for security purposes

TASK1

Task 1

- Create a publicly accessible bucket in GCP with Terraform.  You must complete the following tasks.
    - Terraform script
    - Git Push the script to your Github
    - Output file must show the public link
    - Must have an index.html file within

Create a terraform providers.tf, main.tf, variables.tf, and outputs.tf with a publicly accessible bucket in GCP with an "index.html" file, "Jandk.png" file, and "JandN.jpg" file uploaded to the bucket in us-central1 and have the output show the public URL for index.html file that also displays the parameters of the bucket

Here's an explanation of each block in the Terraform script:

Resource Block: “google_storage_bucket” "public_bucket"
Description:
- This block creates a Google Cloud Storage bucket with specified attributes.
- “name”: Uses the variable “var.bucket_name” to set the bucket's name.
- “location”: Sets the bucket's location using “var.region”.
- “storage_class”: Sets the storage class to "STANDARD", which is a cost-effective storage option for data accessed less frequently.
- “uniform_bucket_level_access”: Enables uniform bucket-level access, simplifying permission management by removing object-level ACLs.
- “website”: Configures the bucket as a static website. “main_page_suffix” specifies the main page (index.html) and “not_found_page” specifies the error page (404.html) for requests to non-existing pages.
- “cors”: Sets Cross-Origin Resource Sharing (CORS) rules allowing all domains (“*”) to perform “GET” and “HEAD” requests.
Relation to Other Blocks:
- It serves as the foundation for the “google_storage_bucket_iam_binding” and “google_storage_bucket_object” resources, providing the bucket context in which they operate.

Resource Block: “google_storage_bucket_iam_binding” "public_read"
Description:
- This block assigns the IAM role of “objectViewer” to “allUsers”, making the bucket's contents publicly readable.
- “bucket”: Specifies the bucket name using “google_storage_bucket.public_bucket.name”, linking it to the previously defined bucket resource.
- “role”: Assigns the “storage.objectViewer” role, which allows users to view objects stored in the bucket.
- “members”: Specifies “allUsers”, indicating that anyone on the internet can access the objects.

Relation to Other Blocks:
- It directly modifies the IAM policy of the “google_storage_bucket.public_bucket” to allow public access, crucial for serving the static website content globally.

Resource Block: “google_storage_bucket_object” "index"
Description:
- Creates an object “index.html” within the bucket.
- “name”: Sets the object's name to "index.html".
- “bucket”: Links to the “google_storage_bucket.public_bucket” to define where the object should reside.
- “content”: Defines the HTML content of the webpage.
- “content_type”: Specifies the MIME type as “text/html”.
Relation to Other Blocks:
- It adds content to the bucket configured for static website hosting. This object is what will be served as the main page due to the website configuration in the bucket resource.

Variable Blocks: “project_id”, “region”, “bucket_name”
Description:
- These blocks define variables that are used throughout the Terraform configuration.
- “project_id”: Specifies the Google Cloud project ID.
- “region”: Specifies the region where resources will be created.
- “bucket_name”: Specifies the name of the bucket to be created.
Relation to Other Blocks:
- These variables are used to configure properties in the “google_storage_bucket” resource and can be referenced throughout the configuration to ensure consistency and reusability of values.

Output Block: “bucket_url”
Description:
- This block generates an output that displays the URL of the publicly accessible bucket.
- “value”: Constructs the URL using the bucket's name.
Relation to Other Blocks:
- Provides a user-friendly way to access the URL of the bucket created and configured by the earlier resource blocks, making it easy to verify and access the deployed resources.
Each block plays a distinct role in configuring the storage, accessibility, and interactivity of resources in your Google Cloud project. Together, they form a comprehensive Terraform configuration for deploying a static website hosted on a Google Cloud Storage bucket.

TASK2

Task 2

- Create a publicly accessible web page with Terraform.  You must complete the following
    - Terraform Script with a VPC
    - Terraform script must have a VM within your VPC.
    - The VM must have the homepage on it.
    - The VM must have an publicly accessible link to it.
    - You must Git Push your script to your Github.
    - Output file must show 1) Public IP, 2) VPC, 3) Subnet of the VM, 4) Internal IP of the VM.


Here's how each block works:

00-provider.tf
- Purpose: Sets up the Google Cloud provider necessary for managing resources on Google Cloud Platform (GCP).
- Details: It specifies the project ID, region, and credentials file that Terraform will use to authenticate and interact with GCP. It also ensures that a specific version of the Google provider is used, aligning with best practices for reliable and predictable deployments.

01-main.tf
- Google Storage Bucket: Configured to host a static website. “uniform_bucket_level_access” is enabled for simplified permission management, and a website configuration is provided to specify the main and error pages. CORS settings are configured to control cross-origin requests.
- Public IAM Binding: Grants public read access to all objects in the specified bucket, making it usable as a public static website.
- Storage Bucket Objects: Uploads “index.html” and images (“Jandk.png”, “JandN.jpg”) to the bucket, setting the correct content type for web hosting.
- Google Compute Network and Subnet: Creates a VPC (“just_jules_vpc”) without auto-creating subnetworks, and a subnet within this VPC with a specified CIDR block.
- Google Compute Instance: Sets up a virtual machine within the created subnet, using a predefined machine type and image. It configures a network interface connected to the subnet and sets a startup script to install and start Apache and deploy static files.

02-variables.tf
- Purpose: Defines variables used throughout the Terraform configuration. These variables allow the configuration to be reusable and customizable for different environments or needs.
- Variables: Include “project_id”, “bucket_name”, “region”, “zone”, and “machine_type”. These are used to parameterize the configuration so it can be adapted or scaled without modifying the core logic.

03-outputs.tf
- Purpose: Defines output values that are displayed to the user upon successful deployment. These provide useful information for further configuration or verification of the deployed resources.
- Outputs:
- Public IP: Shows the external IP address of the created VM, useful for accessing or managing the VM post-deployment.
- VPC and Subnet Names: Useful for referencing the network setup in additional configurations or scripts.
- Internal IP: Provides the internal IP of the VM, relevant in network-related configurations.
- Website URL: Outputs the URL where the static website is hosted, directly pointing to the “index.html” on GCS, providing immediate access to verify the website deployment.
Interactions and Dependencies
- The Google Compute Instance depends on the network and subnet to be correctly set up before it can be provisioned.
- The static website and VM utilize outputs from network and storage configurations, linking these resources functionally.
- IAM policies are directly tied to the bucket configuration, ensuring that the access permissions are aligned with the public accessibility needs of the website.
- CORS settings in the GCS bucket ensure that web browsers can appropriately fetch resources from the bucket when served as part of the website.

This Terraform setup is a comprehensive example of how to deploy a mixed infrastructure on GCP, including networking, compute, and storage resources, making it an excellent basis for building and expanding complex environments. Each component is modular yet interconnected, allowing for extensive customization and scalability.

TASK3

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


“00-provider.tf”
- Provider Configuration: Specifies that Google Cloud is the provider for the infrastructure resources. The “credentials” field refers to the JSON key file that contains your service account key, which Terraform will use to authenticate with Google Cloud.
- Project and Region: Sets default values for the project and region, which apply to all resources unless explicitly overridden. This simplifies resource definitions by not needing to specify these values repeatedly.
- Required Providers: This block specifies the version constraints for the Google Cloud provider, ensuring that Terraform uses an appropriate version of the provider that's compatible with your code.

“01-main.tf”
- Virtual Private Cloud (VPC) and Subnets:
- European VPC: Defines a VPC in Europe without auto-created subnets, allowing for manual subnet management.
- European Subnet: Specifies a subnet within the European VPC with a specific CIDR block and enables private Google access, which allows resources in the subnet to communicate with Google services without public IP addresses.
- American VPCs: Similar to the European setup, two VPCs are defined for America, again without auto-created subnets.
- American Subnets: Each American VPC has a dedicated subnet, defined with specific CIDR blocks.
- Asia Pacific VPC and Subnet: Follows the same pattern as other regions, with a VPC and a specific subnet for the Asia Pacific region.

“02-variables.tf”
- Variables: Defines variables “project_id”, “european_region”, “american_region1”, “american_region2”, and “asia_pacific_region”. These allow for dynamic input, which are used across the configuration to specify the deployment settings like region-specific resources.

“03-outputs.tf”
- Outputs: Outputs are used to easily access important information about the resources once Terraform applies the configurations. For instance:
- “european_vpc_id” and similar outputs for other regions provide the ID of the created VPCs, which can be useful for debugging, cross-referencing, or as inputs to other tools or scripts.
- Subnet ranges like “european_subnet_range” provide CIDR blocks of each created subnet, useful for network planning and management.

Interaction Among Blocks
- Resource Definitions and Variable Usage: Each resource block in “01-main.tf” uses variables from “02-variables.tf” to specify configurations like region, which makes the code reusable and adaptable to different environments without changing the core logic.
- Provider and Resource Dependency: The provider configuration in “00-provider.tf” must successfully authenticate and be configured correctly for the resources in “01-main.tf” to be provisioned in GCP.
- Outputs and Resource Attributes: The outputs in “03-outputs.tf” extract attributes from the resources defined in “01-main.tf”, such as VPC and subnet IDs or CIDR ranges. These outputs can be critical for further automation or integration with other systems.
This setup ensures a modular, understandable, and maintainable infrastructure-as-code environment where changes to the infrastructure can be managed with minimal adjustments to the code, primarily through the variables file or by updating resource definitions in “01-main.tf”. Each component plays a specific role and interacts with others through the use of shared variables and attributes, reflecting a well-structured Terraform project.
