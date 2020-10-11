apiVersion: batch/v1
kind: Job
metadata:
#  annotations:
#    argocd.argoproj.io/hook: PreSync
#    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
#    argocd.argoproj.io/sync-wave: "3"
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
          image: gcr.io/PROJECT_ID/migration:COMMIT_SHA
          args: ["-path", "db/migrations", "-database", "mysql://$(MYSQL_CONNECTION)", "up"]
          env:
            - name: MYSQL_CONNECTION
              valueFrom:
                secretKeyRef:
                  name: env-secret
                  key: MYSQL_CONNECTION
      restartPolicy: Never
