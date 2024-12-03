Sender and Receiver Kubernetes Setup with One Image
This project demonstrates the deployment and communication between two applications, Sender and Receiver, using Kubernetes. The project includes two main setups:

Standard Service Deployment with ClusterIP services for inter-pod communication.
Headless Service Deployment for direct pod-to-pod communication.
Both Sender and Receiver are deployed from the same image.

Prerequisites
Kubernetes Cluster: Minikube or any other Kubernetes cluster.
kubectl: Installed and configured to access your Kubernetes cluster.
Docker: To build and push the Docker image for Sender.
Image: Docker image for the Sender and Receiver applications is hosted on Docker Hub:
peervetzler/sendandreceivemessages:latest
Step A: Standard Deployment with Services
In this setup, both the Sender and Receiver applications are exposed using Kubernetes services to enable communication between them.

1. Create Namespace
bash
Copy code
kubectl create namespace messages
2. Create Deployments
Create Sender and Receiver deployments using the same image, but with different roles:

Sender: sender-deployment.yaml
Receiver: receiver-deployment.yaml
Note: Even though we’re using the same image, the Receiver pod will run a different process (i.e., receive and store messages) from the Sender pod.

3. Create Services
Create services to expose the Sender and Receiver pods:

sender-service.yaml
receiver-service.yaml
4. Apply Resources
Apply the deployments and services to Kubernetes:

bash
Copy code
kubectl apply -f sender-deployment.yaml -n messages
kubectl apply -f receiver-deployment.yaml -n messages
kubectl apply -f sender-service.yaml -n messages
kubectl apply -f receiver-service.yaml -n messages
5. Verify Resources
To check the status of your resources, run:

bash
Copy code
kubectl get all -n messages
You should see the Sender and Receiver pods, deployments, and services.

6. Test Communication
To test communication between the applications, enter the Sender pod and send a POST request to the Receiver service:

bash
Copy code
kubectl exec -it sender-deployment-<pod-name> -n messages -- sh
curl -X POST http://receiver-service:5000/messages -H "Content-Type: application/json" -d '{"message": "Hello from Sender!"}'
Step B: Headless Service Deployment
In this setup, we use headless services to allow Sender to communicate directly with the Receiver pod by accessing its IP address.

1. Create Namespace
bash
Copy code
kubectl create namespace messages-headless
2. Create Headless Services
Create headless services to expose the Sender and Receiver pods:

sender-headless-service.yaml
receiver-headless-service.yaml
3. Create Deployments
Use the same Sender and Receiver deployment YAML files, but change the namespace to messages-headless:

sender-deployment-headless.yaml
receiver-deployment-headless.yaml
Note: Here, we use the same image for both pods, but we need to configure them differently (e.g., different environment variables or entry points) to distinguish between Sender and Receiver.

4. Apply Resources
Apply the headless services and deployments to Kubernetes:

bash
Copy code
kubectl apply -f sender-deployment-headless.yaml -n messages-headless
kubectl apply -f receiver-deployment-headless.yaml -n messages-headless
kubectl apply -f sender-headless-service.yaml -n messages-headless
kubectl apply -f receiver-headless-service.yaml -n messages-headless
5. Verify Resources
To check the status of your resources, run:

bash
Copy code
kubectl get all -n messages-headless
You should see the Sender and Receiver pods and headless services.

6. Test Communication (Pod-to-Pod)
Enter the Sender pod and use the pod IP of the Receiver to send a message directly:

bash
Copy code
kubectl exec -it sender-deployment-<pod-name> -n messages-headless -- sh
curl -X POST http://<receiver-pod-ip>:5000/messages -H "Content-Type: application/json" -d '{"message": "Hello from Sender!"}'
Get the Receiver pod IP:

bash
Copy code
kubectl get pods -n messages-headless -o wide
Conclusion
Step A demonstrates the use of Kubernetes services (ClusterIP) to enable communication between the Sender and Receiver applications.
Step B demonstrates the use of headless services to allow Sender and Receiver pods to communicate directly using their IP addresses.
Both setups are useful depending on your requirements for pod communication in Kubernetes.

