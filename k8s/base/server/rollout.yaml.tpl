apiVersion: argoproj.io/v1alpha1
kind: Rollout
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
          command: ["/server"]
          imagePullPolicy: Always
          resources:
            limits:
              cpu: 500m
              memory: 1000Mi
            requests:
              cpu: 200m
              memory: 500Mi
          ports:
            - containerPort: 9090
          envFrom:
            - secretRef:
                name: env-secret
          readinessProbe:
            exec:
              command: ["/bin/grpc_health_probe", "-addr=:9090"]
            initialDelaySeconds: 1
          livenessProbe:
            exec:
              command: ["/bin/grpc_health_probe", "-addr=:9090"]
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
            - name: https
              containerPort: 8081
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
              port: 8081
            initialDelaySeconds: 3
          livenessProbe:
            httpGet:
              scheme: HTTP
              path: /healthz
              httpHeaders:
                - name: x-envoy-livenessprobe
                  value: healthz
              port: 8081
            initialDelaySeconds: 10
      volumes:
        - name: envoy-volume
          configMap:
            name: envoy-gitops-sample-server-config
  strategy:
    blueGreen:
      # The ActiveService specifies the service to update with the new template hash at time of promotion.
      # This field is mandatory for the blueGreen update strategy.
      activeService: grpc-server-active
      # The PreviewService field references a Service that will be modified to send traffic to the new replicaset
      # before the new one is promoted to receiving traffic from the active service.
      previewService: grpc-server-preview
      # The AutoPromotionEnabled will make the rollout automatically promote the new ReplicaSet to the active service once the new ReplicaSet is healthy.
      # This field is defaulted to true if it is not specified.
      autoPromotionEnabled: false
      # The ScaleDownDelaySeconds is used to delay scaling down the old ReplicaSet after the active Service is switched to the new ReplicaSet.
      scaleDownDelaySeconds: 60
