import ballerina/file;
import ballerina/http;
import ballerina/io;

isolated function getBranches(http:Client githubGraphqlClient, string query, json variables) returns Branch[]|error {
    json|http:ClientError graphqlData = check getJsonPayloadFromService(githubGraphqlClient, query, variables);
    if graphqlData is http:ClientError {
        return error(graphqlData.message());
    }
    if graphqlData is map<json> && graphqlData.hasKey("data"){
        json data = graphqlData.get("data");
        if data is map<json> && data.hasKey("repository") {
            json repository = data.get("repository");
            if repository is map<json>  && repository.hasKey("refs") {
                json branches = repository.get("refs"); 
                if branches is map<json> && branches.hasKey("nodes") {
                    return branches.get("nodes").cloneWithType();
                }
                return error("Error in fetching branches");
            }
            return error("Repository not found");
        }
    }
    return error("GraphQL Server Error");
}

isolated function getGraphqlQueryFromFile(string fileName) returns string|error {
    string gqlFileName = string `${fileName}.graphql`;
    string path = check file:joinPath("resources", gqlFileName);
    return io:fileReadString(path);
}

isolated function getJsonPayloadFromService(http:Client githubGraphqlClient, string document, json? variables = {})
returns json|http:ClientError {
    http:Request request = new;
    request.setPayload({ query: document, variables: variables});
    http:Response response = check githubGraphqlClient->post("", request);
    return response.getJsonPayload();
}
