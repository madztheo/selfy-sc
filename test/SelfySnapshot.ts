import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Selfy Test", function () {
  async function deployFixture() {
    const [owner, addr1] = await ethers.getSigners();
    const GHO_TOKEN_ADDRESS = "0xcbE9771eD31e761b744D3cB9eF78A1f32DD99211";

    // Deploy Contract SelfyProfile with Parameters
    const SelfySnapshotGHO = await ethers.getContractFactory("SelfySnapshotGHO");
    const selfySnapshotGHO = await SelfySnapshotGHO.deploy(GHO_TOKEN_ADDRESS);

    // Deploy Contract SelfyProfile with Parameters
    const SelfySnapshotETH = await ethers.getContractFactory("SelfySnapshotETH");
    const selfySnapshotETH = await SelfySnapshotETH.deploy();

    return { selfySnapshotETH, selfySnapshotGHO,  owner, addr1, GHO_TOKEN_ADDRESS};
  };

  describe("SelfySnpashot GHO and ETH", function () {
    it("Should return the right data", async function () {
      const {selfySnapshotETH, selfySnapshotGHO,GHO_TOKEN_ADDRESS } = await loadFixture(deployFixture);
      expect(await selfySnapshotGHO.ghoToken()).to.equal(GHO_TOKEN_ADDRESS);
    });
/*
    it("Should mint a SelfyProfile", async function () {
        const {selfyProfile, baseURI, defaultURIValue, addr1, selfyBadge, owner} = await loadFixture(deployFixture);
        await selfyProfile.connect(addr1).createSelfyProfile();
        expect(await selfyProfile.balanceOf(addr1.address)).to.equal(1);
        expect(await selfyProfile.tokenURI(0)).to.equal(
            baseURI
            +  defaultURIValue.head
            +"&background=" + defaultURIValue.background
            +"&body=" + defaultURIValue.body
            +"&accessory=" + defaultURIValue.accessory
            +"&glasses=" + defaultURIValue.glasses
        );
    });*/
  })
});
