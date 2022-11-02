---
After creating Snapshots for Load-Balancers, Masters, Workers.
Each of the Disk should be configured with GCE Cloud Providers.
Hence `/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf`
must have the corresponding configured `node_ip`.

Thus, Ansible Kubernetes Runtime (Step-2) must be re-run to apply
the following configuration before bootstrap Kubernetes Cluster.

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: CustomResourceDefinition.ApiExtensions.k8s.io "prometheus.monitoring.coreos.com" is invalid: metadata.annotations: Too long: must have at most 262144 bytes.
# @see {@link https://github.com/prometheus-community/helm-charts/issues/1500#issuecomment-968619283}.
# @resolve {@link https://medium.com/pareture/kubectl-install-crd-failed-annotations-too-long-2ebc91b40c7d}.
# @resolve {@link https://github.com/prometheus-operator/prometheus-operator/issues/4355#issuecomment-955881550}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
> kubectl create --filename /root/Linux-Command-Line-Tools/k8s-bootstrap/resources/kubernetes/prometheus/manifests/setup/ ;
> kubectl create --filename /root/Linux-Command-Line-Tools/k8s-bootstrap/resources/kubernetes/prometheus/manifests/setup/0prometheusCustomResourceDefinition.yaml ;
> kubectl apply --filename /root/Linux-Command-Line-Tools/k8s-bootstrap/resources/kubernetes/prometheus/manifests/ ;

---
@description: Get ArgoCD Default Admin Password within Kubernetes Secret.
> echo $(kubectl --namespace argocd-system get secret argocd-initial-admin-secret --output jsonpath="{.data.password}" | base64 --decode);
> export ADMIN_PASSWORD="$(kubectl --namespace argocd-system get secret argocd-initial-admin-secret --output jsonpath="{.data.password}" | base64 --decode)";

---
@description: Change [Default] Admin Password within Kubernetes [ArgoCD] Server.
> kubectl apply --filename /root/Linux-Command-Line-Tools/k8s-bootstrap/resources/kubernetes/argocd-config.yaml ;
> kubectl apply --filename /root/Linux-Command-Line-Tools/k8s-bootstrap/resources/kubernetes/rest-api/ ;
> kubens argocd-system ; k8s-exec pod/argocd-server ;
> argocd login argocd-server.argocd-system.svc.cluster.local --username admin --grpc-web-root-path / ;
> argocd account update-password --account admin --new-password 12345678 --current-password <ADMIN_PASSWORD> ;
> argocd account update-password --account guest --new-password 12345678 --current-password <ADMIN_PASSWORD> ;

---
@description: Create ArgoCD Guest User and Apply Guest Password via Kubernetes ArgoCD ConfigMap.
@ref {@link <PROJECT>/k8s-bootstrap/resources/kubernetes/argocd-config.yaml}

---
@description: Get Jenkins Default Admin Password within Kubernetes Container.
> echo $(cat /var/jenkins_home/secrets/initialAdminPassword);

---
@description: Install Jenkins Plugin: [Kubernetes, Kubernetes CLI, Git, Gitlab, Credentials, Credentials Binding, ...etc].
@see {@link https://jenkins.e8s.io/pluginManager/available}

---
@description: Install Jenkins Plugin: [Generic Webhook Trigger, ...etc].
@see {@link https://cloudbooklet.com/jenkins-how-to-build-a-specific-branch-on-github/}
@see {@link https://stackoverflow.com/questions/32108380/jenkins-how-to-build-a-specific-branch#67832392}

---
@description: Configure RBAC Permission :: [Admin, Guess, ...etc].
@see {@link https://docs.bitnami.com/azure-templates/apps/jenkins/troubleshooting/configure-jenkins-security/}

@description: Create [Guess] User and Apply Read-Only Permission.
@target {@link https://jenkins.e8s.io/configureSecurity/}
@target {@link https://jenkins.e8s.io/securityRealm/}

---
@description: Resolve No Valid Crumb on Jenkins HTTP Request pass-through Reverse-Proxy (NGINX).
@see {@link https://stackoverflow.com/questions/44711696/jenkins-403-no-valid-crumb-was-included-in-the-request}
@see {@link https://jenkins.e8s.io/configureSecurity/}
>> [CSRF Protection]::[Enable Proxy Compatibility]

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
@description: Prevent Jenkins Built on specific Branches: [Master, ...etc].
>> Build Triggers >> When Changes pushed to GitLab. GitLab webhook URL: <WEB-URL>
>> Filter Branches by Names >> Fill-in [master]

---
@description: Prometheus Tutorial.
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
