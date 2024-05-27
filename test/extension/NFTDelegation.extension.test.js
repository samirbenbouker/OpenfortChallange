const { expect } = require("chai");
const { ethers } = require("hardhat");
const { constants } = require('@openzeppelin/test-helpers');

describe("NFTDelegationExtension", function () {
    let NFTDelegationExtension;
    let nftDelegationExtension;
    let erc20Token;
    let erc721Token;
    let owner, addr1, addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        // Deploy ERC20Mock for testing
        const ERC20Mock = await ethers.getContractFactory("ERC20Mock");
        erc20Token = await ERC20Mock.deploy("Test Token", "TST", ethers.parseEther("1000"));
        await erc20Token.waitForDeployment();

        // Deploy ERC721Mock for testing
        const ERC721Mock = await ethers.getContractFactory("ERC721Mock");
        erc721Token = await ERC721Mock.deploy("TestNFT", "TNFT");
        await erc721Token.waitForDeployment();

        // Deploy the NFTDelegationExtension contract
        const NFTDelegationExtension = await ethers.getContractFactory("NFTDelegationExtension");
        nftDelegationExtension = await NFTDelegationExtension.deploy("https://example.com/metadata/id.json", erc20Token.getAddress());
        await nftDelegationExtension.waitForDeployment();
    });

    describe("ERC721 Functionality", function () {
        it("Should deposit an ERC721 token", async function () {
            await erc721Token.mint(owner.address, 1); // Mint ERC721 token
            await erc721Token.setApprovalForAll(nftDelegationExtension.getAddress(), true);

            // Deposit ERC721 token into NFTDelegationExtension
            await expect(nftDelegationExtension.depositERC721(erc721Token.getAddress(), 1, 1))
                .to.emit(nftDelegationExtension, "ERC721Deposited")
                .withArgs(owner.address, erc721Token.getAddress(), 1, 1);

            // Check ERC721 token balance of the owner in NFTDelegationExtension
            expect(await nftDelegationExtension.balanceOf(owner.address, 1)).to.equal(1);
        });

        it("Should withdraw an ERC721 token", async function () {
            // Mint and deposit ERC721 token
            await erc721Token.mint(owner.address, 1);
            await erc721Token.setApprovalForAll(nftDelegationExtension.getAddress(), true);
            await nftDelegationExtension.depositERC721(erc721Token.getAddress(), 1, 1);

            // Withdraw ERC721 token from NFTDelegationExtension
            await nftDelegationExtension.withDrawERC721(1, 1);

            // Check if ERC721 token ownership is reverted to the owner
            expect(await erc721Token.ownerOf(1)).to.equal(owner.address);
        });

        it("Should delegate an ERC721 token", async function () {
            // Mint and deposit ERC721 token
            await erc721Token.mint(owner.address, 1);
            await erc721Token.setApprovalForAll(nftDelegationExtension.getAddress(), true);
            await nftDelegationExtension.depositERC721(erc721Token.getAddress(), 1, 1);

            // Delegate ERC721 token to addr1
            await nftDelegationExtension.delegateERC271(addr1.address, 1, 1);

            // Check if ERC721 token is delegated to addr1
            expect(await nftDelegationExtension.getERC721Delegate(1, 1)).to.equal(addr1.address);
        });

        it("Should revoke ERC721 delegation", async function () {
            // Mint, deposit, and delegate ERC721 token
            await erc721Token.mint(owner.address, 1);
            await erc721Token.setApprovalForAll(nftDelegationExtension.getAddress(), true);
            await nftDelegationExtension.depositERC721(erc721Token.getAddress(), 1, 1);
            await nftDelegationExtension.delegateERC271(addr1.address, 1, 1);

            // Revoke ERC721 delegation
            await nftDelegationExtension.revokeERC721Delegation(1, 1);

            // Check if ERC721 delegation is revoked
            expect(await nftDelegationExtension.getERC721Delegate(1, 1)).to.equal(constants.ZERO_ADDRESS);
        });

        it("Should have the same owner after ERC721 deposit and delegation", async function () {
            // Get owner before ERC721 deposit and delegation
            const ownerBefore = await nftDelegationExtension.owner();

            // Deposit ERC721 token
            await erc721Token.mint(owner.address, 1);
            await erc721Token.setApprovalForAll(nftDelegationExtension.getAddress(), true);
            await nftDelegationExtension.depositERC721(erc721Token.getAddress(), 1, 1);

            // Delegate ERC721 token
            await nftDelegationExtension.delegateERC271(addr1.address, 1, 1);

            // Get owner after ERC721 deposit and delegation
            const ownerAfter = await nftDelegationExtension.owner();

            // Check if the owner remains unchanged
            expect(ownerAfter).to.equal(ownerBefore, "Owner should remain unchanged");
        });
    });

    describe("ERC20 Functionality", function () {
        it("Should deposit ERC20 tokens", async function () {
            await erc20Token.approve(nftDelegationExtension.getAddress(), ethers.parseEther("100")); // Approve NFTDelegationExtension contract to spend ERC20 tokens
            await nftDelegationExtension.depositERC20(ethers.parseEther("100")); // Deposit ERC20 tokens into NFTDelegationExtension

            // Check ERC20 token balance of the owner in NFTDelegationExtension
            expect(await nftDelegationExtension.getERCBalance(owner.address)).to.equal(ethers.parseEther("100"));
        });

        it("Should delegate ERC20 tokens", async function () {
            await erc20Token.approve(nftDelegationExtension.getAddress(), ethers.parseEther("100")); // Approve NFTDelegationExtension contract to spend ERC20 tokens
            await nftDelegationExtension.depositERC20(ethers.parseEther("100")); // Deposit ERC20 tokens into NFTDelegationExtension

            // Delegate ERC20 tokens to addr1
            await nftDelegationExtension.delegateERC20(addr1.address, ethers.parseEther("50"));

            // Check if ERC20 tokens are delegated to addr1
            expect(await nftDelegationExtension.getERCBalance(addr1.address)).to.equal(ethers.parseEther("50"));
            expect(await nftDelegationExtension.getERC20Delegate(owner.address)).to.equal(addr1.address);
        });

        it("Should revoke ERC20 delegation", async function () {
            await erc20Token.approve(nftDelegationExtension.getAddress(), ethers.parseEther("100")); // Approve NFTDelegationExtension contract to spend ERC20 tokens
            await nftDelegationExtension.depositERC20(ethers.parseEther("100")); // Deposit ERC20 tokens into NFTDelegationExtension

            await nftDelegationExtension.delegateERC20(addr1.address, ethers.parseEther("50")); // Delegate ERC20 tokens to addr1
            await nftDelegationExtension.revokeERC20Delegation(); // Revoke ERC20 delegation

            // Check if ERC20 delegation is revoked
            expect(await nftDelegationExtension.getERC20Delegate(owner.address)).to.equal(constants.ZERO_ADDRESS);
        });
    });

    describe("Override Functionality", function () {
        it("Should override safeTransferFrom for ERC1155", async function () {
            // Mint and deposit an ERC721 token
            await erc721Token.mint(owner.address, 1);
            await erc721Token.setApprovalForAll(nftDelegationExtension.getAddress(), true);
            await nftDelegationExtension.depositERC721(erc721Token.getAddress(), 1, 1);
            await nftDelegationExtension.delegateERC271(addr1.address, 1, 1);

            // Perform safeTransferFrom
            await nftDelegationExtension.safeTransferFrom(owner.address, addr1.address, 1, 1, "0x");

            // Check if the delegation has been revoked
            expect(await nftDelegationExtension.getERC721Delegate(1, 1)).to.equal(constants.ZERO_ADDRESS);
        });
    });
});
