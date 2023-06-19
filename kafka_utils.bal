import ballerina/log;
import ballerinax/kafka;
import ballerina/uuid;

configurable decimal POLL_INTERVAL = 100.0;
final kafka:Producer producer = check new (kafka:DEFAULT_URL);

isolated function produceIssue(Issue newIssue, string repoName) returns error? {
    return producer->send({topic: repoName, value: newIssue});
}

isolated class IssueStream {
    private final string repoName;
    private final kafka:Consumer consumer;

    isolated function init(string repoName) returns error? {
        self.repoName = repoName;
        kafka:ConsumerConfiguration consumerConfiguration = {
            groupId: uuid:createType1AsString(),
            topics: repoName,
            maxPollRecords: 1
        };
        self.consumer = check new (kafka:DEFAULT_URL, consumerConfiguration);
    }

    public isolated function next() returns record {|Issue value;|}? {
        Issue[]|error issueRecords = self.consumer->pollPayload(POLL_INTERVAL);
        if issueRecords is error {
            log:printError("Failed to retrieve data from the Kafka server", issueRecords, id = self.repoName);
            return;
        }
        if issueRecords.length() < 1 {
            log:printWarn(string `No issues available in "${self.repoName}"`, id = self.repoName);
            return;
        }
        return {value: issueRecords[0]};
    }
}
