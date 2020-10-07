apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitops-sample-server
spec:
  replicas: 2
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: gitops-sample-server
  template:
    metadata:
      labels:
        app: gitops-sample-server
    spec:
      containers:
        - name: gitops-sample-server
          image: gcr.io/PROJECT_ID/app:COMMIT_SHA
          command: ["/gitops-sample-server"]
          imagePullPolicy: Always
          resources:
            limits:
              cpu: 500m
              memory: 1000Mi
            requests:
              cpu: 200m
              memory: 500Mi
          ports:
            - containerPort: 8080
          envFrom:
            - secretRef:
                name: env-secret
          readinessProbe:
            exec:
              command: ["/bin/grpc_health_probe", "-addr=:8080"]
            initialDelaySeconds: 1
          livenessProbe:
            exec:
              command: ["/bin/grpc_health_probe", "-addr=:8080"]
            initialDelaySeconds: 1
        - name: envoy-proxy
          image: envoyproxy/envoy-alpine:v1.14.4
          command: ["/bin/sh", "-c", "/usr/local/bin/envoy -c /etc/envoy/envoy.yaml"]
          resources:
            limits:
              cpu: 500m
              memory: 500Mi
            requests:
              cpu: 100m
              memory: 100Mi
          ports:
            - name: app
              containerPort: 10000
            - name: envoy-admin
              containerPort: 8001
          volumeMounts:
            - name: envoy-volume
              mountPath: /etc/envoy
          readinessProbe:
            httpGet:
              scheme: HTTP
              path: /healthz
              httpHeaders:
                - name: x-envoy-livenessprobe
                  value: healthz
              port: 10000
            initialDelaySeconds: 3
          livenessProbe:
            httpGet:
              scheme: HTTP
              path: /healthz
              httpHeaders:
                - name: x-envoy-livenessprobe
                  value: healthz
              port: 10000
            initialDelaySeconds: 10
      volumes:
        - name: envoy-volume
          configMap:
            name: envoy-gitops-sample-server-config
