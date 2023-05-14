import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Selfy Test", function () {
  async function deployFixture() {
    const [owner, addr1] = await ethers.getSigners();
    const GHO_TOKEN_ADDRESS = "0xcbE9771eD31e761b744D3cB9eF78A1f32DD99211";
    const GHO_PRICE = ethers.utils.parseEther("50");
    const ETH_PRICE = ethers.utils.parseEther("0.1");
    const baseURI = 'https://noun-api.com/beta/pfp';

    // Deploy Contract SelfyProfile with Parameters
    const SelfySnapshotGHO = await ethers.getContractFactory("SelfySnapshotGHO");
    const selfySnapshotGHO = await SelfySnapshotGHO.deploy(GHO_TOKEN_ADDRESS);

    // Deploy Contract SelfyProfile with Parameters
    const SelfySnapshotETH = await ethers.getContractFactory("SelfySnapshotETH");
    const selfySnapshotETH = await SelfySnapshotETH.deploy();

    return { selfySnapshotETH, selfySnapshotGHO,  owner, addr1, GHO_TOKEN_ADDRESS, GHO_PRICE, ETH_PRICE, baseURI};
  };

  describe("SelfySnpashot GHO and ETH", function () {
    it("Should return the right data", async function () {
      const {selfySnapshotETH, selfySnapshotGHO,GHO_TOKEN_ADDRESS, owner } = await loadFixture(deployFixture);
      // GHO Deployement
      expect(await selfySnapshotGHO.ghoToken()).to.equal(GHO_TOKEN_ADDRESS);
      expect(await selfySnapshotGHO.hasRole(selfySnapshotGHO.DEFAULT_ADMIN_ROLE(), owner.address)).to.be.true;
      // ETH Deployement
      expect(await selfySnapshotETH.hasRole(selfySnapshotETH.DEFAULT_ADMIN_ROLE(), owner.address)).to.be.true;
      expect(await selfySnapshotETH.hasRole(selfySnapshotETH.MINTER_ROLE(), owner.address)).to.be.true;
    });

    it("Should mint a SelfyProfile w/ ETH", async function () {
        const {selfySnapshotETH, baseURI, addr1, ETH_PRICE } = await loadFixture(deployFixture);

        // Mint the SnapShot NFToken
        await selfySnapshotETH.connect(addr1).mint(baseURI, {value: ETH_PRICE});
        expect(await selfySnapshotETH.balanceOf(addr1.address)).to.equal(1);
        expect(await selfySnapshotETH.tokenURI(1)).to.equal(baseURI);
    });

    it("Should mint a SelfyProfile w/ GHO", async function () {
        const {owner, selfySnapshotETH, baseURI, addr1, GHO_PRICE, gho } = await loadFixture(deployFixture);

    });
  })
});
