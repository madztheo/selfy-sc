import { ethers, network } from "hardhat";
const Web3 = require("web3");
require('dotenv').config();

async function main() {
  const web3 = new Web3(process.env.RPC_URL);

  const transactionCount = await web3.eth.getTransactionCount(process.env.OWNER_ADDRESS);

  // gets the address of SelfyProfile before it is deployed
  const futureAddress = ethers.utils.getContractAddress({
    from: process.env.OWNER_ADDRESS,
    nonce: transactionCount + 1
  });

  // Deploy Contract SelfyProfile with Parameters
  const SelfyProfile = await ethers.getContractFactory("SelfyProfile");
  const selfyProfile = await SelfyProfile.deploy(futureAddress);

  const SelfyBadge = await ethers.getContractFactory("SelfyBadge");
  const selfyBadge = await SelfyBadge.deploy(selfyProfile.address);

  console.log(
      `SelfyProfile deployed to ${selfyProfile.address}`,
      `SelfyBadge deployed to ${selfyBadge.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
