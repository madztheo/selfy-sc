import { ethers, network } from "hardhat";
const Web3 = require("web3");
require('dotenv').config();

async function main() {
  const web3 = new Web3(process.env.RPC_URL);
  const OWNER_ADDRESS = process.env.OWNER_ADDRESS as string;

  const transactionCount = await web3.eth.getTransactionCount(OWNER_ADDRESS);

  // gets the address of SelfyProfile before it is deployed
  const futureAddress = ethers.utils.getContractAddress({
    from: OWNER_ADDRESS,
    nonce: transactionCount + 1
  });

  // Deploy Contract SelfyProfile with Parameters
  const SelfyProfile = await ethers.getContractFactory("SelfyProfile");
  const selfyProfile = await SelfyProfile.deploy(
      "SelfyProfile", // Name
      "SP", // Symbol
      futureAddress, // SelfyBadge Address
      ethers.utils.getAddress("0x621AC9c06cf1aa650cFA198DA175dC5a5d2Ba516") // Gho Token Address
  );

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
