---
After creating Snapshots for Load-Balancers, Masters, Workers.
Each of the Disk should be configured with GCE Cloud Providers.
Hence `/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf`
must have the corresponding configured `node_ip`.

Thus, Ansible Kubernetes Runtime (Step-2) must be re-run to apply
the following configuration before bootstrap Kubernetes Cluster.

---
Get ArgoCD Default Admin Password within Kubernetes Secret.
> echo $(kubectl --namespace argocd-system get secret argocd-initial-admin-secret --output jsonpath="{.data.password}" | base64 --decode);

---
Get Jenkins Default Admin Password within Kubernetes Container.
> echo $(cat /var/jenkins_home/secrets/initialAdminPassword);

---
@description: Jenkins Tutorial
@see {@link https://youtube.com/watch?v=eRWIJGF3Y2g/}
@see {@link https://devopscube.com/jenkins-build-agents-kubernetes/}
@see {@link https://github.com/marcel-dempers/docker-development-youtube-series/blob/master/jenkins/readme.md}
--------------------------------------------------------------------------------------------------------------
@access {@link https://jenkins.e8s.io/configureClouds/}
> Namespace: jenkins-system
> Jenkins URL: http://jenkins.jenkins-system.svc.cluster.local:8080
> Pod Labels:
  + Key: jenkins
  + Value: agent

> Pod Templates:
  + Name: jenkins-agent
  + Namespace: jenkins-system
  + Labels: jenkins-agent # [Step 6: Matching Labels Expression]
  > Container Templates:
    + Name: jnlp
    + Docker Image: jenkins/inbound-agent:4.3-4
    + Working Directory: /home/jenkins/agent
    + Command to Run: <empty>
    + Command Arguments: <empty>

---
@description: Prometheus Tutorial
@see {@link https://github.com/prometheus-operator/kube-prometheus/}
> kubectl apply --server-side --filename ./resources/kubernetes/prometheus/manifests/setup/;
> until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done;
> kubectl apply --filename ./resources/kubernetes/prometheus/manifests/;

@error: Cannot fetch Nodes Metrics.
@see {@link https://github.com/kubernetes-sigs/prometheus-adapter/issues/385#issuecomment-847813605}
@see {@link https://github.com/kubernetes-sigs/prometheus-adapter/issues/398#issuecomment-847859835}
@see {@link https://github.com/kubernetes-sigs/prometheus-adapter/issues/398#issuecomment-943663327}

@refer: Please refer to the following sources from Kube Prometheus Legacy Projects.
@see {@link https://github.dev/prometheus-operator/kube-prometheus/tree/release-0.10/}
@see {@link https://github.dev/prometheus-operator/kube-prometheus/tree/release-0.11/}

---
