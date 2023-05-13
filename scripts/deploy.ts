import { ethers } from "hardhat";

async function main() {
  const SelfyBadge = await ethers.getContractFactory("SelfyBadge");
  const selfyBadge = await SelfyBadge.deploy();
  await selfyBadge.deployed();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
