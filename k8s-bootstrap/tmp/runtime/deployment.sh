cat << EOF | kubectl apply --filename -
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-runtime
  namespace: default
spec:
  accessModes:
    - ReadWriteMany # ["ReadWriteOnce", "ReadOnlyMany", "ReadWriteMany"]
  storageClassName: longhorn-retain # ["gce-pd", "longhorn-delete", "longhorn-retain"]
  resources:
    requests:
      storage: 1Gi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: runtime
  namespace: default
  labels:
    app.kubernetes.io/name: runtime
    app.kubernetes.io/instance: runtime
    app.kubernetes.io/version: latest
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: runtime
      app.kubernetes.io/instance: runtime
      app.kubernetes.io/version: latest
  template:
    metadata:
      labels:
        app.kubernetes.io/name: runtime
        app.kubernetes.io/instance: runtime
        app.kubernetes.io/version: latest
    spec:
      serviceAccountName: controller-manager
      containers:
        - name: node
          image: node:18.12.1
          command:
            - cat
          tty: true
          volumeMounts:
            - name: pv-src
              mountPath: /usr/src/
        - name: docker
          image: docker:20.10.21
          command:
            - cat
          tty: true
          volumeMounts:
            - name: docker-sock
              mountPath: /var/run/docker.sock
            - name: pv-src
              mountPath: /usr/src/
      volumes:
        - name: docker-sock
          hostPath:
            path: /var/run/docker.sock
        - name: pv-src
          persistentVolumeClaim:
            claimName: pvc-runtime

EOF
