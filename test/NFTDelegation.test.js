const { expect } = require("chai");
const { ethers } = require("hardhat");
const { constants } = require('@openzeppelin/test-helpers');

describe("NFTDelegation", function () {
  let NFTDelegation, nftDelegation
  let MockNFT, mockNFT
  let owner, addr1, addr2

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy the NFTDelegation contract
    NFTDelegation = await ethers.getContractFactory("NFTDelegation")
    nftDelegation = await NFTDelegation.deploy()
    await nftDelegation.waitForDeployment()

    // Deploy a mock NFT contract
    MockNFT = await ethers.getContractFactory("MockNFT")
    mockNFT = await MockNFT.deploy(nftDelegation.getAddress())
    await mockNFT.waitForDeployment()

    await nftDelegation.setNFTContract(mockNFT.getAddress())
  })

  describe("Success cases", async function () {
    beforeEach(async function () {
      await mockNFT.mint(owner.address, 1)
    })

    describe("Delegate", function () {
      it("Should delegate an NFT", async function () {
        await mockNFT.connect(owner).approve(nftDelegation.getAddress(), 1)
        await nftDelegation.connect(owner).delegateNFT(addr1.address, 1)

        const delegate = await nftDelegation.getDelegate(1)
        expect(delegate).to.equal(addr1.address)
      })

      it("Should allow the owner to transfer the NFT after they have transferred it", async function () {
        await mockNFT.connect(owner).approve(nftDelegation.getAddress(), 1)
        await nftDelegation.connect(owner).delegateNFT(addr1.address, 1)
        await nftDelegation.connect(owner).delegateNFT(addr2.address, 1)

        const delegate = await nftDelegation.getDelegate(1)
        expect(delegate).to.equal(addr2.address)
      })
    })

    describe("Events", function () {
      it("Should emit Delegated and Revoked events", async function () {
        await mockNFT.connect(owner).approve(nftDelegation.getAddress(), 1)

        await expect(nftDelegation.connect(owner).delegateNFT(addr1.address, 1))
          .to.emit(nftDelegation, "Delegated")
          .withArgs(owner.address, addr1.address, 1)

        await expect(nftDelegation.connect(owner).delegateNFT(addr2.address, 1))
          .to.emit(nftDelegation, "Revoked")
          .withArgs(owner.address, 1)
      })
    })

    describe("Transfer", function () {
      it("Should revoke delegation on transfer", async function () {
        await mockNFT.connect(owner).approve(nftDelegation.getAddress(), 1)
        await nftDelegation.connect(owner).delegateNFT(addr1.address, 1)

        await mockNFT.connect(owner).transferFrom(owner.address, addr2.address, 1)

        const delegate = await nftDelegation.getDelegate(1)

        expect(delegate).to.equal(constants.ZERO_ADDRESS)
      })
    })

  })

  describe("Error cases", function () {
    beforeEach(async function () {
      await mockNFT.mint(owner.address, 1)
    })

    describe("Delegate", function () {
      it("Should show 'You are not the owner of this NFT' message", async function () {
        await mockNFT.connect(owner).approve(nftDelegation.getAddress(), 1)
        await nftDelegation.connect(owner).delegateNFT(addr1.address, 1)

        await expect(nftDelegation.connect(addr2).delegateNFT(addr1.address, 1))
          .to.be.revertedWith("You are not the owner of this NFT");
      })

      it("Should show 'Invalid delegate address' message", async function () {
        await mockNFT.connect(owner).approve(nftDelegation.getAddress(), 1)
        await nftDelegation.connect(owner).delegateNFT(addr1.address, 1)

        await expect(nftDelegation.connect(owner).delegateNFT(constants.ZERO_ADDRESS, 1))
          .to.be.revertedWith("Invalid delegate address");
      })
    })

    describe("Transfer Delegate Rights", function () {
      it("Should show 'Invalid delegate address' message", async function () {
        await mockNFT.connect(owner).approve(nftDelegation.getAddress(), 1)
        await nftDelegation.connect(owner).delegateNFT(addr1.address, 1)

        await expect(nftDelegation.connect(owner).delegateNFT(constants.ZERO_ADDRESS, 1))
          .to.be.revertedWith("Invalid delegate address");
      })
    })
  })
});
