apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitops-sample-gateway
spec:
  replicas: 2
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: gitops-sample-gateway
  template:
    metadata:
      labels:
        app: gitops-sample-gateway
    spec:
      containers:
        - name: gitops-sample-gateway
          image: gcr.io/PROJECT_ID/app:COMMIT_SHA
          resources:
            limits:
              cpu: 500m
              memory: 1000Mi
            requests:
              cpu: 200m
              memory: 500Mi
          command: ["/gitops-sample-proxy"]
          args: ["--grpc-server-endpoint=127.0.0.1:9090"]
          imagePullPolicy: "Always"
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /v1/health
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /v1/health
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
        - name: envoy-proxy
          image: envoyproxy/envoy-alpine:v1.14.4
          imagePullPolicy: Always
          command:
            - "/usr/local/bin/envoy"
          args:
            - "--config-path /etc/envoy/envoy.yaml"
          ports:
            - name: app
              containerPort: 10000
            - name: envoy-admin
              containerPort: 8001
          volumeMounts:
            - name: envoy-volume
              mountPath: /etc/envoy
      volumes:
        - name: envoy-volume
          configMap:
            name: envoy-gitops-sample-proxy-config
  strategy:
    blueGreen:
      # The ActiveService specifies the service to update with the new template hash at time of promotion.
      # This field is mandatory for the blueGreen update strategy.
      activeService: gitops-sample-gateway-active
      # The PreviewService field references a Service that will be modified to send traffic to the new replicaset
      # before the new one is promoted to receiving traffic from the active service.
      previewService: gitops-sample-gateway-preview
      # The AutoPromotionEnabled will make the rollout automatically promote the new ReplicaSet to the active service once the new ReplicaSet is healthy.
      # This field is defaulted to true if it is not specified.
      autoPromotionEnabled: false
      # The ScaleDownDelaySeconds is used to delay scaling down the old ReplicaSet after the active Service is switched to the new ReplicaSet.
      scaleDownDelaySeconds: 60
