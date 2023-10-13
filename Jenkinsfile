#!groovy
@Library('github.com/cloudogu/ces-build-lib@1.67.0')
import com.cloudogu.ces.cesbuildlib.*

git = new Git(this, "cesmarvin")
git.committerName = 'cesmarvin'
git.committerEmail = 'cesmarvin@cloudogu.com'
gitflow = new GitFlow(this, git)
github = new GitHub(this, git)
changelog = new Changelog(this)

repositoryName = "k8s-cert-manager"
productionReleaseBranch = "main"

node('docker') {
    timestamps {
        catchError {
            timeout(activity: false, time: 60, unit: 'MINUTES') {
                stage('Checkout') {
                    checkout scm
                    make 'clean'
                }

                helmImage = "alpine/helm:3.13.0"
                stage("Lint k8s Resources") {
                    new Docker(this)
                            .image(helmImage)
                            .inside("-v ${WORKSPACE}/:/data -t --entrypoint=")
                                    {
                                        sh "helm lint /data/k8s/helm"
                                    }
                }
            }
        }

        stageAutomaticRelease()
    }
}

void stageAutomaticRelease() {
    if (gitflow.isReleaseBranch()) {
        Makefile makefile = new Makefile(this)
        String releaseVersion = makefile.getVersion()
        String changelogVersion = git.getSimpleBranchName()
        String registryNamespace = "k8s"
        String registryUrl = "registry.cloudogu.com"

        stage('Finish Release') {
            gitflow.finishRelease(releaseVersion, productionReleaseBranch)
        }

        stage('Generate release resource') {
            make 'generate-release-resource'
        }

        stage('Push to Registry') {
            GString targetEtcdResourceYaml = "target/make/${registryNamespace}/${repositoryName}_${releaseVersion}.yaml"

            DoguRegistry registry = new DoguRegistry(this)
            registry.pushK8sYaml(targetEtcdResourceYaml, repositoryName, registryNamespace, "${releaseVersion}")
        }

        stage('Push Helm chart to Harbor') {
            new Docker(this)
                    .image("golang:1.20")
                    .mountJenkinsUser()
                    .inside("--volume ${WORKSPACE}:/${repositoryName} -w /${repositoryName}")
                            {
                                make 'crd-helm-package'
                                make 'helm-package-release'

                                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'harborhelmchartpush', usernameVariable: 'HARBOR_USERNAME', passwordVariable: 'HARBOR_PASSWORD']]) {
                                    sh ".bin/helm registry login ${registryUrl} --username '${HARBOR_USERNAME}' --password '${HARBOR_PASSWORD}'"
                                    sh ".bin/helm push target/make/k8s/helm/${repositoryName}-${releaseVersion}.tgz oci://${registryUrl}/${registryNamespace}"
                                    sh ".bin/helm push target/make/k8s/helm-crd/${repositoryName}-crd-${releaseVersion}.tgz oci://${registryUrl}/${registryNamespace}"
                                }
                            }
        }

        stage('Add Github-Release') {
            releaseId = github.createReleaseWithChangelog(changelogVersion, changelog, productionReleaseBranch)
        }
    }
}

void make(String makeArgs) {
    sh "make ${makeArgs}"
}
