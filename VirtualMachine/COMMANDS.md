## Create a new VM
Navigate to the root of the project
```
cd path/to/project-root
```

List projects to get ID
```
gcloud projects list
```

Specify the Google Cloud project where you want to deploy:
```
gcloud config set project [PROJECT_ID]
```

Use the gcloud command to create a VM instance. For example:
* NOTICE: node-app-instance is the name of the instance you are creating
```
gcloud compute instances create node-app-instance --zone=europe-north1-a --machine-type=e2-micro --tags=http-server,https-server
```

Allow traffic to your VM instance:
(Here we are using port 8080 because it matches the port in the app)
```
gcloud compute firewall-rules create default-allow-http --allow tcp:8080 --source-ranges=0.0.0.0/0 --target-tags http-server
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

ALTERNATIVELY install nvm
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
```

Remember to run:
```
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

Check nvm was installed
```
nvm -v
```

And install Node.js

```
nvm install --lts
```

## Upload to the VM

On your local machine, open a new terminal, use gcloud scp to copy your app files to the VM:
```
gcloud compute scp ./app.js node-app-instance:~/ --zone=europe-north1-a
```

And the package.json file:
```
gcloud compute scp ./package.json  ccc-app:~/ --zone=europe-north1-a
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

## Visit the frontend

Find the IP address:
```
gcloud compute instances list
```

Which will give you a result like this:
```
NAME     ZONE             MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP   STATUS
ccc-app  europe-north1-a  e2-micro                   10.166.0.4   34.88.42.155  RUNNING
```

Then visit the app at `http://[EXTERNAL-IP]:8080`