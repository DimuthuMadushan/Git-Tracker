# Git Tracker

Git Tracker is a GraphQL service written in Ballerina that connects with the GitHub REST API, GitHub GraphQL API and the Ballerina GitHub connector. It enables tracking and monitoring of Git repositories.

## Features

- Seamless integration with GitHub REST API and GitHub GraphQL API.
- Supports query, mutation, and subscription operations.
- Real-time tracking of repository activities.
- Provides a GraphQL interface for querying Git data.

## Installation

### Prerequisites

- Ballerina - Version Swan Lake 2201.6.0

### Steps

1. Clone the Git Tracker repository:

   ```bash
   git clone https://github.com/DimuthuMadushan/git-tracker.git

2. Navigate to the cloned repository:
    ```bash
    cd git-tracker

3. Configure the application by updating the config.toml file with your GitHub API credentials:
    ```bash
    authToken = "<YOUR_GITHUB_AUTH_TOKEN>"
    owner = "<GITHUB_USERNAME>"

3. Start the Git Tracker service:
    ```bash
    bal run

4. Access the Git Tracker service at http://localhost:9090/graphql.

### Usage

Make GraphQL requests to interact with the Git Tracker service. Here's an example:

# Get repository details
    query MyQuery {
        repositories {
            created_at
            description
            forks_count
            language
            name
            visibility
            default_branch
            license {
                name
            }
            owner {
                login
                id
                url
            }
        }
    }

Modify the GraphQL query according to your specific requirements.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please submit a pull request. For major changes, please open an issue first to discuss your proposed changes.
