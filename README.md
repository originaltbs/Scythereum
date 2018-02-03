# Scythereum 

Scythereum is a proposal for an ERC-20 compatible *ethereum token* for the subreddit [/r/EthGarden](https://www.reddit.com/r/EthGarden).  The subreddit's goal is to support the creation of "projects"--essentially decentralized startups--built on the ethereum platform.  We wish to give away, free of charge, Scythereum tokens to any interested subreddit subscriber.

The Scythereum token provides tokenholders a means to vote on, and thereby support, projects that excite them. Tokenholders "invest" their tokens in projects of their choosing with the promise of future rewards.  In rough terms, the Scythereum platform is a like a play stock market for nascent ethereum projects, where early investors are rewarded more than later investors.  Once project's 1) pass the minimum investment threshold and 2) complete their first milestone, the invested tokens are released to the project and investors get back their original tokens, plus a reward that depends on how early they invested. Thus, each successfully funded project inflates the token supply, so it is best to actively participate and to only invest in projects that are likely to 1) get funded and 2) complete their first major milestone. Bystanders or poor investors will have a shrinking share of the total token supply. Investors are inventivized to help projects complete milestones.

In addition to the investing rewards described above, implemented entirely in Scythereum, there is a second type of reward implemented external to Scythereum. Approved projects (all projects must be approved) agree to dedicate a reward to all investors if their project is successfully funded.  For projects implementing their own token, this is expected to be a portion of their initial token supply. The amount of tokens they dedicate to early Scythereum backers is expected to be proportional to the value provided by the subreddit.  More specific guidelines and recommendations will develop over time.  In the early stages of Scythereum, the Scythereum token is expected to have no intrinsic value, and so early backers should be rewarded based on their material contributions, such as evangelism or direct code contributions.  If the Scythereum tokens attains a monetary value, rewards should also be proportional to the amount of tokens invested.

Scythereum tokens are given away to anyone who wants them, and thus are excluded from securities regulations under the first rule of the Howey test.  It is possible that some participants may try to acquire free tokens under multiple fictitious identities, or sock puppets.  Sock puppets are prevented by using a reddit "AMA" style verification procedure using photos with specific hand-written messages.

More details and discussion can be found in the [/r/EthGarden](https://www.reddit.com/r/EthGarden) subreddit.

## Getting Started

Our Scythereum smart contract is written in solidity, and resides in the contracts/ folder. Interested parties should be familiar with or review the ERC-20 token standard.  It is a relatively simple standard that provides functions for transferring tokens securely between parties (also for authorizing a third party to transfer tokens on your behalf).  The solidity documentation is a good place to start.  The ethereum.org homepage also provides an introduction to ERC-20 tokens.  

The functions of the smart contract are written but still needs significatn review, unit tests, and a security audit.

The smart contract was developed with truffle.

### Prerequisites

To interact with the smart contract on a local "developers blockchain", or to run the tests, you will need to install truffle (which means you will also need the "node package manager" npm).  Good documentation is provided at https://truffleframework.com.

## Running the tests

An example truffle config file is provided: truffleDemo.js. You will need to rename it to truffle.js.  To run the tests on a local, temporary blockchain on your computer you should not have to change the file.  However, if you want to test it on a *real* testnet (like ropsten) you will have to change the file as described therein.

Tests are kept in the tests/ folder and can be run with: 

```
truffle test
```

## Deployment

We are working toward an eventual deployment on the ethereum main net.

## Built With

* [Truffle](https://truffleframework.com/) - The solidity development environment used

## Contributing

We welcome all contributions.

## License

This project is still in development and tentatively licensed under the MIT License, though subject to change.

## Acknowledgments

* The truffle folks
* Helpful people in the solidity gitter channel

