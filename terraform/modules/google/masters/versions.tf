# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Developer >> Terraform >> Tutorials >> Configuration Language >> Manage Terraform Versions.
# @see {@link https://developer.hashicorp.com/terraform/tutorials/configuration-language/versions}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
terraform {
    required_version = ">= 0.12"
    experiments = [module_variable_optional_attrs]
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    # @description: Project Dependencies for Kubernetes and Terraform.
    # @see {@link https://architect.io/blog/2021-02-17/terraform-kubernetes-tutorial/#project-dependencies-for-kubernetes-and-terraform}.
    # ------------------------------------------------------------------------------------------------------------------------------------------------
    required_providers {
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0.0"
        }
        helm = {
            source = "hashicorp/helm"
            version = ">= 2.0.0"
        }
    }
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Define Kubernetes Resources with Terraform.
# @see {@link https://architect.io/blog/2021-02-17/terraform-kubernetes-tutorial/#define-kubernetes-resources-with-terraform}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
provider "kubernetes" {
    config_path = "<kubeconfig_path>"
}

provider "helm" {
    kubernetes {
        config_path = "<kubeconfig_path>"
    }
}
