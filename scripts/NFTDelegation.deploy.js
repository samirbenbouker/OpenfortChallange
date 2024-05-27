async function main() {
    // Deploying the NFTDelegation contract
    const NFTDelegation = await ethers.getContractFactory("NFTDelegation");
    console.log("Deploying NFTDelegation...");
    const nftDelegation = await NFTDelegation.deploy();
    await nftDelegation.waitForDeployment();
    console.log("NFTDelegation deployed to:", await nftDelegation.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });