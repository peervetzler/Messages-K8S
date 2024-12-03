
# Kubernetes Messaging App Setup

This project demonstrates how to set up a basic messaging system using Kubernetes, where two pods (Sender and Receiver) can communicate with each other. It includes both a **standard service-based setup** and a **headless service setup**.

## Step A: Standard Deployment with Services

### 1. **Create Namespace**

First, create a Kubernetes namespace for your application:

```bash
kubectl create namespace messages
```

### 2. **Create Deployments**

Create the deployments for **Sender** and **Receiver**. Both use the same Docker image, but they have different roles in the system:

- **Sender Deployment**: `deployment-sender.yaml`
- **Receiver Deployment**: `deployment-receiver.yaml`

```yaml
# deployment-sender.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sender-deployment
  namespace: messages
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sender
  template:
    metadata:
      labels:
        app: sender
    spec:
      containers:
        - name: sender
          image: peervetzler/sendandreceivemessages:latest
          ports:
            - containerPort: 5000

# deployment-receiver.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: receiver-deployment
  namespace: messages
spec:
  replicas: 1
  selector:
    matchLabels:
      app: receiver
  template:
    metadata:
      labels:
        app: receiver
    spec:
      containers:
        - name: receiver
          image: peervetzler/sendandreceivemessages:latest
          ports:
            - containerPort: 5000
```

### 3. **Create Services**

Expose the **Sender** and **Receiver** pods using Kubernetes services. The services allow communication between the pods:

- **Sender Service**: `service-sender.yaml`
- **Receiver Service**: `service-receiver.yaml`

```yaml
# service-sender.yaml
apiVersion: v1
kind: Service
metadata:
  name: sender-service
  namespace: messages
spec:
  selector:
    app: sender
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
  type: ClusterIP

# service-receiver.yaml
apiVersion: v1
kind: Service
metadata:
  name: receiver-service
  namespace: messages
spec:
  selector:
    app: receiver
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
  type: ClusterIP
```

### 4. **Deploy the Configurations**

Run the following command to deploy all the resources (deployments and services) in the `messages` namespace:

```bash
kubectl apply -f sender-deployment.yaml
kubectl apply -f receiver-deployment.yaml
kubectl apply -f sender-service.yaml
kubectl apply -f receiver-service.yaml
```

---

## Step B: Headless Deployment

In this setup, both **Sender** and **Receiver** are deployed with headless services. Communication will be directly between pods, without using services to route traffic.

### 1. **Create Namespace**

First, create a new Kubernetes namespace for the headless setup:

```bash
kubectl create namespace messages-headless
```

### 2. **Create Headless Services**

Create **headless services** for both **Sender** and **Receiver**. The services are defined with `clusterIP: None`, which ensures direct communication between the pods.

- **Sender Headless**: `sender-headless-service.yaml`
- **Receiver Headless**: `receiver-headless-service.yaml`

```yaml
# Service-sender
apiVersion: v1
kind: Service
metadata:
  name: sender-service
  namespace: messages-headless
spec:
  clusterIP: None   # This is the headless service
  selector:
    app: sender
  ports:
    - port: 5000
      targetPort: 5000

# Service-receiver
apiVersion: v1
kind: Service
metadata:
  name: receiver-service
  namespace: messages-headless
spec:
  clusterIP: None   # This is the headless service
  selector:
    app: receiver
  ports:
    - port: 5000
      targetPort: 5000```

### 3. **Create Deployments**

Create the **Sender** and **Receiver** deployments, just like before, but this time in the `messages-headless` namespace:

```yaml
# sender deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sender-deployment
  namespace: messages-headless
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sender
  template:
    metadata:
      labels:
        app: sender
    spec:
      containers:
        - name: sender
          image: peervetzler/sendandreceivemessages:latest
          ports:
            - containerPort: 5000

# receiver deploymentapiVersion: apps/v1
kind: Deployment
metadata:
  name: receiver-deployment
  namespace: messages-headless
spec:
  replicas: 1
  selector:
    matchLabels:
      app: receiver
  template:
    metadata:
      labels:
        app: receiver
    spec:
      containers:
        - name: receiver
          image: peervetzler/sendandreceivemessages:latest
          ports:
            - containerPort: 5000
```

### 4. **Deploy the Configurations**

Deploy the configurations in the `messages-headless` namespace:

```bash
kubectl apply -f headless-sender.yaml
kubectl apply -f headless-receiver.yaml
```

---

## Testing Communication

### 1. **Access the Sender Pod**

You can access the **Sender** pod using `kubectl exec` to send messages to the **Receiver**:

```bash
kubectl exec -it <sender-pod-name> -n messages -- /bin/sh
```

### 2. **Send a POST Request**

Inside the **Sender** pod, use `curl` to send a message to the **Receiver** service. If you're using headless services, you'll address the Receiver pod directly by its IP or name.

```bash
curl -X POST http://receiver-service:5000/send -H "Content-Type: application/json" -d '{"message": "Hello Receiver!"}'
```
```bash
curl -X POST http://<pod-IP>:5000/send -H "Content-Type: application/json" -d '{"message": "Hello Receiver!"}'

For getting the IP of the pod:
kubectl get pods -n messages-headless -o wide

### 3. **Check the Receiver's Messages**
```
To verify the message was received, use `kubectl exec` to check the **Receiver** pod's message list:

```bash
kubectl exec -it <receiver-pod-name> -n messages -- curl http://localhost:5000/messages
```

---

## Cleanup

When you're done, you can delete the resources you created by running the following commands:

```bash
kubectl delete namespace messages
kubectl delete namespace messages-headless
```

---

## Notes

- The **headless service** setup allows the **Sender** pod to directly interact with the **Receiver** pod without the need for the Kubernetes service.
- Ensure that the `kubectl` context is set to the correct cluster and namespace when interacting with pods and services.
