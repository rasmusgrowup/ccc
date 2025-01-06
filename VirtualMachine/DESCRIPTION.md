This small app displays a message on the home route '/' on port 8080. The app runs on express.js.

The solution was created using the gloud CLI to 
create a new Google Cloud Virtual Machine instance
on one of my projects. The solution uses a cheap 
instance on the [INSERT ZONE] zone.

Firewall rules are created using the CLI, to configure
ip-ranges and to allow tcp traffic on port 8080.

I'm using the CLI to connect with SSH to the copy the 
app.js file and the package.json.

NVM gets installed on the instance, to be able to
use NPM and Node.js to run the application and
install dependencies. 