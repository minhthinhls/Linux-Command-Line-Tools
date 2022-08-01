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
