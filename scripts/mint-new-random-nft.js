const { ethers, getNamedAccounts } = require("hardhat");


async function main() {
	console.log("---------------------------------------------------------------------");
	console.log("Trying to mint RandomNFT");
    const { deployer } = await getNamedAccounts();
	const randomSVGNFT = await ethers.getContract("NEWRANDOMNFT", deployer);
	const tokenId = await randomSVGNFT.getTokenCounter();
	const transectionResponse = await randomSVGNFT.createNFT("21");
    await transectionResponse.wait(1);
    const mintTransectionResponse = await randomSVGNFT.finishMint(tokenId);
    await mintTransectionResponse.wait(1);
	console.log(
		`NFT Created Successfully, its token URI is ${await randomSVGNFT.tokenURI(tokenId)}`
	);
    console.log("---------------------------------------------------------------------");

}

main()
	.then(() => {
		process.exit(0);
	})
	.catch((error) => {
		console.log(error);
		process.exit(1);
	});
