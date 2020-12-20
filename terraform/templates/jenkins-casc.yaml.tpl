jenkins:
  systemMessage: "Jenkins configured automatically by Jenkins Configuration as Code plugin\n\n"
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "$${jenkins-master-admin-user}"

  authorizationStrategy:
    globalMatrix:
      permissions:
      - "Overall/Administer:admin"
      - "Overall/Administer:admin"
      - "Overall/Read:authenticated"
  nodes:
    - permanent:
        name: "static-agent"
        remoteFS: "/home/jenkins"
        launcher:
          jnlp:
            workDirSettings:
              disabled: true
              failIfWorkDirIsMissing: false
              internalDir: "remoting"
              workDirPath: "/tmp"

  slaveAgentPort: 50000
  agentProtocols:
    - "jnlp2"
  clouds:

credentials:
  system:
    domainCredentials:
      - credentials:
          - basicSSHUserPrivateKey:
              scope: SYSTEM
              id: jenkins-agent-key-pair
              username: ec2-user
              passphrase: ''
              description: "Jenkins Agent SSH key pair"
              privateKeySource:
                directEntry:
                  privateKey: ${jenkins-slave-key}
unclassified:
    gitHubConfiguration:
      apiRateLimitChecker: ThrottleForNormalize
      endpoints:
      - apiUri: "https://api.github.com"
        name: "Github Endpoint"
    location:
      adminAddress: ish@ish-ar.io
      url: http://jenkins.ish-ar.io/
    gitSCM:
      createAccountBasedOnEmail: false
      globalConfigEmail: "jenkins@ish-ar.io"
      globalConfigName: "Jenkins"
    pollSCM:
      pollingThreadCount: 5
    simple-theme-plugin:
      elements:
      - cssUrl:
          url: "https://cdn.rawgit.com/afonsof/jenkins-material-theme/gh-pages/dist/material-green.css"
    slackNotifier:
      teamDomain: justeat
      tokenCredentialId: SLACK_TOKEN

jobs:
  - script: >
      freeStyleJob('seed_job') {
          displayName('seed_job')
          description('Jenkins Seed Job')
          concurrentBuild(false)
          quietPeriod(5)
          logRotator(-1, 30)
          label('main')
          properties{
              githubProjectUrl("https://github.com/ish-xyz/jenkins-aws-platform.git")
          }
          scm {
              git {
                  remote {
                      url("https://github.com/ish-xyz/jenkins-aws-platform.git")
                      //credentials('')
                      name('origin')
                  }
                  branch('master')
              }
          }
          steps {
              dsl {
                  external('jenkins-jobs/*.groovy')
              }
          }
      }
