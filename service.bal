import ballerina/graphql;
import ballerina/http;
import ballerina/io;
import ballerinax/github;

configurable string authToken = ?;
configurable string owner = ?;

@graphql:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    },
    graphiql: {
        enabled: true
    }
}
service /graphql on new graphql:Listener(9090) {

    final http:Client githubRestClient;

    function init() returns error? {
        self.githubRestClient = check new ("https://api.github.com", {auth: {token: authToken}});
        io:println(string `💃 Server ready at http://localhost:9090/graphql`);
        io:println(string `Access the GraphiQL UI at http://localhost:9090/graphiql`);
    }

    # Get GitHub User Details
    # 
    # + return - GitHub repository list
    resource function get user() returns User|error {
        User user = check self.githubRestClient->get(string `/user`);
        return user;
    }

    # Get GitHub Repository List
    # 
    # + return - GitHub repository list
    resource function get repositories() returns Repository[]|error {
        Repository[] repositories = check self.githubRestClient->get(string `/users/${owner}/repos`);
        return repositories;
    }

    # Get Repository
    #
    # + repositoryName - Repository name
    # + return - GitHub repository
    resource function get repository(string repositoryName) returns Repository|error {
        Repository repository = check self.githubRestClient->get(string `/repos/${owner}/${repositoryName}`);
        return repository;
    }

    # Create Repository
    #
    # + createRepoInput - Represent create repository input payload
    # + return - GitHub repositor or error.
    remote function createRepository(CreateRepositoryInput createRepoInput) returns Repository|error {
        Repository repository = check self.githubRestClient->/user/repos.post(createRepoInput.toJson());
        return repository;
    }

    # Create Issue
    #
    # + createIssueInput - Create issue input payload  
    # + repositoryName - Repository name
    # + return - GitHub issue
    remote function createIssue(github:CreateIssueInput createIssueInput, string repositoryName) returns Issue|error {
        Issue issue = check self.githubRestClient->post(string `/repos/${owner}/${repositoryName}/issues`, createIssueInput.toJson());
        check produceIssue(issue, repositoryName);
        return issue;
    }

    # Subscribe to issues created
    #
    # + repositoryName - Repository name
    # + return - Stream of issues
    resource function subscribe issues(string repositoryName) returns stream<Issue>|error {
        stream<Issue> issueStream;
        lock {
            IssueStream issueStreamGenerator = check new (repositoryName);
            issueStream = new (issueStreamGenerator);
        }
        return issueStream;
    }
}
