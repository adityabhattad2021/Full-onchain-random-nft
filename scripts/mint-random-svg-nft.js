const { ethers, getNamedAccounts, network } = require("hardhat");
const { deveplomentChains } = require("../helper-hardhat-config");

async function main() {
	console.log("---------------------------------------------------------------------");
	console.log("Trying to mint RandomNFT");
    const { deployer } = await getNamedAccounts();
    console.log("---------------------c 1---------------------");
	const randomSVGNFT = await ethers.getContract("RandomSVGNFT", deployer);
	const tokenId = await randomSVGNFT.getTokenCounter();
    console.log("---------------------c 2---------------------",tokenId);
	const transectionResponse = await randomSVGNFT.createNFT();
    console.log("---------------------c 3---------------------");
    const transectionRecipt = await transectionResponse.wait(1);
    console.log("---------------------c 4---------------------");
    const requestId = transectionRecipt.events[1].args.requestId;
    console.log("---------------------c 5---------------------");
    
    if (network.config.chainId == "1337") {
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock");
        console.log("Function call: fulfillRandomness");
        await vrfCoordinatorV2Mock.fulfillRandomWords(requestId, randomSVGNFT.address);
    }
    
    console.log("---------------------c 6---------------------");
    const mintTransectionResponse = await randomSVGNFT.finishMint(tokenId);
    console.log("---------------------c 7---------------------");
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
