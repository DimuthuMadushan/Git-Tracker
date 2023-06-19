import ballerina/graphql;
import ballerina/http;
import ballerina/io;
import xlibb/pubsub;

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
    private final pubsub:PubSub pubsub = new;

    function init() returns error? {
        self.githubRestClient = check new ("https://api.github.com", {auth: {token: authToken}});
        io:println(string `💃 Server ready at http://localhost:9090/graphql`);
        io:println(string `Access the GraphiQL UI at http://localhost:9090/graphiql`);
    }

    # Get GitHub User Details
    # 
    # + return - GitHub repository list
    resource function get user() returns GitHubUser|error {
        GitHubUser user = check self.githubRestClient->/user;
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
    remote function createIssue(CreateIssueInput createIssueInput, string repositoryName) returns Issue|error {
        Issue issue = check self.githubRestClient->post(string `/repos/${owner}/${repositoryName}/issues`, createIssueInput.toJson());
        string topic = string `reviews-${repositoryName}`;
        check self.pubsub.publish(topic, issue.cloneReadOnly(), timeout = 10);
        return issue;
    }

    # Subscribe to issues created
    #
    # + repositoryName - Repository name
    # + return - Stream of issues
    resource function subscribe issues(string repositoryName) returns stream<Issue, error?>|error {
        string topic = string `reviews-${repositoryName}`;
        return self.pubsub.subscribe(topic, timeout = -1);
    }
}
