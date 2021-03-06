#!/bin/bash

run() {
	allargs="${ARGS[@]}"

	for i in "${ARGS[@]}"; do
            case "$i" in
                 --stage=*) STAGE="${i#*=}" ;;
                 --workflow.version=*) WORKFLOW_ENGINE_VERSION="${i#*=}" ;;
                 --manifest.type=*) MANIFEST_TYPE="${i#*=}" ;;
		 --is.sast.enabled=*) IS_SAST_ENABLED="${i#*=}" ;;
                 --is.sca.enabled=*) IS_SCA_ENABLED="${i#*=}" ;;
		 --is.dast.enabled=*) IS_DAST_ENABLED="${i#*=}" ;;
                 *) ;;
       	    esac
   	done
   	
	preValidation ""

	if [[ "$STAGE" == "IO" ]]; then
	    ioPrescription ""
	elif [[ "$STAGE" == "WORKFLOW" ]]; then
	    runWorkflowEngineClient ""
	fi
}

function preValidation() {
    STAGE=${STAGE:?'STAGE variable missing.'};
    IO_SERVER_URL=${IO_SERVER_URL:?'IO_SERVER_URL variable missing.'};
    IO_ACCESS_TOKEN=${IO_ACCESS_TOKEN:?'IO_ACCESS_TOKEN variable missing.'};
    WORKFLOW_ENGINE_SERVER_URL=${WORKFLOW_ENGINE_SERVER_URL:?'WORKFLOW_ENGINE_SERVER_URL variable missing.'};
    WORKFLOW_ENGINE_VERSION=${WORKFLOW_ENGINE_VERSION:="2021.04"};
    JIRA_API_URL=${JIRA_API_URL:="<<JIRA_API_URL>>"};
    JIRA_PROJECT_NAME=${JIRA_PROJECT_NAME:="<<JIRA_PROJECT_NAME>>"};
    JIRA_ISSUES_QUERY=${JIRA_ISSUES_QUERY:="<<JIRA_ISSUES_QUERY>>"};
    JIRA_USERNAME=${JIRA_USERNAME:="<<JIRA_USERNAME>>"};
    JIRA_AUTH_TOKEN=${JIRA_AUTH_TOKEN:="<<JIRA_AUTH_TOKEN>>"};
    JIRA_ASSIGNEE=${JIRA_ASSIGNEE:="<<JIRA_ASSIGNEE>>"};
    MANIFEST_TYPE=${MANIFEST_TYPE:="yml"};
    IS_SAST_ENABLED=${IS_SAST_ENABLED:="true"};
    IS_SCA_ENABLED=${IS_SCA_ENABLED:="true"};
    IS_DAST_ENABLED=${IS_DAST_ENABLED:="true"};
    
    additionalWorkflowArgs=${additionalWorkflowArgs:=""};
}

function ioPrescription() {
    wget https://sigdevsecops.blob.core.windows.net/intelligence-orchestration/${WORKFLOW_ENGINE_VERSION}/prescription.sh

    chmod +x prescription.sh
    sed -i -e 's/\r$//' prescription.sh

    ./prescription.sh \
        --io.url=${IO_SERVER_URL} \
        --io.token=${IO_ACCESS_TOKEN} \
        --io.manifest.url=${IO_MANIFEST_URL} \
        --stage=${STAGE} \
        --persona=${PERSONA} \
	--asset.id=${IO_ASSET_ID} \
        --release.type=${RELEASE_TYPE} \
	--manifest.type=${MANIFEST_TYPE} \
        --sensitive.package.pattern=${SENSITIVE_PACKAGE_PATTERN} \
        --workflow.url=${WORKFLOW_ENGINE_SERVER_URL} \
        --workflow.version=${WORKFLOW_ENGINE_VERSION} \
        --scm.type=${SCM_TYPE} \
	--scm.owner=${GITHUB_WORKSPACE} \
	--scm.repo.name=${GITHUB_REPO_NAME} \
        --scm.branch.name=${GITHUB_BRANCH_NAME} \
	--polaris.project.name=${POLARIS_PROJECT_NAME} \
        --polaris.url=${POLARIS_SERVER_URL} \
        --polaris.token=${POLARIS_ACCESS_TOKEN} \
        --blackduck.project.name=${BLACKDUCK_PROJECT_NAME} \
        --blackduck.url=${BLACKDUCK_SERVER_URL} \
        --blackduck.api.token=${BLACKDUCK_ACCESS_TOKEN} \
        --bitbucket.commit.id=${BITBUCKET_COMMIT} \
        --bitbucket.username=${BITBUCKET_USERNAME} \
        --bitbucket.password=${BITBUCKET_ACCESS_TOKEN} \
        --jira.api.url=${JIRA_API_URL} \
        --jira.project.name=${JIRA_PROJECT_NAME} \
        --jira.issues.query=${JIRA_ISSUES_QUERY} \
        --jira.username=${JIRA_USERNAME} \
        --jira.auth.token=${JIRA_AUTH_TOKEN} \
        --jira.assignee=${JIRA_ASSIGNEE} \
        --IS_SAST_ENABLED=${IS_SAST_ENABLED} \
        --IS_SCA_ENABLED=${IS_SCA_ENABLED} \
        --IS_DAST_ENABLED=${IS_DAST_ENABLED} \
        --slack.channel.id=${SLACK_CHANNEL_ID} \
        --slack.token=${SLACK_TOKEN} \
        ${additionalWorkflowArgs}

    isSastEnabled=$(jq -r '.security.activities.sast.enabled' result.json)
    isScaEnabled=$(jq -r '.security.activities.sca.enabled' result.json)
    echo "IS_SAST_ENABLED=${isSastEnabled}" > io_actions.meta.env
    echo "IS_SCA_ENABLED=${isScaEnabled}" >> io_actions.meta.env
}

function runWorkflowEngineClient () {
    $(`wget https://sigdevsecops.blob.core.windows.net/intelligence-orchestration/${WORKFLOW_ENGINE_VERSION}/prescription.sh`)

    chmod +x prescription.sh
    sed -i -e 's/\r$//' prescription.sh

    ./prescription.sh \
        --io.url=${IO_SERVER_URL} \
        --io.token=${IO_ACCESS_TOKEN} \
        --io.manifest.url=${IO_MANIFEST_URL} \
        --stage=${STAGE} \
        --persona=${PERSONA} \
        --asset.id=${IO_ASSET_ID} \
        --release.type=${RELEASE_TYPE} \
	--manifest.type=${MANIFEST_TYPE} \
        --sensitive.package.pattern=${SENSITIVE_PACKAGE_PATTERN} \
        --workflow.url=${WORKFLOW_ENGINE_SERVER_URL} \
        --workflow.version=${WORKFLOW_ENGINE_VERSION} \
        --scm.type=${SCM_TYPE} \
	--scm.owner=${GITHUB_WORKSPACE} \
	--scm.repo.name=${GITHUB_REPO_NAME} \
        --scm.branch.name=${GITHUB_BRANCH_NAME} \
	--polaris.project.name=${POLARIS_PROJECT_NAME} \
        --polaris.url=${POLARIS_SERVER_URL} \
        --polaris.token=${POLARIS_ACCESS_TOKEN} \
        --blackduck.project.name=${BLACKDUCK_PROJECT_NAME} \
        --blackduck.url=${BLACKDUCK_SERVER_URL} \
        --blackduck.api.token=${BLACKDUCK_ACCESS_TOKEN} \
        --bitbucket.commit.id=${BITBUCKET_COMMIT} \
        --bitbucket.username=${BITBUCKET_USERNAME} \
        --bitbucket.password=${BITBUCKET_ACCESS_TOKEN} \
        --jira.api.url=${JIRA_API_URL} \
        --jira.project.name=${JIRA_PROJECT_NAME} \
        --jira.issues.query=${JIRA_ISSUES_QUERY} \
        --jira.username=${JIRA_USERNAME} \
        --jira.auth.token=${JIRA_AUTH_TOKEN} \
        --jira.assignee=${JIRA_ASSIGNEE} \
        --IS_SAST_ENABLED=${IS_SAST_ENABLED} \
        --IS_SCA_ENABLED=${IS_SCA_ENABLED} \
        --IS_DAST_ENABLED=${IS_DAST_ENABLED} \
        --slack.channel.id=${SLACK_CHANNEL_ID} \
        --slack.token=${SLACK_TOKEN} \
        ${additionalWorkflowArgs}
    
    echo "APP_MANIFEST_FILE generated successfullly....Calling WorkFlow Engine"
    
    
    if [[ "$MANIFEST_TYPE" == "json" ]]; then
        java -jar WorkflowClient.jar --workflowengine.url=${WORKFLOW_ENGINE_SERVER_URL} --io.manifest.path=synopsys-io.json
    elif [[ "$MANIFEST_TYPE" == "yml" ]]; then
        java -jar WorkflowClient.jar --workflowengine.url=${WORKFLOW_ENGINE_SERVER_URL} --io.manifest.path=synopsys-io.yml
    fi
}

ARGS=("$@")

run
