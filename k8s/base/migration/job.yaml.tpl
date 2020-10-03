apiVersion: batch/v1
kind: Job
metadata:
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
    argocd.argoproj.io/sync-wave: "3"
  name: migration
  labels:
    job-name: migration-job
spec:
  ttlSecondsAfterFinished: 10
  backoffLimit: 0
  template:
    spec:
      containers:
        - name: migration
          image: gcr.io/PROJECT_ID/app:COMMIT_SHA
          command: ["goose"]
          args: ["-dir", ".gcp/migration/db/migrations", "mysql", "$(MYSQL_CONNECTION)", "up"]
          env:
            - name: MYSQL_CONNECTION
              valueFrom:
                secretKeyRef:
                  name: env-secret
                  key: MYSQL_CONNECTION
      restartPolicy: Never

---
apiVersion: batch/v1
kind: Job
metadata:
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
    argocd.argoproj.io/sync-wave: "1"
  name: start-continuous-delivery
  labels:
    job-name: start-continuous-delivery
spec:
  ttlSecondsAfterFinished: 10
  backoffLimit: 0
  template:
    spec:
      containers:
        - name: start-continuous-delivery
          image: gcr.io/PROJECT_ID/app:COMMIT_SHA
          command: ["/vi-job"]
          args: ["send-message-to-slack", "<Trigger>", "<Env>", "<ArgoCD Login URL>"]
          envFrom:
            - secretRef:
                name: env-secret
          volumeMounts:
            - name: service-account-file
              mountPath: /mnt
              readOnly: true
      volumes:
        - name: service-account-file
          secret:
            secretName: service-account-secret
      restartPolicy: Never

---
apiVersion: batch/v1
kind: Job
metadata:
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
    argocd.argoproj.io/sync-wave: "99"
  name: finish-migration
  labels:
    job-name: finish-migration
spec:
  ttlSecondsAfterFinished: 10
  backoffLimit: 0
  template:
    spec:
      containers:
        - name: finish-migration
          image: gcr.io/PROJECT_ID/app:COMMIT_SHA
          command: ["/vi-job"]
          args: ["send-message-to-slack", "<Trigger>", "<Env>", ""]
          envFrom:
            - secretRef:
                name: env-secret
          volumeMounts:
            - name: service-account-file
              mountPath: /mnt
              readOnly: true
      volumes:
        - name: service-account-file
          secret:
            secretName: service-account-secret
      restartPolicy: Never

---
apiVersion: batch/v1
kind: Job
metadata:
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
    argocd.argoproj.io/sync-wave: "99"
  name: finish-continuous-delivery
  labels:
    job-name: finish-continuous-delivery
spec:
  ttlSecondsAfterFinished: 10
  backoffLimit: 0
  template:
    spec:
      containers:
        - name: finish-continuous-delivery
          image: gcr.io/PROJECT_ID/app:COMMIT_SHA
          command: ["/vi-job"]
          args: ["send-message-to-slack", "<Trigger>", "<Env>", "<ArgoCD Login URL>"]
          envFrom:
            - secretRef:
                name: env-secret
          volumeMounts:
            - name: service-account-file
              mountPath: /mnt
              readOnly: true
      volumes:
        - name: service-account-file
          secret:
            secretName: service-account-secret
      restartPolicy: Never
