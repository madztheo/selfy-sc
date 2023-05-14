# Selfy - Smart Contract

This repos contain all the smart contracts for the Selfy project.
We have :

    - SelfyProfile.sol : Selfy Profile, is the ERC721 contract that contain the SBT evolutive profile NFT of the user
    - SelfyBadge.sol : Selfy Badge, is the ERC721 contract that contain the SBT badge, proof of action, NFT of the user
    - SelfySnapshotETH.sol ou SelfySnapshotGHO.sol : Selfy Snapshot is the contract that let you mint forever your profile picture and sell it or show them an achievement.

## How to deploy ?


To deploy all the contract you need first to create a .env file by copy-paste the .env.example file and fill it with your own information.

And then you can deploy the contract with the following command :
```shell

```shell
# Deoploy of SelfyProfile.sol + SelfyBadge.sol
npx hardhat scripts/deploy.js --network gnosis

# Deploy SelfySnapshotETH.sol or SelfySnapshotGHO.sol contract on any new chain (Payement in ETH or GHO)
npx hardhat scripts/deploy_SelfySnapshot.js --network gnosis
```

## How to test

To test the contract you need first to create a .env file by copy-paste the .env.example file and fill it with your own information.

And then you can test the contract with the following command :
```shell
npx hardhat test
```