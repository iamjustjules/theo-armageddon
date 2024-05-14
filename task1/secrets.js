const {SecretManagerServiceClient} = require('@google-cloud/secret-manager');
const client = new SecretManagerServiceClient();

async function accessSecret() {
  const [version] = await client.accessSecretVersion({
    name: 'projects/terraform-gcp-justjules/secrets/service-account-key/versions/latest'
  });

  const payload = version.payload.data.toString('utf8');
  console.log(`Payload: ${payload}`);
}

accessSecret();
