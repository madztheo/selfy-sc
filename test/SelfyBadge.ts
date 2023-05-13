import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Selfy Test", function () {
  async function deployFixture() {
    const [owner, addr1] = await ethers.getSigners();
    const GHO_TOKEN_ADDRESS = "0xcbE9771eD31e761b744D3cB9eF78A1f32DD99211";
    const baseURI = 'https://noun-api.com/beta/pfp?head=';
    const defaultURIValue = {
        "background": 0,
        "body": 13,
        "accessory" : 100,
        "head": 0,
        "glasses" : 7
    }
    let newtTransaction = await owner.getTransactionCount();

    // gets the address of SelfyProfile before it is deployed
    const futureSelfyBadgeAddress = ethers.utils.getContractAddress({
      from: owner.address,
      nonce: newtTransaction + 1
    });

    // Deploy Contract SelfyProfile with Parameters
    const SelfyProfile = await ethers.getContractFactory("SelfyProfile");
    const selfyProfile = await SelfyProfile.deploy(
        "SelfyProfile", // Name
        "SP", // Symbol
        futureSelfyBadgeAddress, // SelfyBadge Address
        GHO_TOKEN_ADDRESS // Gho Token Address
    );

    // Deploy Contract SelfyBadge with Parameters
    const SelfyBadge = await ethers.getContractFactory("SelfyBadge");
    const selfyBadge = await SelfyBadge.deploy(selfyProfile.address);
    console.log("selfyBadge", selfyBadge.address);

    return { selfyProfile, selfyBadge,  owner, addr1, GHO_TOKEN_ADDRESS, baseURI, defaultURIValue };
  };

  describe("SelfyBadge", function () {
    it("Should return the right data", async function () {
      const {selfyProfile, GHO_TOKEN_ADDRESS, selfyBadge, owner} = await loadFixture(deployFixture);

     /* expect(await selfyProfile.name()).to.equal("SelfyProfile");
      expect(await selfyProfile.symbol()).to.equal("SP");
      expect(await selfyProfile.hasRole(selfyProfile.MINTER_ROLE(), selfyBadge.address)).to.be.true;
      expect(await selfyProfile.hasRole(selfyProfile.DEFAULT_ADMIN_ROLE(), owner.address)).to.be.true;
      expect(await selfyProfile.ghoToken()).to.equal(ethers.utils.getAddress(GHO_TOKEN_ADDRESS));

      */
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
