## Create a new VM
List projects to get ID
```
gcloud projects list
```

Specify the Google Cloud project where you want to deploy:
```
gcloud config set project [PROJECT_ID]
```

Use the gcloud command to create a VM instance. For example:
```
gcloud compute instances create node-app-instance \
    --zone=europe-north1-a \
    --machine-type=e2-micro \
    --tags=http-server,https-server
```

Allow traffic to your VM instance:
(Here we are using port 8080 because it matches the port in the app)
```
gcloud compute firewall-rules create default-allow-http \
    --allow tcp:8080 \
    --source-ranges=0.0.0.0/0 \
    --target-tags http-server
```

## SSH into the VM
SSH into your newly created VM:
```
gcloud compute ssh node-app-instance --zone=europe-north1-a
```

## Install Node.js
Install Node.js and npm on the VM.
Once inside the VM:
```
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
```

## Upload to the VM

On your local machine, open a new terminal, use gcloud scp to copy your app files to the VM:
```
gcloud compute scp ./app.js node-app-instance:~/ --zone=europe-north1-a
```

## Run the app on the VM
If you need to get back into the VM, run this command again:
```
gcloud compute ssh node-app-instance --zone=europe-north1-a
```

Install dependencies
```
npm install
```

Run the app
```
node app.js
```