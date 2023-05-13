import { ethers, network } from "hardhat";
require("dotenv").config();

async function main() {
  const SelfySnapshot = await ethers.getContractFactory("SelfySnapshot");
  const selfySnapshot = await SelfySnapshot.deploy();
  await selfySnapshot.deployed();
  console.log(
    `SelfySnapshot deployed to ${selfySnapshot.address}`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });