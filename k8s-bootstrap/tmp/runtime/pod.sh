cat << EOF | kubectl apply --filename -
---
apiVersion: v1
kind: Pod
metadata:
  name: runtime
  namespace: default
  labels:
    app.kubernetes.io/name: runtime
    app.kubernetes.io/instance: runtime
    app.kubernetes.io/version: latest
spec:
  containers:
    - name: node
      image: node:18.12.1
      command:
        - cat
      tty: true
    - name: docker
      image: docker:20.10.21
      command:
        - cat
      tty: true
      volumeMounts:
        - mountPath: /var/run/docker.sock
          name: docker-sock
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock

EOF
