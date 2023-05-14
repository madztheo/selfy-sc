import { ethers, network } from "hardhat";
require("dotenv").config();

function Ask(query: string) {
    const readline = require("readline").createInterface({
        input: process.stdin,
        output: process.stdout
    })

    return  new Promise(resolve => readline.question(query, (ans: string) => {
        readline.close();
        resolve(ans);
    }))
}

async function main() {
    const GHO_TOKEN_ADDRESS = process.env.GHO_TOKEN_ADDRESS;
    var answer = await Ask('Do you want to deploy using the GHO Payement Method ? [y/n] ')
    if (answer === "y") {
        const SelfySnapshot = await ethers.getContractFactory("SelfySnapshotGHO");
        const selfySnapshot = await SelfySnapshot.deploy(GHO_TOKEN_ADDRESS);
        await selfySnapshot.deployed();
        console.log(
            `SelfySnapshot deployed to ${selfySnapshot.address}`
        );
    } else {
        const SelfySnapshot = await ethers.getContractFactory("SelfySnapshotETH");
        const selfySnapshot = await SelfySnapshot.deploy();
        await selfySnapshot.deployed();
        console.log(
            `SelfySnapshot deployed to ${selfySnapshot.address}`
        );
    }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });